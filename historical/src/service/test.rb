require 'Photos.rb'
require 'pp'


test = Photos.new([])
pp test.getDirList();
puts '------------------------------'
pp test.getDirList('Pictures');
