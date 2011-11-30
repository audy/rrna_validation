#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'dnaio'))

$stderr.puts 'loading'
records = DnaIO.new(File.open(ARGV.pop)).to_a

is_gap = Array.new(records.first.length)

is_gap.collect! { |x| x = true }

$stderr.puts 'filtering'

records.first.length.times do |i|
  records.each do |record|
    if ['G', 'A', 'T', 'C', 'U'].include? record.sequence[i].upcase
      is_gap[i] = false
      break
    end
  end
end

$stderr.puts 'writing'

records.each do |record|
  new_sequence = []
  record.sequence.chars.each_with_index do |g, i|
    if is_gap[i]
      next
    else
      new_sequence << g
    end
  end
  record.sequence = new_sequence.join
  puts record
end
