##check_C2.rb

require 'csv'
require 'set'

require 'matrix'

##calculate rotation angle from euler angle
def eul2mat (ang)
	angle = ang.map { |i| (i.to_f/180)*Math::PI }
	z1mat = Matrix.rows([[Math.cos(angle[0]),-Math.sin(angle[0]),0],[Math.sin(angle[0]),Math.cos(angle[0]),0],[0,0,1]]) 
	xmat = Matrix.rows([[1,0,0],[0,Math.cos(angle[2]),-Math.sin(angle[2])],[0,Math.sin(angle[2]),Math.cos(angle[2])]])
	z2mat = Matrix.rows([[Math.cos(angle[1]),-Math.sin(angle[1]),0],[Math.sin(angle[1]),Math.cos(angle[1]),0],[0,0,1]]) 
     	rotmat = z2mat*(xmat*z1mat)
	return rotmat
end

##calculate matrix transpose from euler angle
def transpose_eul (ang)
        rotmat = eul2mat(ang)
	transmat = rotmat.transpose()
	return transmat
end

def rotate_pnt (ang, pnt=[0,0,1])
	rotmat = eul2mat(ang)
	temp = rotmat*Matrix.column_vector(pnt)
	i = [temp[0,0],temp[1,0],temp[2,0]]
	return i
end

def angle_3d (pt1, pt2)
	dotproduct = pt1[0]*pt2[0]+pt1[1]*pt2[1]+pt1[2]*pt2[2]
	dotproduct = 0.9999999 if dotproduct >= 1.0
	dotproduct = -0.9999999 if dotproduct <= -1.0
	angle = Math.acos(dotproduct)*(180/Math::PI)
	return angle
end



##calculate difference between two angles
#def dist_ang (angone, angtwo)
#	p = eul2mat(angone)
#	q = transpose_eul(angtwo)
#	r = p*q
#	theta = Math.acos((r.trace()-1)/2)
#	thetad = (180/Math::PI)*theta
#	return thetad
#end

##calculate the distance between two 3D points
def dist_3d (pt1, pt2)
	Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

if ARGV.length == 4
   newmod = ARGV[0]
   oldmod = ARGV[1]
   newmotl = ARGV[2]
   oldmotl = ARGV[3]
end

ARGV.clear

modcsv = CSV.read(newmod, col_sep:" ", converters: :numeric, skip_lines: /#/)
oldcsv = CSV.read(oldmod, col_sep:" ", converters: :numeric, skip_lines: /#/)
angonecsv = CSV.read(newmotl, col_sep:",", converters: :numeric, skip_lines: /#|CCC/)
angtwocsv = CSV.read(oldmotl, col_sep:",", converters: :numeric, skip_lines: /#|CCC/)

modset = modcsv.to_set
oldset = oldcsv.to_set
angonearr = []
angtwoarr = []
distarr = []
anglearr = []
yarr = []

angonecsv.each do |el|
	angonearr.append([el[16],el[17],el[18]])
end

angtwocsv.each do |el|
	angtwoarr.append([el[16],el[17],el[18]])
end

##measure distance to all points and save distance
##measure angular distance between closest points
modset.each_with_index do |el, i|
	magn = 12
	delta = 361
	yaxis = 0
	p=rotate_pnt(angonearr[i])
	r=rotate_pnt(angonearr[i], [0,1,0])
	oldset.each_with_index do |le, j|
		if (el[1]-le[1]).abs <= 12 && dist_3d(el, le) <= magn
			magn = dist_3d(el, le)
			q = rotate_pnt(angtwoarr[j])
			s = rotate_pnt(angtwoarr[j], [0,1,0])
			delta = angle_3d(p,q)
			yaxis = angle_3d(r,s)
		end
	end
	distarr[i] = magn
	anglearr[i] = delta
	yarr[i] = yaxis
end



avgdist = distarr.sum / distarr.size
sumdist = distarr.sum(0.0) { |i| (i - avgdist)**2 }
vardist = sumdist / (distarr.size - 1) 
diststd = Math.sqrt (vardist)
distthr = 0
distarr.each_with_index do |i, j|
	if i <= 2.0 && anglearr[j] <= 3 && yarr[i] >= 177
		distthr = distthr + 1
	end
end

angthr = 0
anglearr.each do |i|
        if i <= 5
                angthr = angthr + 1
        end
end

puts avgdist
puts anglearr.min
puts anglearr.max
puts distthr
