# Overview

[![Build Status](https://travis-ci.org/duosecurity/duo_api_ruby.svg?branch=master)](https://travis-ci.org/duosecurity/duo_api_ruby)
[![Issues](https://img.shields.io/github/issues/duosecurity/duo_api_ruby)](https://github.com/duosecurity/duo_api_ruby/issues)
[![Forks](https://img.shields.io/github/forks/duosecurity/duo_api_ruby)](https://github.com/duosecurity/duo_api_ruby/network/members)
[![Stars](https://img.shields.io/github/stars/duosecurity/duo_api_ruby)](https://github.com/duosecurity/duo_api_ruby/stargazers)
[![License](https://img.shields.io/badge/License-View%20License-orange)](https://github.com/duosecurity/duo_api_ruby/blob/master/LICENSE)

**Auth** - https://www.duosecurity.com/docs/authapi

**Admin** - https://www.duosecurity.com/docs/adminapi

**Accounts** - https://www.duosecurity.com/docs/accountsapi

# Compatibility
While the gem should work for Ruby versions >= 2.5, tests and linting may only work properly on Ruby versions >= 3.0.

Tests are only run on currently supported Ruby versions.

### Tested Against Ruby Versions:
* 3.1
* 3.2
* 3.3
* 3.4

### TLS 1.2 and 1.3 Support

duo_api_ruby uses the Ruby openssl extension for TLS operations.

All Ruby versions compatible with this gem (2.5 and higher) support TLS 1.2 and 1.3.

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
 - Examples of doing things [the hard way](/examples/the_hard_way.md)
 - Examples of doing things [the less hard way](/examples/the_less_hard_way.md)
 - Examples of doing things [the simple way](/examples/the_simple_way.md)

# Testing
###### (Testing and Linting can be done simultaneously by running `rake` without specifying a task)
```
rake test
```

# Linting
###### (Testing and Linting can be done simultaneously by running `rake` without specifying a task)
```
rake lint
```
