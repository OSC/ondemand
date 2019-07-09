/* global CloudCmd */
/* global CloudFunc */
/* global DOM */

(function() {
    'use strict';
    
    if (typeof module !== 'undefined' && module.exports)
        module.exports      = uploadDirectory;
    else
        DOM.uploadDirectory = uploadDirectory;
    
    function uploadDirectory(items) {
        var entries,
            Images  = DOM.Images,
            Info    = DOM.CurrentInfo,
            load    = DOM.load,
            Dialog  = DOM.Dialog,
            url     = '',
            array   = [
                'findit',
                'philip'
            ];
        
        if (items.length)
            Images.show('top');
        
        entries     = [].map.call(items, function(item) {
            return item.webkitGetAsEntry();
        });
        
        array = array.map(function(name) {
            var result = [
                '/modules/' + name,
                '/lib/' + name,
                '.js'
            ].join('');
            
            return result;
        });
        
        if (!window.Emitify)
            array.unshift('/modules/emitify/dist/emitify.js');
        
        if (!window.exec)
            array.unshift('/modules/execon/lib/exec.js');
        
        url = CloudCmd.join(array);
        
        load.js(url, function() {
            var path        = Info.dirPath
                .replace(/\/$/, ''),
                
                uploader;
            
            uploader = window.philip(entries, function(type, name, data, i, n, callback) {
                var upload,
                    prefixURL   = CloudCmd.PREFIX_URL,
                    FS          = CloudFunc.FS,
                    full        = prefixURL + FS + path + name;
                
                switch(type) {
                case 'file':
                    // If the file to be uploaded is less than the maximum supported upload size, upload file.
                    // Otherwise, provide an error message and do not upload.
                    // See also DOM.uploadFiles() for simialar behavior on dialog uploads
                    if (data.size < OOD.upload_max) {
                        upload = uploadFile(full, data);
                    } else {
                        var msg = "The file '" + name + "' (" + parseInt(data.size / 1024 / 1024) + "MB) is too large to upload via the web interface. " +
                            "The maximum upload size is " + parseInt(OOD.upload_max / 1024 / 1024) + "MB. Please use SFTP to transfer this file instead.";
                        Dialog.alert("Error", msg);
                        upload = uploadFile("", null);
                    }
                    break;
                
                case 'directory':
                    upload = uploadDir(full);
                    break;
                }
                
                upload.on('end', callback);
                
                upload.on('progress', function(count) {
                    var current = percent(i, n),
                        next    = percent(i + 1, n),
                        max     = next - current,
                        value   = current + percent(count, 100, max);
                    
                    setProgress(value);
                });
            });
            
            uploader.on('error', function(error) {
                Dialog.alert(error);
                uploader.abort();
            });
            
            uploader.on('progress', function(count) {
                setProgress(count);
            });
            
            uploader.on('end', function() {
                CloudCmd.refresh();
            });
        });
    }
    
    function percent(i, n, per) {
        var value;
        
        if (typeof per === 'undefined')
            per = 100;
        
        value = Math.round(i * per / n);
        
        return value;
    }
    
    function setProgress(count) {
        var Images  = DOM.Images;
        
        Images.setProgress(count);
        Images.show('top');
    }
    
    function uploadFile(url, data) {
        return DOM.load.put(url, data);
    }
    
    function uploadDir(url) {
        return DOM.load.put(url + '?dir');
    }
    
})();
