$:.push File.expand_path('../lib', __FILE__)

require "supersaas-api-client/version"

Gem::Specification.new do |spec|
  spec.name          = "supersaas-api-client"
  spec.version       = Supersaas::VERSION
  spec.authors       = ["Travis Dunn"]
  spec.email         = ["travis@supersaas.com"]

  spec.summary       = %q{Online bookings/appointments/calendars using the SuperSaaS scheduling platform.}
  spec.description   = %q{Online appointment scheduler for any type of business. Flexible and affordable booking software that can be integrated into any site. Free basic version.}
  spec.homepage      = "https://www.supersaas.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test)/})
  end
  spec.test_files    = Dir['test/**/*']
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17.3"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
