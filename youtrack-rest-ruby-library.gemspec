# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "youtrack_api/version"

Gem::Specification.new do |s|
  s.name        = "youtrack_api"
  s.version     = YouTrackAPI::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Anna Zhdan', 'Jason Rickman', 'JD Huntington']
  s.email       = ['jdhuntington@gmail.com']
  s.homepage    = 'https://github.com/jdhuntington/youtrack-rest-ruby-library'
  s.summary     = %q{Ruby wrapper around YouTrack REST api}
  s.description = %q{Ruby wrapper around YouTrack REST api}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n") + ['Rakefile', 'Gemfile', 'Gemfile.lock']
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README"]

  s.add_development_dependency('rspec')
  s.add_development_dependency('rake')
end
