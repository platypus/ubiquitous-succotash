##check_rotaxes.rb

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
def translate_3d (angle, pt0)
	angle.map! { |i| (i/180)*Math::PI }
	xyz = Matrix.column_vector(pt0)
	rotz = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]) 
	roty = Matrix.rows([[Math.cos(angle[1]),0,Math.sin(angle[1])],[0,1,0],[-Math.sin(angle[1]),0,Math.cos(angle[1])]])
	rotx = Matrix.rows([[1,0,0],[0,Math.cos(angle[0]),-Math.sin(angle[0])],[0,Math.sin(angle[0]),Math.cos(angle[0])]])
	temp = (rotx*roty*rotz*xyz).map { |n| n.truncate(5) }
	i = [temp[0,0],temp[1,0],temp[2,0]]
	return i
end

if ARGV.length == 3
	file = ARGV[0]
	mofile = ARGV[1]
	rofile = ARGV[2]
end	

ARGV.clear

##get filename from user and remove trailing whitespace
#puts "Summary:"
#file = gets.chomp!

#puts "MotiveList:"
#mofile = gets.chomp!

#puts "RotAxes:"
#rofile = gets.chomp! 

data = CSV.read(file, converters: :float, skip_lines: /#/)

angle = []

modfilein = []
data.each do |i|
	angle.append([i[4],i[5],i[6]])
	modfilein.append([i[1],i[2],i[3]])
end

pt0 = [0,1,0]
particley = []

angle.each do |i|
	particley.append(translate_3d i, pt0)
end	

##find average y-rotaxis
avgang = particley.transpose.map(&:sum) 
avgang.map! { |i| i/particley.length }

##find angle from average
yvariation = []
particley.each do |i|
	yvariation.append(angle_3d i, avgang)
end

avgyvar = yvariation.sum/yvariation.length

keeppts = []
yvariation.each do |i|
	if i < 6.0
		keeppts.append(1)
	else
		keeppts.append(0)
	end
end

##convert particley[] to csv string
particley.map! { |i|
	i = i.join(",")
}

#=begin

motfilein = File.readlines(mofile)
motfilein.reject!.each_with_index do |el, i|
i > 0 && keeppts[i-1] == 0
end

motfilein.map!.each_with_index do |el, i|
   if i > 0 
      arr = el.split(",")
      arr[3] = i.to_s
      el = arr.join(",")
   end
end

rotfilein = File.readlines(rofile)
rotfilein.reject!.each_with_index do |el, i|
keeppts[i] == 0
end

sumfilein = File.readlines(file)
sumfilein.reject!.each_with_index do |el, i|
i > 0 && keeppts[i-1] == 0
end

modfilein.reject!.each_with_index do |el, i|
keeppts[i] == 0
end
modfilein.map! { |i| i.join("\t") }


newmotfile = mofile.gsub("clean_ruby\.csv", "final\.csv")
File.open(newmotfile, "w+") do |i|
	i.puts(motfilein)
end

newrotfile = rofile.gsub("clean_ruby\.csv", "final\.csv")
File.open(newrotfile, "w+") do |i|
	i.puts(rotfilein)
end

newmodfile = file.gsub("Summary_clean_ruby\.csv", "final\.txt")
File.write(newmodfile, modfilein.join("\n"))

newsumfile = file.gsub("clean_ruby\.csv", "final\.csv")
File.open(newsumfile, "w+") do |i|
	i.puts(sumfilein)
end

#yfile = file.gsub("\.csv", "_Yaxis\.csv")
#File.write(yfile, particley.join("\n"))

#=end

puts file
#puts avgyvar
#puts modfilein.length