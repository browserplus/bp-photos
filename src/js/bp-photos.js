(function() {
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

})();
