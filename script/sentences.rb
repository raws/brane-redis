#!/usr/bin/env ruby

require_relative '../lib/brane/redis-backwords'

brane = Brane::Redis.new
brane.redis = Redis.new(url: 'redis://localhost:6379/1')

10.times do
  puts brane.sentence(ARGV.first)
end
