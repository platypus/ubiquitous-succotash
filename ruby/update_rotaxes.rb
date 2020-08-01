#update_rotaxes.rb

require 'csv'
require 'Matrix'

puts "File name:"
file = gets.chomp!

puts "Angle (X,Y,Z):"
angle = gets.split(%r{,\s*}).map(&:to_f)

angle.map! { |i| (i/180)*Math::PI }

rotz = Matrix.rows([[Math.cos(angle[2]),-Math.sin(angle[2]),0],[Math.sin(angle[2]),Math.cos(angle[2]),0],[0,0,1]]) 
roty = Matrix.rows([[Math.cos(angle[1]),0,Math.sin(angle[1])],[0,1,0],[-Math.sin(angle[1]),0,Math.cos(angle[1])]])
rotx = Matrix.rows([[1,0,0],[0,Math.cos(angle[0]),-Math.sin(angle[0])],[0,Math.sin(angle[0]),Math.cos(angle[0])]])

data = CSV.read(file, converters: :float)

data.map! { |i|

xyz = Matrix.column_vector(i)

temp = (rotx*roty*rotz*xyz).map { |n| n.truncate(5) }
i = [temp[0,0],temp[1,0],temp[2,0]].join(",")

}

newfile = file.gsub("\.csv", "_ruby\.csv")
File.write(newfile, data.join("\n"))
