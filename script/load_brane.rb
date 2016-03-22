#!/usr/bin/env ruby

unless ARGV.size > 0
  $stderr.puts 'usage: load_brane.rb path/to/lines.txt'
  exit 1
end

require_relative '../lib/brane/redis-backwords'

brane = Brane::Redis.new
brane.redis = Redis.new(url: 'redis://localhost:6379/1')

IO.foreach(ARGV.first) do |line|
  brane.add line
end
