#!/usr/bin/env ruby
r = /(\s*)(\w+)(\(\)\s*\{)/
ob = /\{/
cb = /\}/
bc = 0
i = nil
f = nil
$stdin.each_line do |line|
  cbc = line.scan(cb).length
  bc += line.scan(ob).length - cbc
  r.match line do |m|
    i = m.captures[0]
    f = m.captures[1]
  end
  puts line
  if f && !f.empty? && cbc > 0 && bc == 0
    puts "#{i}export -f #{f}"
    i = nil
    f = nil
  end
end
