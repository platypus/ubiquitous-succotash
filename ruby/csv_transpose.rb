##csv_transpose.rb

require 'csv'

if ARGV.length == 2
        motlfile = ARGV[0]
        modfile = ARGV[1]
end

ARGV.clear

motlcsv = CSV.read(motlfile, converters: :numeric, skip_lines: /C|#/)
modcsv = CSV.read(modfile, col_sep:" ", converters: :numeric, skip_lines: /#/)

motlcsv.each_with_index do |el, i|
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
