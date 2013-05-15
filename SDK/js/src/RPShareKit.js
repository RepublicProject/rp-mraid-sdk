var callbacks = {};
var shareableIdMap = {};

function RPShareKit(){
}

RPShareKit.prototype.shareToFacebook = function(shareableMessage, callback) {
    var id = (new Date()).getTime();
    var nativeBridge = new NativeBridge();
    nativeBridge.callNativeMethodWithParameter("shareToFacebook", id);
    this.setShareableWithId(shareableMessage, id);

    if (typeof callback === 'function') {
        this.registerCallback(callback, id);
    }
};

RPShareKit.prototype.shareToTwitter = function(shareableMessage, callback) {
    var id = (new Date()).getTime();
    var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("shareToTwitter", id);
	this.setShareableWithId(shareableMessage, id);
    
    if (typeof callback === 'function') {
        this.registerCallback(callback, id);
    }
};

RPShareKit.prototype.shareDialog = function(shareableMessage, callback) {
    var id = (new Date()).getTime();
    var nativeBridge = new NativeBridge();
    nativeBridge.callNativeMethodWithParameter("shareDialog", id);
    this.setShareableWithId(shareableMessage, id);

    if (typeof callback === 'function') {
        this.registerCallback(callback, id);
    }
};

RPShareKit.prototype.setShareableWithId = function(shareableMessage, id) {
	shareableIdMap[id] = shareableMessage;
}

RPShareKit.prototype.registerCallback = function(callback, id) {
    callbacks[id] = callback;
}

// Public methods

RPShareKit.getShareableWithId = function(id) {
    var returnedShareableMessage = shareableIdMap[id];
    shareableIdMap[id] = null;
    return JSON.stringify(returnedShareableMessage);
}

RPShareKit.callCallbackWithId = function(id, status) {
    var returnedCallback = callbacks[id];
    returnedCallback(status);

    callbacks[id] = null;
}