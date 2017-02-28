# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ptt/version'

Gem::Specification.new do |spec|
  spec.name          = 'ptt'
  spec.version       = PTT::VERSION
  spec.authors       = ['Alexander Sulim']
  spec.email         = ['hello@sul.im']
  spec.summary       = %q{PTT - Pneumatic Tube Transport}
  spec.description   = %q{PTT - messaging based on AMQP and some conventions}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'bunny'
  spec.add_runtime_dependency 'json'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
