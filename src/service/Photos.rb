require 'find'
require 'tmpdir'
require 'Pathname'
require 'pp'
 

class Photos
    
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

        data = { 'name' => name, 'fullpath' => entry, 'size' => File.size(entry), 'mtime' => File.stat(entry).mtime }
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



