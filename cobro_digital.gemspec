# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cobro_digital/version'

Gem::Specification.new do |spec|
  spec.name          = "cobro_digital"
  spec.version       = CobroDigital::VERSION
  spec.authors       = ["g.edera"]
  spec.email         = ["gab.edera@gmail.com"]

  spec.summary       = "Adaptador CobroDigital"
  spec.description   = "Adaptador para el Web Service de CobroDigital"
  spec.homepage      = "https://github.com/gedera/cobro_digital"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency(%q<savon>, ["= 2.4.0"])

  spec.add_dependency(%q<nokogiri>, ["~> 1.6"])
  spec.add_dependency(%q<wasabi>, ["~> 3.2.3"])
  spec.add_dependency(%q<akami>, ["~> 1.1"])
  spec.add_dependency(%q<nori>, ["~> 2.3.0"])
end
