##clean_motive.rb

require 'csv'

##generates array +/- 1 for point
##converts array back to csv
##checks old model for any points in array
def rounding_error(point, modcsv)
   rounding = Array.new(27, point)
   rounding.map!.each_with_index do |el, i|
      a = el[0].to_i + ((i / 9.5).to_i) - 1
      b = el[1].to_i + ((i / 3.1).to_i % 3) - 1
      c = el[2].to_i + (i % 3) - 1
      el = [a,b,c].join(",")
   end
   roundcsv = CSV.parse(rounding.join("\n"), converters: :integer)
   roundcsv.each do |i|
     return true if modcsv.include?(i)
   end
   return false
end 


if ARGV.length == 5
   newmod = ARGV[0]
   oldmod = ARGV[1]
   motfile = ARGV[2]
   rotfile = ARGV[3]
   sumfile = ARGV[4]
end

puts motfile
ARGV.clear

##get filename from user and remove trailing whitespace
#puts "New model:"
#newmod = gets.chomp!

#puts "Original model:"
#oldmod = gets.chomp!

#puts "MotiveList:"
#motfile = gets.chomp! 

#puts "RotAxes:"
#rotfile = gets.chomp 

#puts "Summary:"
#sumfile = gets.chomp!

modcsv = CSV.read(newmod, col_sep:" ", converters: :integer, skip_lines: /#/)
oldcsv = CSV.read(oldmod, col_sep:" ", converters: :integer, skip_lines: /#/)

keeppts = []
oldcsv.each do |i|
   if modcsv.include?(i)
      keeppts.append(1)
   elsif rounding_error(i, modcsv) 
      keeppts.append(1)
   else
      keeppts.append(0)
   end
end

motfilein = File.readlines(motfile)
motfilein.reject!.each_with_index do |el, i|
i > 0 && keeppts[i-1] == 0
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

if modcsv.length != (motfilein.length - 1)
   abort("Something broke!")
end

rotfilein = File.readlines(rotfile)
rotfilein.reject!.each_with_index do |el, i|
keeppts[i] == 0
end

sumfilein = File.readlines(sumfile)
sumfilein.reject!.each_with_index do |el, i|
i > 0 && keeppts[i-1] == 0
end

newmotfile = motfile.gsub("\.csv", "_clean\.csv")
File.open(newmotfile, "w+") do |i|
	i.puts(motfilein)
end

newrotfile = rotfile.gsub("\.csv", "_clean\.csv")
File.open(newrotfile, "w+") do |i|
	i.puts(rotfilein)
end

newsumfile = sumfile.gsub("\.csv", "_clean\.csv")
File.open(newsumfile, "w+") do |i|
	i.puts(sumfilein)
end

