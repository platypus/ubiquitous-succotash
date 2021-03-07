##remove_pts.rb

require 'csv'

if ARGV.length == 1
	oldmod = ARGV[0]
end

##get filename from user and remove trailing whitespace
#puts "Model:"
#oldmod = gets.chomp!

oldcsv = CSV.read(oldmod, col_sep:" ", converters: :integer, skip_lines: /#/)

oldcsv.reject!.each do |i|
(i[0]+i[1]+i[2])%9 != 0
end

oldcsv.map! { |i| i.join("\t") }

newmodfile = oldmod.gsub("PtsAdded\.txt", "trim\.txt")
File.open(newmodfile, "w+") do |i|
	i.puts(oldcsv)
end


