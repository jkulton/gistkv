Gem::Specification.new do |s|
  s.add_development_dependency 'bundler', '>= 1', '< 3'
  s.add_development_dependency 'simplecov', '>= 0.21.2', '< 1'
  s.add_development_dependency 'webmock', '>= 3', '< 4'
  s.add_dependency 'faraday', '>= 2', '< 3'
  s.name = 'gistkv'
  s.version = '0.1.0'
  s.summary = 'Use GitHub gists as simple key/value databases'
  s.authors = ['Jon Kulton']
  s.email = 'hello@jkulton.com'
  s.files = ['lib/gistkv.rb']
  s.homepage = 'https://github.com/jkulton/gistkv'
  s.license = 'MIT'
  s.required_ruby_version = '>= 3.0.0'
end