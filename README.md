# Overview

[![Build Status](https://travis-ci.org/duosecurity/duo_api_ruby.svg?branch=master)](https://travis-ci.org/duosecurity/duo_api_ruby)
[![Issues](https://img.shields.io/github/issues/duosecurity/duo_api_ruby)](https://github.com/duosecurity/duo_api_ruby/issues)
[![Forks](https://img.shields.io/github/forks/duosecurity/duo_api_ruby)](https://github.com/duosecurity/duo_api_ruby/network/members)
[![Stars](https://img.shields.io/github/stars/duosecurity/duo_api_ruby)](https://github.com/duosecurity/duo_api_ruby/stargazers)
[![License](https://img.shields.io/badge/License-View%20License-orange)](https://github.com/duosecurity/duo_api_ruby/blob/master/LICENSE)

**Auth** - https://www.duosecurity.com/docs/authapi

**Admin** - https://www.duosecurity.com/docs/adminapi

**Accounts** - https://www.duosecurity.com/docs/accountsapi

## Tested Against Ruby Versions:
* 2.7
* 3.0
* 3.1
* 3.2

## TLS 1.2 and 1.3 Support

Duo_api_ruby uses the Ruby openssl extension for TLS operations.

All currently supported Ruby versions (2.7 and higher) support TLS 1.2 and 1.3.

# Installing

Development:

```
$ git clone https://github.com/duosecurity/duo_api_ruby.git
$ cd duo_api_ruby
```

System:

```
$ gem install duo_api
```

Or add the following to your project:

```
gem 'duo_api', '~> 1.0'
```

# Using

TODO

# Testing

```
$ rake
Loaded suite /usr/lib/ruby/vendor_ruby/rake/rake_test_loader
Started
........

Finished in 0.002024715 seconds.
--------------------------------------------------------------------------------------------------------
8 tests, 10 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
100% passed
--------------------------------------------------------------------------------------------------------
3951.17 tests/s, 4938.97 assertions/s
```

# Linting

```
$ rubocop
```
