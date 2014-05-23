# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'night_watch/version'

Gem::Specification.new do |spec|
  spec.name          = "night_watch"
  spec.version       = NightWatch::VERSION
  spec.authors       = ["Money Advice Service", "Gareth Visagie"]
  spec.email         = ["development.team@moneyadviceservice.org.uk", "gareth@gjvis.com"]
  spec.description   = %q{Find visual regression introduced by changes to upstream bower modules}
  spec.summary       = %q{Find visual regression introduced by changes to upstream bower modules}
  spec.homepage      = "https://github.com/moneyadviceservice/night_watch"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "wraith", "1.1.6"
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "commander"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.0"
  spec.add_development_dependency "pry"
end
