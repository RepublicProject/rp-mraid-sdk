var callbacks = {};
var urlIdMap = {};

function RPModalKit(){
}

RPModalKit.prototype.pushUrl = function(urlMessage, callback) {
    var id = (new Date()).getTime();
	var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("pushURL", id);
    this.setURLWithId(urlMessage, id);
    
    if (typeof callback === 'function') {
        this.registerCallback(callback, id);
    }
};

RPModalKit.prototype.openUrl = function(urlMessage, callback) {
	var id = (new Date()).getTime();
    var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("openURL", id);
    this.setURLWithId(urlMessage, id);
    
    if (typeof callback === 'function') {
        this.registerCallback(callback, id);
    }
};

RPModalKit.prototype.showVideoPlayer = function(urlMessage, callback) {
	var id = (new Date()).getTime();
    var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("showVideoPlayer", id);
    this.setURLWithId(urlMessage, id);
    
    if (typeof callback === 'function') {
        this.registerCallback(callback, id);
    }
};

RPModalKit.prototype.storePicture = function(urlMessage, callback) {
	var id = (new Date()).getTime();
    var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("storePicture", id);
    this.setURLWithId(urlMessage, id);
    
    if (typeof callback === 'function') {
        this.registerCallback(callback, id);
    }
};

RPModalKit.prototype.setURLWithId = function(urlMessage, id) {
	urlIdMap[id] = urlMessage;
}

RPModalKit.prototype.registerCallback = function(callback, id) {
    callbacks[id] = callback;
}

// Public methods

RPModalKit.getURLWithId = function(id) {
    var returnedURLMessage = urlIdMap[id];
    urlIdMap[id] = null;
    return JSON.stringify(returnedURLMessage);
}

RPModalKit.callCallbackWithId = function(id, status) {
    var returnedCallback = callbacks[id];
		if (typeof returnedCallback === 'function') {
	    returnedCallback(status);
	    callbacks[id] = null;	
		}
}