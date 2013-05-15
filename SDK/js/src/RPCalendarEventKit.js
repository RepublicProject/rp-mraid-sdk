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