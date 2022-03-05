##csv_relion_transpose.rb

require 'csv'

##method to normalize an array
class Array
  def normalize!
    xMin,xMax = self.minmax
    dx = (xMax-xMin).to_f
    self.map! {|x| (x-xMin) / dx }
  end
end

if ARGV.length == 3
	motlfile = ARGV[0]
	modfile = ARGV[1]
	cccfile = ARGV[2]
end	

ARGV.clear

motlcsv = CSV.read(motlfile, converters: :numeric, skip_lines: /C|#/)
modcsv = CSV.read(modfile, col_sep:",", converters: :numeric, skip_lines: /#/)
ccccsv = CSV.read(cccfile, col_sep:" ", converters: :numeric, skip_lines: /#/)

cccfilein = []

ccccsv.each do |i|
        cccfilein.append(i[0])
end

mean = cccfilein.sum(0.0) / cccfilein.size
sum = cccfilein.sum(0.0) { |el| (el -mean) ** 2 }
variance = sum / (cccfilein.size - 1)
stddev = Math.sqrt(variance)
mincc = mean - (stddev * 2)
maxcc = mean + (stddev * 2)

cccfilein.each do |el|
        el = mincc if el < mincc
        el = maxcc if el > maxcc
end

cccfilein.normalize!

motlcsv.each_with_index do |el, i|
	el[0] = cccfilein[i]
	el[7] = modcsv[i][0]
	el[8] = modcsv[i][1]
	el[9] = modcsv[i][2]
end

mtpose = motlcsv.transpose
	
mtpose.map! { |i| i.join(",") }

newfile = motlfile.gsub("\.csv", "_po\.csv")
File.open(newfile, "w+") do |i|
	i.puts(mtpose)
end
