#!/usr/bin/env ruby


require 'sensu-plugin/check/cli'
require 'json'
require 'net_http_unix'

def create_docker_client
  client = nil
  if config[:docker_host][0] == '/'
    host = 'unix://' + config[:docker_host]
    client = NetX::HTTPUnix.new(host)
  else
    split_host = config[:docker_host].split ':'
    client = if split_host.length == 2
               NetX::HTTPUnix.new(split_host[0], split_host[1])
             else
               NetX::HTTPUnix.new(config[:docker_host], 2375)
             end
  end

  client
end

#
# Check HTTP
#
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

  option :container_prefix,
         short: '-p PREFIX',
         long: '--container-prefix PREFIX',
         description: 'A prefix prepend to the container names. Ex: prefix = default, container = redis, result -> default_redis',

  option :scale,
         short: '-s SCALE',
         long: '--scale SCALE',
         description: 'The maximum number of instantiated containers of a certain type. (default: 0, meaning no scaling is used)',
         default: 0

  option :warning_threshold,
         short: '-wt WARNING',
         long: '--warning-threshold WARNING',
         description: 'If the number of non-running containers is greater than or equal to this threshold, a warning is raised. (default: 1)',
         default: 1

  option :critical_threshold,
         short: '-ct CRITICAL',
         long: '--critical-threshold CRITICAL',
         description: 'If the number of non-running containers is greater than or equal to this threshold, a critical is raised. (default: 1)',
         default: 1

  def run
    client = create_docker_client

    # Build the correct container name
    if config[:container_prefix]
      container_name = "#{config[:container_prefix]}_#{config[:container]}"
    else
      container_name = config[:container]
    end

    # Create the container instance names in case scaling is used
    containers = []
    if config[:scale]
      (1..config[:scale]).each do |i|
        containers << "#{container_name}_#{i}"
      end
    else
      containers << container_name
    end

    # Collect the results
    results = {
      not_found: {
        count: 0,
        messages: []
      },
      running: {
        count: 0,
        messages: []
      },
      not_running: {
        count: 0,
        messages: []
      },
      error: {
        count: 0,
        messages: []
      }
    }

    containers.each do |container|
      path = "/containers/#{container}/json"

      req = Net::HTTP::Get.new path
      begin
        # Try to retrieve container
        response = client.request(req)

        # Container not found
        if response.body.include? 'no such id'
          results[:not_found][:count]++
          results[:not_found][:messages] << "#{conatiner} was not found"
        end

        # Retrieve the state of the container
        container_state = JSON.parse(response.body)['State']['Status']

        # Check if the container is running
        if container_state == 'running'
          results[:running][:count]++
          results[:running][:mesages] << "#{container} is running"
        else
          results[:not_running][:count]++
          results[:not_running][:messages] << "#{container} is #{container_state}"
        end
      rescue JSON::ParserError => e
        results[:error][:count]++
        results[:error][:messages] << "JSON Error for #{container}: #{e.inspect}"
      rescue => e
        results[:error][:count]++
        results[:error][:messages] << "Error for #{container}: #{e.inspect}"
      end
    end

    message = build_message(results)

    # In case of error or not found
    if results[:error][:count] > 0 || results[:not_found][:count] > 0
      critical message

    # In case of not running
    elsif results[:not_running][:count] > 0
      # Check against the critical threshold
      if results[:not_running][:count] >= config[:critical_threshold]
        critical message

      # Check against the warning threshold
      elsif results[:not_running][:count] >= config[:warning_threshold]
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
    messages = results.inject([]) do |memo, result|
      memo << result[:messages].join(',')
    end

    messages.join(',')
  end
end
