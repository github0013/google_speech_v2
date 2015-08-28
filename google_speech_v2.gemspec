# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'google_speech_v2/version'

Gem::Specification.new do |spec|
  spec.name          = "google_speech_v2"
  spec.version       = GoogleSpeechV2::VERSION
  spec.authors       = ["ore"]
  spec.email         = ["orenoimac@gmail.com"]
  spec.summary       = %q{google speech api v2 gem}
  spec.description   = %q{google speech api v2 - the ruby way}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "dotenv"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"

  spec.add_dependency "activesupport"
  spec.add_dependency "mechanize"
end