##clean_PtsAdded.rb

require 'csv'
require 'matrix'

##calculate the distance between two 3D points
def dist_3d (pt1, pt2)
	Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

start = Time.now

if ARGV.length == 1
	modfile = ARGV[0]
end	

ARGV.clear

modcsv = CSV.read(modfile, col_sep:" ", converters: :numeric, skip_lines: /#/)

modfilein = []

modcsv.each do |i|
	modfilein.append([i[0],i[1],i[2]])
end

##measure distance to all points and save distance to nearest eight
modfilein.each_with_index do |el, i|
	#if (i%5000 == 0) 
	#	puts i
	#end
  next if el[0] <= 0
	(i+1..modfilein.length-1).each do |j|
		if  ((el[1]-modfilein[j][1]).abs <= 5 \
	    	  && (el[0]-modfilein[j][0]).abs <= 5 \
		      && (el[2]-modfilein[j][2]).abs <= 5 \
		      && dist_3d(el, modfilein[j]) <= 4)
			      modfilein[j] = [-10,-10,-10]
		end
	end 
end

newmod = modfilein - [[-10,-10,-10]]

newmod.map! { |i| i.join("\t") }

newmodfile = modfile.gsub("\.txt", "_clean\.txt")
File.open(newmodfile, "w+") do |i|
	i.puts(newmod)
end

finish = Time.now
deltat = finish-start
puts deltat
