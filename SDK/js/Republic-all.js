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
function RPCalendarEvent(){
    this.startDate;
    this.endDate;
    this.allDay;
    this.title;
    this.timezone;
    this.location;
    this.notes;
    this.url;
}

RPCalendarEvent.prototype.setDate = function(startDate, endDate) {
    this.startDate = startDate;
    this.endDate = endDate;
};

RPCalendarEvent.prototype.getEvent = function() {
    return this;
};
var callbacks = {};

function RPCalendarEventKit(){

}

RPCalendarEventKit.prototype.newEvent = function() {
    var newEvent = new RPCalendarEvent();

    return newEvent;
};

RPCalendarEventKit.prototype.addEventToUserCalendar = function(event, callback) {
    var id = (new Date()).getTime();
    var nativeBridge = new NativeBridge();
		nativeBridge.callNativeMethodWithParameter("addEventToUserCalendar", id);
    RPCalendarEventKit.setEventWithId(event, id);
    
    if (typeof callback === 'function') {
        this.registerCalllback(callback, id);
    }
};

RPCalendarEventKit.eventIdMap = {};


RPCalendarEventKit.prototype.registerCalllback = function(callback, id) {
    callbacks[id] = callback;
}


RPCalendarEventKit.setEventWithId = function(event, id) {
    RPCalendarEventKit.eventIdMap[id] = event;
}

RPCalendarEventKit.getEventWithId = function(id) {
    var returnedEvent = RPCalendarEventKit.eventIdMap[id];
    RPCalendarEventKit.eventIdMap[id] = null;
    return JSON.stringify(returnedEvent);
}

RPCalendarEventKit.callCallbackWithId = function(id, status) {
    var returnedCallback = callbacks[id];
		if (typeof returnedCallback === 'function') {
	    returnedCallback(status);
	    callbacks[id] = null;	
		}
}
function NativeBridge(){
}

NativeBridge.prototype.callNativeMethod = function(methodName) {
	window.location = "objc: " + methodName;	
};

