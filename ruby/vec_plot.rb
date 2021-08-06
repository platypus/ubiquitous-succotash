##vec_plot.rb

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

##generate transpose of matrix and apply to point
def transpose_3d (ang, pt0)
	angle = ang.map { |i| (i/180)*Math::PI }
	xyz = Matrix.column_vector(pt0)
	rotz = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]).transpose 
	roty = Matrix.rows([[Math.cos(angle[1]),0,Math.sin(angle[1])],[0,1,0],[-Math.sin(angle[1]),0,Math.cos(angle[1])]]).transpose
	rotx = Matrix.rows([[1,0,0],[0,Math.cos(angle[0]),-Math.sin(angle[0])],[0,Math.sin(angle[0]),Math.cos(angle[0])]]).transpose
	temp = (rotz*roty*rotx*xyz).map { |n| n.truncate(5) }
	i = [temp[0,0],temp[1,0],temp[2,0]]
	return i
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

pt0 = [0,1,0]
particley = []

angle.each do |i|
	particley.append(translate_3d i, pt0)
end	1

##measure distance to all points and save distance to nearest eight
tempdist=[]
modfilein.each_with_index do |el, i|
	tempdist = []
	(i+1..modfilein.length-1).each do |j|
		if (el[1]-modfilein[j][1]).abs <= 64 && dist_3d(el, modfilein[j]) <= 64
			magn = dist_3d(el, modfilein[j]) 
			ivec = el.map.with_index {|v, i| v-modfilein[j][i]}
			vect = transpose_3d(angle[i], ivec)
			tempdist.append([magn, vect[0], vect[1], vect[2]]) 
		end
	end
	disteight[i] = tempdist.min(8)
end

disteight.map! {|i| i.map! {|j| j.drop(1).join(",")}}

vectfile = file.gsub("\.csv", "_vect\.csv")
File.write(vectfile, disteight.join("\n"))

finish = Time.now
deltat = finish-start
puts deltat
