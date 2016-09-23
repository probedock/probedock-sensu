lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'date'
require_relative 'lib/probedock-sensu-plugins-docker'

Gem::Specification.new do |s|
  s.authors                = ['Probe Dock Contributors']
  s.date                   = Date.today.to_s
  s.description            = 'This plugin provides native Docker instrumentation
                              for monitoring of containers'
  s.email                  = '<contact@probedock.io>'
  s.executables            = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  s.files                  = Dir.glob('{bin,lib}/**/*') + %w(LICENSE README.md CHANGELOG.md)
  s.homepage               = 'https://github.com/probedock/probedock-sensu-plugins-docker'
  s.license                = 'MIT'
  s.metadata               = { 'maintainer'         => '@prevole',
                               'development_status' => 'active',
                               'production_status'  => 'unstable - testing recommended',
                               'release_draft'      => 'false',
                               'release_prerelease' => 'false' }
  s.name                   = 'sensu-plugins-probedock-docker'
  s.platform               = Gem::Platform::RUBY
  s.post_install_message   = 'You can use the embedded Ruby by setting EMBEDDED_RUBY=true in /etc/default/sensu'
  s.require_paths          = ['lib']
  s.required_ruby_version  = '>= 2.0.0'
  s.summary                = 'Sensu plugins for docker'
  s.test_files             = s.files.grep(%r{^(test|spec|features)/})
  s.version                = ProbedockSensuPluginsDocker::Version::VER_STRING

  s.add_runtime_dependency 'docker-api',    '1.21.0'
  s.add_runtime_dependency 'sensu-plugin',  '~> 1.2.0'
  s.add_runtime_dependency 'sys-proctable', '0.9.8'
  s.add_runtime_dependency 'net_http_unix', '0.2.2'

  s.add_development_dependency 'bundler',                   '~> 1.7'
  s.add_development_dependency 'github-markup',             '~> 1.3'
  s.add_development_dependency 'pry',                       '~> 0.10'
  s.add_development_dependency 'rake',                      '~> 10.0'
  s.add_development_dependency 'redcarpet',                 '~> 3.2'
  s.add_development_dependency 'rspec',                     '~> 3.1'
  s.add_development_dependency 'yard',                      '~> 0.8'
end
