# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "youtrack/version"

Gem::Specification.new do |s|
  s.name        = "youtrack_api"
  s.version     = YouTrack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Anna Zhdan', 'Jason Rickman']
  s.email       = ['eta503@gmail.com']
  s.homepage    = 'https://github.com/jrickman/youtrack-rest-ruby-library'
  s.summary     = %q{Ruby wrapper around YouTrack REST api}
  s.description = %q{Ruby wrapper around YouTrack REST api}

  #~ s.rubyforge_project = "youtrack_api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README"]
end
