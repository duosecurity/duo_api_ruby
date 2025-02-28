# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'

desc('Run tests & linting')
task(default: %i[test lint])

desc('Run tests')
task(:test){ Rake::TestTask.new{ |t| t.libs << 'test' } }

desc('Run linting')
task(lint: %i[rubocop])
task(:rubocop){ RuboCop::RakeTask.new }
