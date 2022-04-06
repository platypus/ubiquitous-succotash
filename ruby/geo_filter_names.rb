##geo_filter_names.rb

require 'csv'
require 'matrix'

def eul2mat (ang)
	angle = ang.map { |i| (i.to_f/180)*Math::PI }
	z1mat = Matrix.rows([[Math.cos(angle[0]),-Math.sin(angle[0]),0],[Math.sin(angle[0]),Math.cos(angle[0]),0],[0,0,1]]) 
	xmat = Matrix.rows([[1,0,0],[0,Math.cos(angle[2]),-Math.sin(angle[2])],[0,Math.sin(angle[2]),Math.cos(angle[2])]])
	z2mat = Matrix.rows([[Math.cos(angle[1]),-Math.sin(angle[1]),0],[Math.sin(angle[1]),Math.cos(angle[1]),0],[0,0,1]]) 
	#rotmat = z1mat*xmat*z2mat   
     	rotmat = z2mat*(xmat*z1mat)
	return rotmat
end

def transpose_eul (ang)
        rotmat = eul2mat(ang)
	transmat = rotmat.transpose()
	return transmat
end

def rotate_pnt (ang, pnt=[0,1,0])
	rotmat = eul2mat(ang)
	temp = rotmat*Matrix.column_vector(pnt)
	i = [temp[0,0],temp[1,0],temp[2,0]]
	return i
end

def angle_3d (pt1, pt2)
	#mag1 = dist_3d pt1, [0,0,0]
	#mag2 = dist_3d pt2, [0,0,0] 
	dotproduct = pt1[0]*pt2[0]+pt1[1]*pt2[1]+pt1[2]*pt2[2]
	dotproduct = 0.9999999 if dotproduct >= 1.0
	dotproduct = -0.9999999 if dotproduct <= -1.0
	#angle = Math.acos(dotproduct/(mag1*mag2))*(180/Math::PI)
	angle = Math.acos(dotproduct)*(180/Math::PI)
	return angle
end

##calculate the distance between two 3D points
def dist_3d (pt1, pt2)
	Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

def plane_3d (ang, pt)
	pz = rotate_pnt(ang, [0,0,-1])
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

if ARGV.length == 1
	file = ARGV[0]
end	

ARGV.clear

data = CSV.read(file, converters: :numeric, skip_lines: /#/)

angle=[]
modpt=[]
names=[]

data.each do |el|
        angle.append([el[16],el[17],el[18]])
	modpt.append([el[7],el[8],el[9]])
	names.append(el[20])
end

angle.each do |el|
	if el[2] > 360
		el[2]=el[2]-360
	elsif el[2] < 0
		el[2]=el[2]+360
	end
	if el[2] > 180
		el[2]=360-el[2]
		el[1]=el[1]+180
	end
	if el[1] > 360
		el[1]=el[1]-360
	elsif el[1] < 0
		el[1]=el[1]+360
	end
	if el[0] > 360
		el[0]=el[0]-360
	elsif el[0] <0
		el[0]=el[0]+360
	end
end

##measure distance to all points and save distance to nearest eight
disteight=[]
keeppts=[]
nameout=[]
modpt.each_with_index do |el, i|
	tempdist = []
	p=rotate_pnt(angle[i])
	plani = plane_3d(angle[i], el)
	modpt.each_with_index do |le, j|
		if i != j && (el[1]-le[1]).abs <= 128 && dist_3d(el, le) <= 128 && dist_plane(plani, le) <= 10
			magn = dist_3d(el, le) 
			q=rotate_pnt(angle[j])
			dif=angle_3d(p,q)
			tempdist.append([magn, dif])
		end
	end
	#tempdist.reject! { |i| i.nil? }
	disteight[i] = tempdist.sort_by { |el| el[1] }
	if disteight[i][2].nil?
		keeppts[i]=1
		nameout.append(names[i])
	elsif disteight[i][2][1] < 15
		keeppts[i]=0
	else
		keeppts[i]=1
     		nameout.append(names[i])
	end
end

motfilein = File.readlines(file)
motfilein.reject!.each_with_index do |el, i|
	i > 0 && keeppts[i-1] == 1
end

motfilein.map!.each_with_index do |el, i|
   if i > 0 
      arr = el.split(",")
      arr[3] = i.to_s
      el = arr.join(",")
   else
      el
   end
end

newmotfile = file.gsub("\.csv", "_geo\.csv")
File.open(newmotfile, "w+") do |i|
	i.puts(motfilein)
end

newnamefile = file.gsub("\.csv", "_removednames\.txt")
File.open(newnamefile, "w+") do |i|
        i.puts(nameout)
end

finish = Time.now
deltat = finish-start
#puts deltat
