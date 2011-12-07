#!/usr/bin/env ruby

total_population = Array.new
pop_by_site = Hash.new { |h, k| h[k] = Array.new }

File.open(ARGV[0]) do |h|

  h.each do |line|
    n, b, size, start, stop, dist = line.strip.split(',')

    total_population << dist.to_f
    pop_by_site[start] << dist.to_f
  end
end

mean_by_site = Hash.new

pop_by_site.each_key do |k|
  
  mean = pop_by_site[k].inject{ |sum, el| sum + el }.to_f/pop_by_site[k].size
  
  fail 'this should not happen :(' if mean_by_site.has_key? k
  
  mean_by_site[k] = mean
end

File.open('total_population.csv', 'w') do |h|
  total_population.each do |p|
    h.puts p
  end
end

File.open('mean_by_site.csv', 'w') do |h|
  mean_by_site.each_pair do |site, mean|
    h.puts "#{site},#{mean}"
  end
end