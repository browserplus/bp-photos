require 'find'
require 'tmpdir'
require 'pathname'
 

class PhotosInstance
    
    def initialize(args)
        @list = {
            '_pics' => []
        }
        # Need to find this path on Windows
        @path = File.expand_path("c:\..\Pictures")
        @slash = '\\'
        @os = 'win' #default to windows
        if RUBY_PLATFORM.downcase.include?("darwin")
            @os = 'mac'
            @path = File.expand_path("~/Pictures/")
            @slash = '/'
        end
    
    end

    def _getFileInfo(entry)
        filename = entry.sub(@path, '')
        if filename[0, 1] == @slash
            file = filename[1, filename.length]
        end
        tmp = file.split(@slash)
        name = tmp[tmp.length - 1]

        stamp = "%10.3f" % File.stat(entry).mtime.to_f
        # Remove the . from the float after turning it into a string
        stamp = stamp.sub(/\./, '')
        
        data = { 'name' => name, 'fullpath' => entry, 'size' => File.size(entry), 'mtime' => stamp }
        return data
    end

    def getLocalFolders(bp, args)
        data = getDirList(args['path'])
        args['callback'].invoke(data)
        return data
    end

    def getDirList(passed = @path)
        path = @path
        if passed and (passed != @path)
            path = "#{@path}#{@slash}#{passed}"
        end
        list = {
            'dirs' => [],
            'pics' => []
        }
        items = Dir.entries(path)
        items.each do |file|
            filePath = "#{path}#{@slash}#{file}"
            if file[0, 1] != '.'
                fileInfo = _getFileInfo(filePath)
                if File.directory?(filePath)
                    list['dirs'].push(fileInfo)
                else
                    if file.match(/.jpg|.jpeg|.png|.gif|.bmp/i)
                        list['pics'].push(fileInfo)
                    end
                end
            end
        end
        return list
    end


end


rubyCoreletDefinition = {
  'class' => "PhotosInstance",
  'name'  => "Photos",
  'major_version' => 0,
  'minor_version' => 0,
  'micro_version' => 1,
  'documentation' => 
  'Plugin returns a list of Photos/Directories available on the end users machine.',
  'functions' =>
  [
    {
      'name' => 'getLocalFolders',
      'documentation' => "Returns an Object of files/directories for the given directory.",
      'arguments' =>
      [
         {
            'name' => 'path',
            'type' => 'string',
            'required' => false,
            'documentation' => 'The path to start at under the default path. Default path is ~/Pictures/'
          },
          {
            'name' => 'callback',
            'type' => 'callback',
            'required' => false,
            'documentation' => 'the callback to send a hello message to'
          }
      ]
    }
  ] 
}

