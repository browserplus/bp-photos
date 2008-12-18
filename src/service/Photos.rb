require 'find'
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

    def getPhotos()
        mainList = {}
        Find.find(@path) do |entry|
            # May need to enhance this match ;)
            if File.file?(entry) and entry.match(/.jpg|.jpeg|.png|.gif|.bmp/i)
                filename = entry.sub(@path, '')
                if filename[0, 1] == @slash
                    file = filename[1, filename.length]
                end
                tmp = file.split(@slash)
                name = tmp[tmp.length - 1]
                #Remove .files from the list
                if name[0, 1] != '.'
                    len = tmp.length - 1
                    if len == 0
                        #Only one file, no loop
                        #@list['_pics'].push(_getFileInfo(entry))
                    else
                        if not @list[tmp[0]]
                            @list[tmp[0]] = {
                                '_pics' => []
                            }
                        end
                        spot = @list
                        lastSpot = spot[tmp[0]]
                        for i in 1..(len - 1)
                            if not lastSpot[tmp[i]]
                                lastSpot[tmp[i]] = {
                                    '_pics' => []
                                }
                                lastSpot = lastSpot[tmp[i]]
                            end
                        end
                        lastSpot['_pics'].push(_getFileInfo(entry))
                        pp spot
                    end
                    #puts file
                    #puts tmp
                    #puts name
                end
            end
        end
        pp @list
    end
end



