#distance_to_points.rb

require 'csv'

def dist_3d (pt1, pt2)
	Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

puts "File name:"
file = gets.chomp!

data = CSV.read(file, converters: :float)

distance = dist_3d data[0], data[1]

centroid = [0,0,0]

data.each do |i|
	centroid[0] += i[0]
	centroid[1] += i[1]
	centroid[2] += i[2]
end

centroid.map! { |n| n/data.length }

puts centroid
puts distance.to_s