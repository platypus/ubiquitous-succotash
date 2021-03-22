##seed_lattice.rb

require 'csv'
require 'Matrix'

##calculate the distance between two 3D points
def dist_3d (pt1, pt2)
	Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

##generate vectors from origin to two 3D points and calculate angle between them
def angle_3d (pt1, pt2)
	mag1 = dist_3d pt1, [0,0,0]
	mag2 = dist_3d pt2, [0,0,0] 
	dotproduct = pt1[0]*pt2[0]+pt1[1]*pt2[1]+pt1[2]*pt2[2]
	angle = Math.acos(dotproduct/(mag1*mag2))*(180/Math::PI)
	return angle
end

##generate transformation matrix from x,y,z angles and apply to point
def translate_3d (radian, pt0)
	angle = radian.map { |i| (i/180)*Math::PI }
	xyz = Matrix.column_vector(pt0)
	rotz = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]) 
	roty = Matrix.rows([[Math.cos(angle[1]),0,Math.sin(angle[1])],[0,1,0],[-Math.sin(angle[1]),0,Math.cos(angle[1])]])
	rotx = Matrix.rows([[1,0,0],[0,Math.cos(angle[0]),-Math.sin(angle[0])],[0,Math.sin(angle[0]),Math.cos(angle[0])]])
	temp = (rotx*roty*rotz*xyz).map { |n| n.truncate(5) }
	i = [temp[0,0],temp[1,0],temp[2,0]]
	return i
end

if ARGV.length == 4
	file = ARGV[0]
	mofile = ARGV[1]
	rofile = ARGV[2]
	latfile = ARGV[3]
end	

ARGV.clear

##get filename from user and remove trailing whitespace
#puts "Summary:"
#file = gets.chomp!

#puts "MotiveList:"
#mofile = gets.chomp!

#puts "RotAxes:"
#rofile = gets.chomp! 

#puts "Lattice:"
#latfile = gets.chomp!

data = CSV.read(file, converters: :float, skip_lines: /#/)
oldmot = CSV.read(mofile, converters: :float, skip_lines: /#/)
oldrot = CSV.read(rofile, converters: :float, skip_lines: /#/)
latpts = CSV.read(latfile, converters: :float, skip_lines: /#/)


angle = []
modfilein = []
data.each do |i|
	angle.append([i[4],i[5],i[6]])
	modfilein.append([i[1],i[2],i[3]])
end

newpts = []
newrot = []
newmot = []
newsum = []


angle.each_with_index do |el, i|
	latpts.each do |j|
		shift = translate_3d(el, j)
		newpts.append(modfilein[i].map.with_index {|v, k| (v-shift[k]).to_i})
		newrot.append(oldrot[i])
		newmot.append(oldmot[i+1])
		newsum.append([1]+newpts[-1]+angle[i])	
	end
end	


keepnew = []
newpts.each_with_index do |el, i|
	k = 1
	modfilein.each do |j|
		k = 0 if (dist_3d(el, j) <= 7)			
	end
	keepnew.append(k)	
end

newpts.each_with_index do |el, i|
	(i+1..newpts.length-1).each do |j|
		keepnew[i] = 0 if (dist_3d(el, newpts[j]) < 7)
	end
end

newpts.reject!.each_with_index do |el, i|
	keepnew[i] == 0
end

newpts.map! { |i| i.join("\t") }

newmodfile = file.gsub("\.csv", "_newmodel\.txt")
File.write(newmodfile, newpts.join("\n"))

newmot.reject!.each_with_index do |el, i|
	i > 0 && keepnew[i-1] == 0
end

newmot.map!.each_with_index do |el, i|
   if i > 0  
       arr = el.to_s.split(",")
       arr[3] = i.to_s
       el = arr.join(",")
   end
end

newmotfile = mofile.gsub("\.csv", "_newMOTL\.csv")
File.open(newmotfile, "w+") do |i|
	i.puts(newmot)
end

newsum.reject!.each_with_index do |el, i|
	keepnew[i] == 0
end

newsum.unshift(["#contour,X,Y,Z,xAngle,yAngle,zAngle"])

newsumfile = file.gsub("\.csv", "_newpts_Summary\.csv")
File.open(newsumfile, "w+") do |i|
	i.puts(newsum)
end

newrot.reject!.each_with_index do |el, i|
	keepnew[i] == 0
end

newrotfile = rofile.gsub("\.csv", "_newpts_RotAxes\.csv")
File.open(newrotfile, "w+") do |i|
	i.puts(newrot)
end
