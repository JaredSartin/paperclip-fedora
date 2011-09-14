# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "paperclip-fedora/version"

include_files = ["README*", "Rakefile", "{lib,tasks}/**/*"].map do |glob|
  Dir[glob]
end.flatten

Gem::Specification.new do |s|
  s.name        = "paperclip-fedora"
  s.version     = Paperclip::Fedora::VERSION
  s.authors     = ["Jared Sartin"]
  s.email       = ["jaredsartin@gmail.com"]
  s.homepage    = "https://github.com/JaredSartin/paperclip-fedora"
  s.summary     = %q{Fedora Commons storage support for paperclip file attachment}
  s.description = %q{Adds Fedora Commons storage support for the Paperclip gem.}

  s.rubyforge_project = "paperclip-fedora"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "paperclip"
  s.add_dependency "rubydora"
  s.add_development_dependency "rake", "0.9.2"
end
