##nav2csv.rb

require 'csv'
require 'Matrix'
require 'nokogiri'

##initialize variables
ptsMat = []
minX = 1.0
minY = 1.0
maxX = 1.0
maxY = 1.0
ptsXa = []
ptsYa = []
ptsDraw = []

##get file from command line
file = ARGV[0]
ARGV.clear

##parse file with nokogiri
doc = File.open(file) { |f| Nokogiri::XML(f) }

##get elements from item one 
map = doc.at_xpath("//MapID").text
mat = doc.at_xpath("//MapScaleMat").text.split(" ")
mapX = doc.at_xpath("//PtsX").text.split(" ")
mapY = doc.at_xpath("//PtsY").text.split(" ")

#remove extra point from PtsX and PtsY and convert to float
mapX.pop
mapY.pop
mat.map! { |i| i.to_f }
mapX.map! { |i| i.to_f }
mapY.map! { |i| i.to_f }

##convert mat to matrix
scale = Matrix.rows([[mat[0],mat[1]],[mat[2],mat[3]]])

##convert points into matrices
mapX.each_with_index do |el, i|
   ptsMat[i] = Matrix.column_vector([el,mapY[i]])
end	

##get new pt values
corners = ptsMat.map { |i| scale*i }

##convert to array
corners.map! { |i| [i[0,0].to_f,i[1,0].to_f] }

##find maxX and maxY
corners.each do |i|
   minX = [minX,i[0]].min
   minY = [minY,i[1]].min 
   maxX = [maxX,i[0]].max
   maxY = [maxY,i[1]].max
end

##get points drawn on item one
#ptsX = doc.xpath("//Item[DrawnID = #{map}]/PtsX")
#ptsY = doc.xpath("//Item[DrawnID = #{map}]/PtsY")
ptsX = doc.xpath("//Item/PtsX")
ptsY = doc.xpath("//Item/PtsY")

##get item names
items = doc.xpath("//Item/attribute::name")

##convert points to float array, remove extra point if present
for i in 0..ptsX.length-1
   ptsXa[i] = ptsX[i].text.split(" ").map { |i| i.to_f }
   ptsYa[i] = ptsY[i].text.split(" ").map { |i| i.to_f }
   if ptsXa[i].length > 1
      ptsXa[i].pop
      ptsYa[i].pop
   end
end

##find centroid of pts
ptsXa.map! { |i| i.sum/i.length }
ptsYa.map! { |i| i.sum/i.length }

##convert points into matrices
ptsXa.each_with_index do |el, i|
   ptsDraw[i] = Matrix.column_vector([el,ptsYa[i]])
end	

##get new pt values
centers = ptsDraw.map { |i| scale*i }
centers.map! { |i| [(i[0,0]-minX).round,(i[1,0]-minY).round] }

##add item name to center points
centers.each_with_index do |el, i|
el.append(items[i].text)
end

##prepare array for printing
centers.map! { |i| i.join("\t") }

##print file
File.write("nav2csv_result_three.csv", centers.join("\n"))

puts "The End."