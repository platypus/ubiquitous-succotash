##geo_filter.rb

require 'csv'
require 'matrix'

def eul2mat (ang)
	angle = ang.map { |i| (i.to_f/180)*Math::PI }
	z1mat = Matrix.rows([[Math.cos(angle[0]),-Math.sin(angle[0]),0],[Math.sin(angle[0]),Math.cos(angle[0]),0],[0,0,1]]) 
	xmat = Matrix.rows([[1,0,0],[0,Math.cos(angle[1]),-Math.sin(angle[1])],[0,Math.sin(angle[1]),Math.cos(angle[1])]])
	z2mat = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]) 
	rotmat = z1mat*xmat*z2mat   
     	return rotmat
end

def transpose_eul (ang)
        rotmat = eul2mat(ang)
	transmat = rotmat.transpose()
	return transmat
end

##calculate the distance between two 3D points
def dist_3d (pt1, pt2)
	Math.sqrt((pt1[0]-pt2[0])**2+(pt1[1]-pt2[1])**2+(pt1[2]-pt2[2])**2)
end

start = Time.now

if ARGV.length == 1
	file = ARGV[0]
end	

ARGV.clear

data = CSV.read(file, converters: :numeric, skip_lines: /#/)

angle=[]
modpt=[]

data.each do |el|
        angle.append([el[16],el[17],el[18]])
	modpt.append([el[7],el[8],el[9]])
end

##measure distance to all points and save distance to nearest eight
disteight=[]
keeppts=[]
modpt.each_with_index do |el, i|
	tempdist = []
	(i+1..modpt.length-1).each do |j|
		if (el[1]-modpt[j][1]).abs <= 128 && dist_3d(el, modpt[j]) <= 128
			magn = dist_3d(el, modpt[j]) 
			p=eul2mat(angle[i])
			q=transpose_eul(angle[j])
			r = p*q
			theta = Math.acos((r.trace()-1)/2)
			thetad = (180/Math::PI)*theta
			tempdist.append([magn, thetad])
		end
	end
	tempdist.reject! { |i| i.nil? }
	disteight[i] = tempdist.sort_by { |el| el[1] }
	if disteight[i][2].nil?
		keeppts[i]=1
	elsif disteight[i][2][1] < 30
		keeppts[i]=0
	else
		keeppts[i]=1
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

finish = Time.now
deltat = finish-start
puts deltat
