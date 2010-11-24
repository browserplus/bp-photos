(function() {
    var Dom = YAHOO.util.Dom,
        Event = YAHOO.util.Event;

    var panel = new YAHOO.widget.Panel('browser', {
        fixedcenter: true,
        draggable: false,
        visible: true,
        close: false,
        height: '305px',
        width: '500px'
    });
    panel.setHeader('Photo Browser');
    panel.render(document.body);
    
    var lastPath = [''];

    Event.on('file_list_cont', 'click', function(e) {
        var tar = Event.getTarget(e);
        var path = tar.innerHTML.replace('/', '');
        if (Dom.hasClass(tar, 'folder')) {
            lastPath.push(path);
            path = lastPath.join('/');
            BrowserPlus.Photos.getLocalFolders({
                path: path,
                callback: function(data) {
                    fillBody(data);
                }
            }, function(x){ });
        }
    });

    var formatDate = function(str) {
        var date = new Date(parseInt(str));
        date = date.getMonth() + '/'+ date.getDate() +'/' + date.getFullYear();
        return date;
    }

    var fillBody = function(data) {
        //console.log(data);
        var str = '', counter = 0;
        for (var i = 0; i < data.dirs.length; i++) {
            var className = ((counter % 2) ? ' class="even"' : '')
            str += '<tr'+className+'><td class="folder">' + data.dirs[i].name + '/</td><td>' + formatDate(data.dirs[i].mtime) + '</td><td class="last">' + data.dirs[i].size + '</td></tr>';
            counter++;
        }
        for (var i = 0; i < data.pics.length; i++) {
            var className = ((counter % 2) ? ' class="even"' : '')
            str += '<tr'+className+'><td class="image">' + data.pics[i].name + '</td><td>' + formatDate(data.pics[i].mtime) + '</td><td class="last">' + data.pics[i].size + '</td></tr>';
            counter++;
        }
        var tb = YAHOO.util.Dom.get('file_list').getElementsByTagName('tbody')[0];
        tb.innerHTML = str;
    }


    BrowserPlus.init(function(res) {  
        if (res.success) {
            BrowserPlus.require({
                services: [
                    {
                        service: "Photos",
                        version: "0",
                        minversion: "0.0.1"
                    }
                ]
            }, function(r) {
                if (r.success) {
                    BrowserPlus.Photos.getLocalFolders({
                        callback: function(data) {
                            fillBody(data);
                        }
                    }, function(x){ });
                } else {
                    alert('BP-Photos failed to load..');
                }
            });
        } else {
            alert('Browser Plus failed to load...');
        }
    });

})();
