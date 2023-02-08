##clean_gold.rb

require 'csv'
require 'set'

require 'matrix'


##calculate the distance between two 3D points
def dist_3d (pt1, pt2)
        Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

if ARGV.length == 3
   newmod = ARGV[0]
   goldmod = ARGV[1]
   motl = ARGV[2]
end

ARGV.clear

modcsv = CSV.read(newmod, col_sep:" ", converters: :numeric, skip_lines: /#/)
goldcsv = CSV.read(goldmod, col_sep:" ", converters: :numeric, skip_lines: /#/)
motlcsv = CSV.read(motl, converters: :numeric, skip_lines: /CCC|#/)

modpts = []
goldpts = []

modcsv.each do |el|
        modpts.append([el[0],el[1],el[2]])
end

goldcsv.each do |el|
        goldpts.append([el[0],el[1],el[2]])
end

##measure distance to all points and save distance
count = 0
modpts.each_with_index do |el, i|
        goldpts.each_with_index do |le, j|
                if motlcsv[i][0] > 0.0 && (el[1]-le[1]).abs <= 48 && dist_3d(el, le) <= 48
                        count = count + 1
                        motlcsv[i][19] = -9999
		end
        end
end

modcsv.map! { |i| i.join(",") }

puts count

header = File.open(motl) {|f| f.readline}

motlcsv.map! {|i| i.join(",")}

newmotlfile = motl.gsub("\.csv", "_clean\.csv")
File.open(newmotlfile, "w+") do |i|
        i.puts(header)
	i.puts(motlcsv)
end
