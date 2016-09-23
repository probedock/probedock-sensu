#!/usr/bin/env ruby

#
#   check-docker-container
#
# DESCRIPTION:
# This is a simple check script for Sensu to check the state of Docker
# containers. It supports also the scaling from Docker Compose.
#
# In the case of scaling, we have a base container name followed by a number.
# The idea is to get all the containers names from this familly and check if
# the containers are running
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: net_http_unix
#
# USAGE:
#   check-docker-container.rb -c default_app -s 3 -w 2 -i 1
#   => 3 default_app_* containers running -> OK
#   => 2 default_app_* containers running -> WARNING
#   => 1 default_app_* containers running -> CRITICAL
#
# NOTES:
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'json'
require 'net_http_unix'

class CheckDockerContainer < Sensu::Plugin::Check::CLI
  option :host,
         short: '-h HOST',
         long: '--host HOST',
         description: 'Docker socket to connect. TCP: "host:port" or Unix: "/path/to/docker.sock" (default: "127.0.0.1:2375")',
         default: '127.0.0.1:2375'

  option :container,
         short: '-c CONTAINER',
         long: '--container CONTAINER',
         description: 'Specify a container name or ID'

  option :excludes,
         short: '-e CONTAINER_EXCLUDED[,CONTAINER_EXCLUDED]'
         long: '--container-excluded CONTAINER_EXCLUDED[,CONTAINER_EXCLUDED]',
         description: 'Specify one or more container name to exclude.',
         proc: proc { |a| a.split(',') }

  option :container_prefix,
         short: '-p PREFIX',
         long: '--container-prefix PREFIX',
         description: 'A prefix prepend to the container names. Ex: prefix = default, container = redis, result -> default_redis'

  option :scale,
         short: '-s SCALE',
         long: '--scale SCALE',
         description: 'The maximum number of instantiated containers of a certain type. (default: 0, meaning no scaling is used)',
         default: 0

  option :warning_threshold,
         short: '-w WARNING',
         long: '--warning-threshold WARNING',
         description: 'If the number of non-running containers is greater than or equal to this threshold, a warning is raised. (default: 1)',
         default: 1

  option :critical_threshold,
         short: '-i CRITICAL',
         long: '--critical-threshold CRITICAL',
         description: 'If the number of non-running containers is greater than or equal to this threshold, a critical is raised. (default: 1)',
         default: 1

  def run
    client =  NetX::HTTPUnix.new(config[:host])

    # Build the correct container name
    container_name = if config[:container_prefix]
      "#{config[:container_prefix]}_#{config[:container]}"
    else
      config[:container]
    end

    # Create the container instance names in case scaling is used
    cmd_output = `docker -H #{config[:host]} ps -a --format="{{.ID}}\t{{.Names}}" --filter="name=#{container_name}"`
    containers = cmd_output.split(/\n/).inject([]) do |memo, container|
      # The container data is <id>\t<name> which will be transformed to { id: <id>, name: <name> }
      memo << Hash[ [:id, :name].zip(container.split(/\t/)) ]
      memo
    end

    # Collect the results
    results = {
      not_found: { count: 0, messages: [] },
      running: { count: 0, messages: [] },
      not_running: { count: 0, messages: [] },
      error: { count: 0, messages: [] }
    }

    # Remove containers that should be excluded
    unless config[:excludes].empty?
      containers = config[:excludes].each do |exclude|
        containers.delete_if { |item| item[:container] == exclude || item[:id] == exclude }
      end
    end

    # Check if there is at least one container
    if containers.empty?
      results[:not_found][:count] = 1
      results[:not_found][:messages] << "No container found corresponding to #{container_name}"
    end

    containers.each do |container|
      path = "/containers/#{container[:id]}/json"
      req = Net::HTTP::Get.new path

      begin
        # Try to retrieve container
        response = client.request(req)

        # Container not found
        if response.body.include? 'no such id'
          results[:not_found][:count] += 1
          results[:not_found][:messages] << "#{container[:name]} was not found"
        end

        # Retrieve the state of the container
        container_state = JSON.parse(response.body)['State']['Status']

        # Check if the container is running
        if container_state == 'running'
          results[:running][:count] += 1
          results[:running][:messages] << "#{container[:name]} is running"
        else
          results[:not_running][:count] += 1
          results[:not_running][:messages] << "#{container[:name]} is #{container_state}"
        end
      rescue JSON::ParserError => e
        results[:error][:count] += 1
        results[:error][:messages] << "JSON Error for #{container[:name]}: #{e.inspect}"
      rescue => e
        results[:error][:count] += 1
        results[:error][:messages] << "Error for #{container[:name]}: #{e.inspect}"
      end
    end

    message = build_message(results)

    # In case of error or not found
    if results[:error][:count] > 0 || results[:not_found][:count] > 0
      critical message

    # In case of not running
    elsif results[:not_running][:count] > 0
      # Check against the critical threshold
      if results[:not_running][:count] >= config[:critical_threshold].to_i
        critical message

      # Check against the warning threshold
      elsif results[:not_running][:count] >= config[:warning_threshold].to_i
        warning message

      # No violation of thresholds, then acceptable situation
      else
        ok message
      end
    else
      ok message
    end
  end

  def build_message(results)
    messages = []
    results.each_value do |result|
      message = result[:messages].join(', ')
      messages << message unless message.empty?
    end

    messages.join(', ')
  end
end
