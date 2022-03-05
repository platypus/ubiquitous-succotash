##build_motl.rb

require 'csv'

##method to normalize an array
class Array
  def normalize!
    xMin,xMax = self.minmax
    dx = (xMax-xMin).to_f
    self.map! {|x| (x-xMin) / dx }
  end
end

start = Time.now

if ARGV.length == 3
        coordfile = ARGV[0]
        angfile = ARGV[1]
        cccfile = ARGV[2]
end

ARGV.clear

coordcsv = CSV.read(coordfile, col_sep:",", converters: :numeric, skip_lines: /#/)
angcsv = CSV.read(angfile, col_sep:",", converters: :numeric, skip_lines: /#/)
ccccsv = CSV.read(cccfile, col_sep:" ", converters: :numeric, skip_lines: /#/)
header = File.open(angfile, &:readline)

angfilein = []
cccfilein = []
motlfileout = []

ccccsv.each do |i|
        cccfilein.append(i[0])
end

cccfilein.normalize!

angcsv.each_with_index do |el, i|
	el[0]=cccfilein[i]
	el[7]=coordcsv[i][0]
	el[8]=coordcsv[i][1]
	el[9]=coordcsv[i][2]
end

angcsv.map! { |i| i.join(",") }

newmotlfile = coordfile.gsub("\.csv", "_built\.csv")

File.open(newmotlfile, "w+") do |i|
	i.puts(header)
	i.puts(angcsv)
end

finish = Time.now
deltat = finish-start
puts deltat
