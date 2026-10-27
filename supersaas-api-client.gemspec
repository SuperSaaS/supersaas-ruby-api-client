# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'supersaas-api-client/version'

Gem::Specification.new do |spec|
  spec.name          = 'supersaas-api-client'
  spec.version       = Supersaas::VERSION
  spec.authors       = ['Kaarle Kulvik']
  spec.email         = ['kaarle@supersaas.com']

  spec.summary       = 'Manage appointments and users on the SuperSaaS scheduling platform'
  spec.description   = 'Online appointment scheduling for any type of business. Flexible and affordable booking software that can be integrated into any site. Free basic version.'
  spec.homepage      = 'https://www.supersaas.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5'

  spec.metadata['source_code_uri'] = 'https://github.com/SuperSaaS/supersaas-ruby-api-client'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/SuperSaaS/supersaas-ruby-api-client/issues'
  spec.metadata['documentation_uri'] = 'https://www.supersaas.com/info/dev'

  # Ship the library and its documentation only. bin/console and bin/setup are development helpers,
  # not executables to install on the user's PATH.
  spec.files         = Dir['lib/**/*.rb', 'examples/*.rb', 'README.md', 'LICENSE']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
