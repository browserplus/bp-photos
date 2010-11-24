#!/usr/bin/env ruby 

alias bp_require require 

require 'pp'

class Trans
  def complete(x) 
    puts "complete called: "
    pp x
  end
end

require 'photos.rb'
require 'pp'

test = PhotosInstance.new([])
test.Albums(Trans.new, {});
puts "\nalbum\n"
test.Photos(Trans.new, {"album"=>"Album_999001"});
puts "\nalbum 5,1\n"
test.Photos(Trans.new, {"album"=>"Album_999001","startResult"=>5,"maxResults"=>1});
