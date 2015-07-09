# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openx_api/version'

Gem::Specification.new do |spec|
  spec.name          = "openx_api"
  spec.version       = OpenxApi::VERSION
  spec.authors       = ["Bin Shen"]
  spec.email         = ["bin.shen@openx.com"]

  spec.summary       = %q{Helper class for accessing the OX3 API}
  spec.homepage      = "https://github.com/openx/OX3-Ruby-API-Client"
  spec.license       = "BSD-3"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "oauth", "~> 0.4"
  spec.add_development_dependency "json", ">= 1.7"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3"
end
