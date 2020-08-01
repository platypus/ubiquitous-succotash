#!/. ruby

require 'bio'
require 'rexml/document'

   files = []
   Dir.foreach("C:/Users/Bryan/Desktop/ab1/") do |x|
      if x =~ /.ab1\z/ 
          files.push x 
      end
   end

   files.each do |x|
      f = File.open("C:/Users/Bryan/Desktop/ab1/#{x}", "rb")
      chromatogram_ff = Bio::Abif.open(f)
      chromatogram = chromatogram_ff.next_entry
      seq = chromatogram.to_seq
         
      fasta = File.new("_.fsta", "a+")
      fasta.puts seq.output_fasta(definition = "#{x.match(/[^\.]*/)}")
      fasta.close
   end