NativeBridge.prototype.callNativeMethodWithParameter = function(methodName, parameter) {
	window.location = "objc: " + methodName + "&" + parameter;	
};
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
function RPShareableMessage(){
    this.message;
    this.shortMessage;
    this.imageUrl;
    this.url;
    this.appId;
}
function RPURLMessage(){
    this.url;
}
(function() {
 var mraid = window.mraid = {};

 var STATES = mraid.STATES = {
   LOADING: 'loading',
   DEFAULT: 'default',
   EXPANDED: 'expanded',
   RESIZED: 'resized',
   HIDDEN: 'hidden'
 };

 var state = STATES.LOADING;

 var PLACEMENT_TYPES = mraid.PLACEMENT_TYPES = {
   UNKNOWN: 'unknown',
   INLINE: 'inline',
   INTERSTITIAL: 'interstitial'
 };
 
 var CUSTOM_CLOSE_POSITIONS = ["top-left", "top-right", "center", "bottom-left", "bottom-right", "top-center", "bottom-center"];

 var placementType = PLACEMENT_TYPES.UNKNOWN;

 var supportedFeatures = {};

 var expandProperties = {
   width: -1,
   height: -1,
   useCustomClose: false,
   isModal: true
 };
 
 var ORIENTATIONS = mraid.ORIENTATIONS = {
	 portrait: 'portrait',
	 landscape: 'landscape',
	 none: 'none'
 };
 
 var orientationProperties = {
	 allowOrientationChange: true,
	 forceOrientation: ORIENTATIONS.none
 };
 
 var resizeProperties = undefined;

 var size = { 
	 width: -1,
   height: -1
 };

 var fireEvent = function(eventListeners, message, action) {
	 for (var id in eventListeners) {
		 eventListeners[id].apply(mraid, [message, action]);
	 }
 };
 
 var createRPCallback = function(message, action) {
	 return function(status) {
		 if(!status) {
			 fireEvent(mraid.listeners.error, message, action);
		 }
	 }
 };
 
 var isBoolean = function(value) {
	 return (value === true || value === false);
 };

 mraid.supports = function(featureName) {
 	 var supports = supportedFeatures[featureName];
	 if (supports === undefined) {
		 return false;
	 }
	 return supports;
 };

 mraid.getState = function() {
	 return state;
 };

 mraid.getVersion = function() {
	 return "2.0";
 };

 mraid.getPlacementType = function() {
	 return placementType;
 };

 mraid.resetEventListeners = function() {
	 this.listeners = {
		 ready: [],
		 error: [],
		 stateChange: [],
		 viewableChange: [],
		 sizeChange: []
 	 };
 };

 mraid.resetEventListeners();

 mraid.addEventListener = function(event, listener) {
	 if (!this.listeners[event]) {
		 throw "Event " + event + " is not supported";
	 }

	 if (typeof listener !== 'function') {
		 throw "Listener must be a function";
	 }

	 this.listeners[event].push(listener);
 };

 mraid.removeEventListener = function(event, listener) {
	 if (!this.listeners[event]) {
		 throw "Event " + event + " is not supported";
	 }

	 if (!listener) {
		 this.listeners[event] = [];
		 return;
	 }

	 if (typeof listener !== 'function') {
		 throw "Listener must be a function";
	 }

	 var listeners = this.listeners[event];
	 var index = listeners.indexOf(listener);
	 if (index !== -1) {
		 listeners.splice(index, 1);
	 }
 };

 mraid.open = function(url) {
	 var message = new RPURLMessage();
	 message.url = url;

	 var modalKit = new RPModalKit();
	 modalKit.pushUrl(message, createRPCallback("Error when opening URL. Check if it is correct.", "open"));
 };

 mraid.playVideo = function(url) {
	 var message = new RPURLMessage();
	 message.url = url;

	 var modalKit = new RPModalKit();
	 modalKit.showVideoPlayer(message, createRPCallback("Error when playing video. Check if the URL is correct.", "playVideo"));
 };

 mraid.createCalendarEvent = function(parameters) {
   var calendarKit = new RPCalendarEventKit();
   var newEvent = calendarKit.newEvent();

	 var startDate = Date.parse(parameters.start);
	 if (startDate) {
		 newEvent.startDate = new Date(startDate);
	 }

	 var endDate = Date.parse(parameters.end);
	 if (endDate) {
		 newEvent.endDate = new Date(endDate);
	 }

   newEvent.title = parameters.description;
   newEvent.location = parameters.location;
   newEvent.notes = parameters.summary;
	 newEvent.alert = parameters.reminder;

   calendarKit.addEventToUserCalendar(newEvent, createRPCallback("Error when creating calendar event.", "createCalendarEvent"));
 };
 
 mraid.storePicture = function(url) {
	 var message = new RPURLMessage();
	 message.url = url;

	 var modalKit = new RPModalKit();
	 modalKit.storePicture(message, createRPCallback("Error when storing picture. Check if the URL is correct.", "storePicture"));
 }

 mraid.useCustomClose = function(shouldUseCustomClose) {
	 var rp = new RP();
	 rp.useCustomClose(shouldUseCustomClose);
	 expandProperties.useCustomClose = shouldUseCustomClose;
 };

 mraid.close = function() {
	 var rp = new RP();
	 rp.close(function(status) {
	 	 if (!status) {
			 fireEvent(mraid.listeners.error, "Error when closing the ad", "close");
	 	 } else {
			 if (state === STATES.EXPANDED) {
				 state = STATES.DEFAULT;
			 } else {
				 state = STATES.HIDDEN;
			 	 RP.onViewableChange(false);
			 }
			 fireEvent(mraid.listeners.stateChange, state);
	 	 }
	 });
 };

 mraid.expand = function(url) {
	 if (state === STATES.EXPANDED) {
			fireEvent(mraid.listeners.error, "Error when expanding the ad. Check if the ad is not already expanded.", "expand");
			return;
	 }

	 if (placementType === PLACEMENT_TYPES.INTERSTITIAL) {
			fireEvent(mraid.listeners.error, "Error when expanding the ad. Check if the ad isn't an interstitial ad.", "expand");
			return;
	 }

	 var rp = new RP();
	 rp.expand(url, expandProperties);
	 state = STATES.EXPANDED;
	 fireEvent(mraid.listeners.stateChange, state);
 };
 
 mraid.setExpandProperties = function(properties) {
	 if (properties.useCustomClose === undefined || !isBoolean(properties.useCustomClose)) {
		fireEvent(mraid.listeners.error, "Error when setting expand properties. Check if the properties are valid.", "setExpandProperties");
		return;
	 }
	 expandProperties.width = properties.width ? properties.width : -1;
	 expandProperties.height = properties.height ? properties.height : -1;
	 expandProperties.useCustomClose = properties.useCustomClose;
 };

 mraid.getExpandProperties = function() {
   var properties = {
     width: expandProperties.width == -1 ? size.width : expandProperties.width,
     height: expandProperties.height == -1 ? size.width : expandProperties.height,
     useCustomClose: expandProperties.useCustomClose,
     isModal: expandProperties.isModal
   };
   return properties;
 };
 
 mraid.getSize = function() {
	return {height: size.height, width: size.width};
 };
 
 mraid.getScreenSize = function() {
	return RP.getScreenSize();
 };

 mraid.getMaxSize = function() {
	 return RP.getMaxSize();
 };
 
 mraid.getCurrentPosition = function() {
	 return RP.getCurrentPosition();
 };
 
 mraid.getDefaultPosition = function() {
	 return RP.getDefaultPosition();
 };
 
 mraid.isViewable = function() {
	 return RP.isViewable();
 }

 mraid.getOrientationProperties = function() {
	 var properties = {
		 allowOrientationChange: orientationProperties.allowOrientationChange,
	 	 forceOrientation: orientationProperties.forceOrientation
	 };
	 return properties;
 };
 
 mraid.setOrientationProperties = function(properties) {
	 var forceOrientation = ORIENTATIONS[properties.forceOrientation];
	 var allowOrientationChange = properties.allowOrientationChange;
	 if (!forceOrientation || !isBoolean(allowOrientationChange)) {
 		fireEvent(mraid.listeners.error, "Error when setting orientation properties. Check if the properties are valid.", "setOrientationProperties");
 		return;
	 }
	 
	 orientationProperties.allowOrientationChange = allowOrientationChange;
	 orientationProperties.forceOrientation = forceOrientation;
	 
	 var rp = new RP();
	 rp.changeOrientationProperties(orientationProperties);
 };

 mraid.setResizeProperties = function(properties) {
	 if (!properties) {
		 resizeProperties = undefined;
		 return;
	 }
	 
	 if (!properties.height || !properties.width) {
		fireEvent(mraid.listeners.error, "Error when setting resize properties. Check if the properties are valid.", "setResizeProperties");
		return;
	 }
	 
	 var index = CUSTOM_CLOSE_POSITIONS.indexOf(properties.customClosePosition);
	 if (index < 0) {
		 properties.customClosePosition = "top-right";
	 }
	 
	 resizeProperties =  {
		 width: properties.width,
		 height: properties.height,
		 customClosePosition: properties.customClosePosition,
		 offsetX: properties.offsetX || 0,
		 offsetY: properties.offsetY || 0,
		 allowOffscreen: properties.allowOffscreen == undefined ? true : properties.allowOffscreen
	 };
 };

 mraid.getResizeProperties = function() {
	 if (!resizeProperties) {
		 return undefined;
	 }
	 
	 var properties =  {
		 width: resizeProperties.width,
		 height: resizeProperties.height,
		 customClosePosition: resizeProperties.customClosePosition,
		 offsetX: resizeProperties.offsetX,
		 offsetY: resizeProperties.offsetY,
		 allowOffscreen: resizeProperties.allowOffscreen
	 };
	 
	 return properties;
 };
 
 mraid.resize = function() {
	 if (!resizeProperties) {
			fireEvent(mraid.listeners.error, "Error when resizing the ad. Check if the resize properties are set.", "resize");
			return;
	 }
	 
	 if (state === STATES.EXPANDED) {
			fireEvent(mraid.listeners.error, "Error when resizing the ad. Check if the ad is not expanded.", "resize");
			return;
	 }

	 var rp = new RP();
	 rp.resize(resizeProperties);
	 state = STATES.RESIZED;
	 fireEvent(mraid.listeners.stateChange, state);
 };

 var initialize = function() {
	 var rp = new RP();
	 rp.initSDK(function(initData) {
		 if (!initData) {
			 fireEvent(mraid.listeners.error, "Error when initializing Republic SDK", "init");
			 return;
		 }
		 placementType = initData.placementType;
		 supportedFeatures = initData.deviceFeatures;
		 if (!initData.state) {
			 state = STATES.DEFAULT;
			 fireEvent(mraid.listeners.stateChange, state);
		 } else {
			 state = initData.state;
		 }

		 fireEvent(mraid.listeners.ready, "Republic SDK initialized with success", "init");
	 });
 };

 RP.onStateChange = function(newState) {
	 state = newState;
	 fireEvent(mraid.listeners.stateChange, state);
 };
 
 RP.onSizeChange = function(newSize) {
	 size.width = newSize.width;
	 size.height = newSize.height;
	 fireEvent(mraid.listeners.sizeChange, newSize.width, newSize.height);
 };
 
 RP.onViewableChange = function(viewable) {
	 if (RP.isViewable() != viewable) {
		 RP.setViewable(viewable);
		 fireEvent(mraid.listeners.viewableChange, viewable);
	 }
 }

 document.addEventListener('DOMContentLoaded', function () {
	 initialize();
 });

})();
