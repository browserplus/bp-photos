bp_require 'plist'
require 'set'
require 'pathname'
require 'uri'

def extractImage(albumData, id) 
  wantFields = Set.new ["MediaType", "Caption",
                        "ImagePath", "ThumbPath"].freeze
  pathFields = Set.new ["ImagePath", "ThumbPath"].freeze
  
  img = albumData['Master Image List'][id]
  img = img.delete_if{|k2,v2| ! wantFields.include? k2 }
  img.each{ |k,v| img[k] = Pathname.new(img[k]) if pathFields.include? k }
  
  img
end

class IPhotoInstance
  @@db = nil
  @@albums = nil
  @@parserThread = nil
  @@noLibFound = false

  def initialize(args)
    # start parsing at init time
    if @@parserThread == nil && !@@noLibFound && @@db == nil
      IPhotoInstance.startParsing
    end
  end

  def waitForParsing
    if @@parserThread != nil
      @@parserThread.join
      @@parserThread = nil
    end
    if @@noLibFound
      raise "couldn't locate itunes library XML file"
    end
  end

  def Albums(trans, args) 
    waitForParsing
    trans.complete(@@albums)
  end

  def IPhotoInstance.startParsing
    @@parserThread = Thread.new {

      paths = [ "#{ENV['HOME']}/Pictures/iPhoto Library/AlbumData.xml" ]               
      path = nil
      paths.each { |x| path = x if File.exists? x }

      if !File.exists? path
        @@noLibFound = true
        return
      end

      # this may take a while
      r = Plist::parse_xml(path)

      # first let's print out albums
      @@db = Hash.new
      r["List of Albums"].each{ |x|
        next if x['AlbumName'] == "Photos"
        @@db[x['AlbumName']] = {
          :id => "Album_" + x['AlbumId'].to_s,
          :media => [],
          :key => nil
        }

        x["KeyList"].each { |k|
          @@db[x['AlbumName']][:key] = extractImage(r, k) if @@db[x['AlbumName']][:key] == nil    
          @@db[x['AlbumName']][:media].push(extractImage(r, k))
        }
      }

      r["List of Rolls"].each{ |x|
        rn = x['RollName']
        @@db[rn] = {
          :id => "Roll_" + x['RollID'].to_s,
          :media => [],
          :key => extractImage(r, x['KeyPhotoKey'])
        }

        x["KeyList"].each { |k|
          @@db[rn][:media].push(extractImage(r, k))
        }
      }
      # now build up @@albums
      @@albums = Hash.new
      @@db.each { |k,v|
        @@albums[k] =  {
          "id" => v[:id],
          "key" => v[:key]
        }
      }
    }
  end
end

rubyCoreletDefinition = {
  'class' => "IPhotoInstance",
  'name' => "iPhotoLibrary",
  'major_version' => 1,
  'minor_version' => 0,  
  'micro_version' => 0,  
  'documentation' => "XXX",
  'functions' =>
  [
   {
     'name' => 'Albums',
     'documentation' => "attain a list of available photo albums.",
     'arguments' => [ ]
   }
  ]
}
