#!/usr/bin/env ruby

r = /(\w+)(\(\)\s*\{.*?\})/m

input = $stdin.read

puts input, ""

input.scan(r) do |m|
  puts "export -f #{m.first}"
end
