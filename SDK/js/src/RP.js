var callbacks = {};
var customCloseIdMap = {};
var expandPropertiesMap = {};
var resizePropertiesMap = {};
var screenSize = {};
var maxSize = {};
var currentPosition = {};
var defaultPosition = {};
var viewable = false;

function RP() {}

RP.prototype.initSDK = function(callback) {
  var id = (new Date()).getTime();
	var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("initSDKForId", id);

  if (typeof callback === 'function') {
		callbacks[id] = callback;
  }
};

RP.prototype.useCustomClose = function(shouldUseCustomClose) {
  var id = (new Date()).getTime();
	var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("useCustomClose", id);

	customCloseIdMap[id] = {useCustomClose: shouldUseCustomClose};
};

RP.prototype.close = function(callback) {
  var id = (new Date()).getTime();
	var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("close", id);

  if (typeof callback === 'function') {
		callbacks[id] = callback;
  }
};

RP.prototype.expand = function(url, expandProperties) {
  var id = (new Date()).getTime();
	var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("expand", id);

	expandProperties.url = url;
	expandPropertiesMap[id] = expandProperties;
};

RP.prototype.resize = function(resizeProperties) {
  var id = (new Date()).getTime();
	var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("resize", id);

	resizePropertiesMap[id] = resizeProperties;
};

RP.prototype.changeOrientationProperties = function(orientationProperties) {
	var nativeBridge = new NativeBridge();
	nativeBridge.callNativeMethodWithParameter("changeOrientationProperties", JSON.stringify(orientationProperties));
};

RP.getScreenSize = function() {
	return screenSize;
};

RP.setScreenSize = function(size) {
	screenSize = size;
};

RP.getMaxSize = function() {
	return maxSize;
};

RP.setMaxSize = function(size) {
	maxSize = size;
};

RP.getCurrentPosition = function() {
	return currentPosition;
}

RP.setCurrentPosition = function(curPos) {
	currentPosition = curPos;
}

RP.getDefaultPosition = function() {
	return defaultPosition;
}

RP.setDefaultPosition = function(defaultPos) {
	defaultPosition = defaultPos;
}

RP.isViewable = function() {
	return viewable;
}

RP.setViewable = function(newViewable) {
	viewable = newViewable;
}

RP.callCallbackWithId = function(id, status) {
    var returnedCallback = callbacks[id];
		if (typeof returnedCallback === 'function') {
	    returnedCallback(status);
	    callbacks[id] = null;
		}
};

RP.getCustomCloseWithId = function(id) {
	var returnedCustomClose = customCloseIdMap[id];
	customCloseIdMap[id] = null;
  return JSON.stringify(returnedCustomClose);
};

RP.getExpandPropertiesWithId = function(id) {
	var expandProperties = expandPropertiesMap[id];
	expandPropertiesMap[id] = null;
  return JSON.stringify(expandProperties);
};

RP.getResizePropertiesWithId = function(id) {
	var resizeProperties = resizePropertiesMap[id];
	resizePropertiesMap[id] = null;
  return JSON.stringify(resizeProperties);
};
