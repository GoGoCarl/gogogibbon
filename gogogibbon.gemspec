require File.expand_path('../lib/gogogibbon/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'gogogibbon'
  s.version       = GoGoGibbon::VERSION
  s.summary       = 'Useful helpers for Gibbon'
  s.description   = 'A wrapper for Gibbon containing useful helper methods.'
  s.authors       = ['GoGoCarl']
  s.email         = 'carl.scott@solertium.com'
  s.files         = Dir['lib/**/*'] + Dir['*.rb'] + ["gogogibbon.gemspec"]
  s.require_paths = ["lib"]
  s.homepage      = 'http://github.com/GoGoCarl/gogogibbon'

  s.add_dependency 'gibbon'
end
