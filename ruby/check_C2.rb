##check_C2.rb

require 'csv'
require 'set'

##generates array +/- 1 for point
##converts array back to csv
##checks old model for any points in array
def rounding_error(point, modset)
   rounding = Array.new(27, point)
   rounding.map!.each_with_index do |el, i|
      a = el[0].to_i + ((i / 9.5).to_i) - 1
      b = el[1].to_i + ((i / 3.1).to_i % 3) - 1
      c = el[2].to_i + (i % 3) - 1
      el = [a,b,c].join(",")
   end
   roundset = rounding.to_set
   roundset.each do |i|
     return true if modset.include?(i)
   end
   return false
end

##calculate the distance between two 3D points
def dist_3d (pt1, pt2)
        Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

if ARGV.length == 2
   newmod = ARGV[0]
   oldmod = ARGV[1]
end

ARGV.clear

modcsv = CSV.read(newmod, col_sep:" ", converters: :integer, skip_lines: /#/)
oldcsv = CSV.read(oldmod, col_sep:" ", converters: :integer, skip_lines: /#/)

modset = modcsv.to_set
oldset = oldcsv.to_set
distarr = []

##measure distance to all points and save distance to nearest eight
modset.each_with_index do |el, i|
        magn = 25
        oldset.each_with_index do |le, j|
                if (el[1]-le[1]).abs <= 24 && dist_3d(el, le) <= 24
                        magn = [dist_3d(el, le), magn].min
                end
        end
        distarr[i] = magn
end

avgdist = distarr.sum / distarr.size
sumdist = distarr.sum(0.0) { |i| (i - avgdist)**2 }
vardist = sumdist / (distarr.size - 1)
diststd = Math.sqrt (vardist)
distthr = 0
distarr.each do |i|
        if i <= 5
                distthr = distthr + 1
        end
end

puts distarr.min
puts distarr.max
puts avgdist
puts diststd
puts distarr.size
puts distthr
