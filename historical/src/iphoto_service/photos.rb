bp_require 'plist'
require 'set'
require 'pathname'
require 'uri'

def extractImage(albumData, id) 
  # define the fields out of the iphoto xml data that we want, and
  # remap them into the values that our API exposes
  wantFields = {
    "MediaType" => "type",
    "Caption" => "title",
    "ImagePath" => "media",
    "ThumbPath" => "thumbnail"
  };
  pathFields = Set.new ["ImagePath", "ThumbPath"].freeze
  
  img = albumData['Master Image List'][id]
  rv = Hash.new
  img.each{|k,v|
    m = wantFields[k]
    if m != nil
      if pathFields.include? k
        rv[m] = Pathname.new(v)
      else
        rv[m] = v
      end
    end
  }
  rv
end

class PhotosInstance
  @@db = nil
  @@albums = nil
  @@parserThread = nil
  @@noLibFound = false

  def initialize(args)
    # start parsing at init time
    if @@parserThread == nil && !@@noLibFound && @@db == nil
      PhotosInstance.startParsing
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

  def Photos(trans, args) 
    waitForParsing
    album = @@db[args['album']]
    if album == nil
      trans.error('noSuchAlbum',
                  "couldn't find album with id '#{args['album']}'")
    end
    
    photos = nil

    b = ((args['startResult'] == nil) ? 0 : args['startResult'])
    n = ((args['maxResults'] == nil) ? -1 : (b-1) + args['maxResults'])

    puts("b: #{b} e:#{n}")
    photos = album[:media].slice(b..n) if album[:media]

    trans.complete({
                     "start" => b,
                     "total" => album[:media].length,
                     "media" => photos
                   })
  end

  def PhotosInstance.startParsing
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

      @@db = Hash.new
      r["List of Albums"].each{ |x|
        next if x['AlbumName'] == "Photos"
        id = "Album_" + x['AlbumId'].to_s
        @@db[id] = {
          :name => x['AlbumName'],
          :media => [],
          :key => nil
        }

        x["KeyList"].each { |k|
          @@db[id][:key] = extractImage(r, k) if @@db[id][:key] == nil    
          @@db[id][:media].push(extractImage(r, k))
        }
      }

      r["List of Rolls"].each{ |x|
        rn = x['RollName']
        id = "Roll_" + x['RollID'].to_s
        @@db[id] = {
          :name => rn,
          :media => [],
          :key => extractImage(r, x['KeyPhotoKey'])
        }

        x["KeyList"].each { |k|
          @@db[id][:media].push(extractImage(r, k))
        }
      }
      # now build up @@albums
      @@albums = Hash.new
      @@db.each { |k,v|
        @@albums[k] = {
          "name" => v[:name],
          "media" => (v[:key] && (v[:key]["thumbnail"] || v[:key]["media"]))  
        }
      }
    }
  end
end

rubyCoreletDefinition = {
  'class' => "PhotosInstance",
  'name' => "Photos",
  'major_version' => 1,
  'minor_version' => 0,  
  'micro_version' => 0,  
  'documentation' => "Allow websites to access photos on your computer.",
  'functions' =>
  [
   {
     'name' => 'Albums',
     'documentation' => "Attain a list of available logical photo albums from a variety of sources (including eventaully Picasa, iPhoto, and the users \"Pictures\" directory).  An object is returned where attributes are the album name, and values are maps contaning information about the album.",
     'arguments' => [ ]
   },
   {
     'name' => 'Photos',
     'documentation' => "Attain photos from within an album.",
     'arguments' =>
     [
      {
        'name' => 'album',
        'type' => 'string',
        'documentation' => 'The id of the album for which you\'d like to access photos',
        'required' => true
      },
      {
        "name" => "startResult",
        "type" => "integer",
        "documentation" => "The starting offset.",
        "required" => false
      },
      {
        "name" => "maxResults",
        "type" => "integer",
        "documentation" => "The maximum number of results to return.",
        "required" => false
      }

     ]
   }
  ]
}
