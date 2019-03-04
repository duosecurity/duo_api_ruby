Gem::Specification.new do |s|
  s.name        = 'duo_api'
  s.version     = '1.1.0'
  s.summary     = 'Duo API Ruby'
  s.description = 'A Ruby implementation of the Duo API.'
  s.email       = 'support@duo.com'
  s.homepage    = 'https://github.com/duosecurity/duo_api_ruby'
  s.license     = 'BSD-3-Clause'
  s.authors     = ['Duo Security']
  s.files       = [
    'lib/duo_api.rb',
    'ca_certs.pem'
  ]
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rubocop', '~> 0.49.0'
  s.add_development_dependency 'test-unit', '~> 3.2'
  s.add_development_dependency 'mocha', '~> 1.8.0'
end
