# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'duo_api'
  s.version     = '1.5.1'
  s.summary     = 'Duo API Ruby'
  s.description = 'A Ruby implementation of the Duo API.'
  s.email       = 'support@duo.com'
  s.homepage    = 'https://github.com/duosecurity/duo_api_ruby'
  s.license     = 'BSD-3-Clause'
  s.authors     = ['Duo Security']
  s.files       = [
    'ca_certs.pem',
    'lib/duo_api.rb',
    'lib/duo_api/api_client.rb',
    'lib/duo_api/api_helpers.rb',
    'lib/duo_api/accounts.rb',
    'lib/duo_api/admin.rb',
    'lib/duo_api/auth.rb',
    'lib/duo_api/device.rb'
  ]
  s.required_ruby_version = '>= 2.5'
  s.add_dependency 'base64', '>= 0.2.0'
  s.add_development_dependency 'mocha', '~> 2.7.1'
  s.add_development_dependency 'ostruct', '~> 0.6.1'
  s.add_development_dependency 'rake', '~> 13.2.1'
  s.add_development_dependency 'rubocop', '~> 1.73.1'
  s.add_development_dependency 'test-unit', '~> 3.6.7'
end
