#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '.', 'lib', 'dnaio'))

records = DnaIO.new(File.open(ARGV.pop)).to_a

is_gap = Array.new(records.first.length)

is_gap.collect! { |x| x = true }

records.each do |record|
  record.sequence.chars.each_with_index do |g, i|
    if ['G', 'A', 'T', 'C', 'U'].include? g.upcase
      is_gap[i] = false
    end
  end
end

p is_gap

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