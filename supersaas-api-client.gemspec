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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
