##dist_to_plane.rb

require 'csv'
require 'matrix'

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
def translate_3d (ang, pt0)
	angle = ang.map { |i| (i/180)*Math::PI }
	xyz = Matrix.column_vector(pt0)
	rotz = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]) 
	roty = Matrix.rows([[Math.cos(angle[1]),0,Math.sin(angle[1])],[0,1,0],[-Math.sin(angle[1]),0,Math.cos(angle[1])]])
	rotx = Matrix.rows([[1,0,0],[0,Math.cos(angle[0]),-Math.sin(angle[0])],[0,Math.sin(angle[0]),Math.cos(angle[0])]])
	temp = (rotx*roty*rotz*xyz).map { |n| n.truncate(5) }
	i = [temp[0,0],temp[1,0],temp[2,0]]
	return i
end

##determine the equation for a plane
def plane_3d (ang, pt)
	pz = translate_3d(ang, [0,0,-1])
	ppz = pt.map.with_index {|v, i| v+pz[i]}
	vecz = pt.map.with_index {|v, i| v-ppz[i]}
	vecd = (pt.map.with_index {|v, i| v*vecz[i]}).sum
	vecz.append(-1*vecd)
	return vecz
end

##calculate distance from a point to a plane
def dist_plane (plane, pt)
	num = ((plane[0]*pt[0])+(plane[1]*pt[1])+(plane[2]*pt[2])+plane[3]).abs
	den = Math.sqrt(plane[0]**2+plane[1]**2+plane[2]**2)
	dist = num/den
	return dist
end
	

start = Time.now

if ARGV.length == 2
	file = ARGV[0]
	modfile = ARGV[1]
end	

ARGV.clear

data = CSV.read(file, converters: :numeric, skip_lines: /#/)
modcsv = CSV.read(modfile, col_sep:" ", converters: :numeric, skip_lines: /#/)

angle = []
modfilein = []
disteight = []

data.each do |i|
	angle.append([i[4],i[5],i[6]])
end

modcsv.each do |i|
	modfilein.append([i[0],i[1],i[2]])
end

##calculate plane for each point
planes = []
modfilein.each_with_index do |el, i|
	planes.append(plane_3d(angle[i], el))
end

##measure distance to all points and save distance to nearest eight
tempdist=[]
modfilein.each_with_index do |el, i|
	tempdist = []
	(i+1..modfilein.length-1).each do |j|
		if (el[1]-modfilein[j][1]).abs <= 32 && (dist_3d(el, modfilein[j])) <=32
			tempdist.append(dist_plane(planes[i], modfilein[j])) 
		end
	end
	disteight[i] = tempdist.min(12)
end

modfilein.reject!.each_with_index do |el, i|
	disteight[i][4].nil? || disteight[i][4] > 4
end

modfilein.map! { |i| i.join(" ") }

puts modfilein.length

newmodfile = file.gsub("\.csv", "_newmodel\.txt")
File.write(newmodfile, modfilein.join("\n"))

finish = Time.now

deltat = finish-start

puts deltat


