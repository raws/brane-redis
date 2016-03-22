#!/usr/bin/env ruby

unless ARGV.size > 0
  $stderr.puts 'usage: load_irc_logs.rb path/to/logs.json'
  exit 1
end

require 'yajl'

File.open(ARGV.first) do |io|
  Yajl::Parser.parse(io) do |object|
    if object['message']
      puts object['message']
    end
  end
end
