# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tvdb2/version'

Gem::Specification.new do |spec|
  spec.name          = "tvdb2"
  spec.version       = Tvdb2::VERSION
  spec.authors       = ["pioz"]
  spec.email         = ["epilotto@gmx.com"]

  spec.summary       = %q{Ruby wrapper for TVDB api version 2}
  spec.description   = %q{Ruby wrapper for TVDB api version 2 (https://api.thetvdb.com/swagger).}
  spec.homepage      = "https://github.com/pioz/tvdb2"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "yard", "~> 0.9"

  spec.add_runtime_dependency "httparty", "~> 0.15"
  spec.add_runtime_dependency "memoist", "~> 0.16"
end
