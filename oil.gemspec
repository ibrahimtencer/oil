# -*- encoding: utf-8 -*-
#$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "oil"
  s.version     = 1.0
  s.authors     = ["Ibrahim Tencer"]
  s.email       = ["itencer1@gmail.com"]
  s.summary     = %q{library code for Ruby and Rails}
  #s.description = %q{ }
  s.files         = `git ls-files`.split("\n")
  #s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["."]

  #s.add_dependency "activerecord", ">=3.2.0"
end
