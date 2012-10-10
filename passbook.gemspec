Gem::Specification.new do |s|
  s.name = "passbook"
  s.version = "0.0.2"
  s.authors = ["Andrei Dinin", "Gregory Chow"]
  s.date = %q[2012-09-20]
  s.description = "Passbook integration for Ruby projects"
  s.summary = s.description
  s.email = 'andrei.dinin@xtremelabs.com'
  s.files = ['README.md', 'lib/passbook.rb', 'lib/passbook/config.rb', 'lib/passbook/config.rb']
  s.homepage = 'http://www.xtremelabs.com'
  s.has_rdoc = false
  s.rubyforge_project = 'xl-passbook-ruby'
  # s.add_dependency('fileutils' )
  s.add_dependency('json' )
end
