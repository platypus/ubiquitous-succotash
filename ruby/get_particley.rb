##get_particley.rb

require 'csv'
require 'matrix'

def eul2mat (ang)
	angle = ang.map { |i| (i.to_f/180)*Math::PI }
	z1mat = Matrix.rows([[Math.cos(angle[0]),-Math.sin(angle[0]),0],[Math.sin(angle[0]),Math.cos(angle[0]),0],[0,0,1]]) 
	xmat = Matrix.rows([[1,0,0],[0,Math.cos(angle[2]),-Math.sin(angle[2])],[0,Math.sin(angle[2]),Math.cos(angle[2])]])
	z2mat = Matrix.rows([[Math.cos(angle[1]),-Math.sin(angle[1]),0],[Math.sin(angle[1]),Math.cos(angle[1]),0],[0,0,1]]) 
     	rotmat = z2mat*(xmat*z1mat)
	return rotmat
end

def rotate_pnt (ang, pnt=[0,1,0])
	rotmat = eul2mat(ang)
	temp = rotmat*Matrix.column_vector(pnt)
	i = [temp[0,0],temp[1,0],temp[2,0]]
	return i
end

start = Time.now

if ARGV.length == 1
	file = ARGV[0]
end	

ARGV.clear

data = CSV.read(file, converters: :numeric, skip_lines: /CCC|#/)

angle=[]
particley =[]

data.each do |el|
        angle.append([el[16],el[17],el[18]])
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

angle.each do |el|
	particley.append(rotate_pnt el)
end

particley.map! { |i|
	i = i.join(",")
}

yfile = file.gsub("\.csv", "_Yaxis\.csv")
File.write(yfile, particley.join("\n"))

finish = Time.now
deltat = finish-start
puts deltat
