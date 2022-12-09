##rotate_motl.rb

require 'csv'

if ARGV.length == 2
   file = ARGV[0].chomp
   puts file
   orange = "#{ARGV[1]},0,0"
   puts orange
   ARGV.clear
else
   puts "File name:"
   file = gets.chomp!
end

#puts "Angle (X,Y,Z):"
angle = orange.split(%r{,\s*}).map(&:to_f)

header = "CCC,reserved,reserved,pIndex,wedgeWT,NA,NA,NA,NA,NA,xOffset,yOffset,zOffset,NA,NA,reserved,EulerZ(1),EulerZ(3),EulerX(2),reserved,CREATED WITH PEET Version 1.14.0 21-Feb-2020"

data = CSV.read(file, converters: :float, skip_lines: /C/)

data.each do |i|
   i[16] = i[16] - angle[0]
   i[17] = i[17] - angle[2]
   i[18] = i[18] - angle[1]
end

data.map! { |i| i.join(",") }

newfile = file.gsub("\.csv", "_ruby\.csv")
File.open(newfile, "w+") do |i|
	i.puts(header)
	i.puts(data)
end
