#!/usr/bin/env ruby 

alias bp_require require 

require 'pp'

class Trans
  def complete(x) 
    puts "complete called: "
    pp x
  end
end

require 'iphoto.rb'
require 'pp'

test = IPhotoInstance.new([])
test.Albums(Trans.new, {});
