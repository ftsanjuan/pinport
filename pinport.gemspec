require "pinport/version"

Gem::Specification.new do |s|
  s.name          = 'pinport'
  s.version       = Pinport::VERSION
  s.date          = '2013-04-29'
  s.summary       = %q{A PIN importing tool}
  s.description   = %q{Pinport is a command-line tool for importing a large list of PINs (Personal Identification Numbers) into a MySQL Database}
  s.authors       = ['Francis San Juan']
  s.email         = 'francis.sanjuan@gmail.com'
  s.license       = 'MIT'
  s.licenses      = ['MIT']
  s.homepage      = 'https://github.com/ftsanjuan/pinport'
  s.require_paths = ['lib']
  s.files         =  %w(README.md LICENSE.md README.md pinport.gemspec)
  s.files        +=  Dir.glob("lib/**/*.rb")
  s.files        +=  Dir.glob("lib/**/generators/templates/**/*")
  s.executables  << 'pinport'

  s.add_development_dependency  'bundler', '~> 1.0'
end