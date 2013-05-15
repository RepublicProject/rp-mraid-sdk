describe("Republic MRAID SDK", function() {

	describe("getVersion", function() {
		it("Should return MRAID compliant version", function() {
			var version = mraid.getVersion();

			expect(version).toEqual("2.0");
		});
	});

	describe("getState", function() {
		it("Should return current state", function() {
			var state = mraid.getState();

			expect(state).toEqual(mraid.STATES.LOADING);
		});
	});
	
	describe("getSize", function() {
		it("Should return current size", function() {
			var size = mraid.getSize();

			expect(size).toBeDefined();
		});
	});

	describe("getPlacementType", function() {
		it("Should return current placement type", function() {
			var placementType = mraid.getPlacementType();

			expect(placementType).toEqual(mraid.PLACEMENT_TYPES.UNKNOWN);
		});
	});

	describe("supports", function() {
		it("Should indicate if the feature is supported", function() {
			var smsIsSupported = mraid.supports('sms');

			expect(smsIsSupported).toEqual(false);
		});
	});

	describe("open", function() {
		it("Should open URL", function() {

			var mock = jasmine.createSpy('pushUrl');
			RPModalKit.prototype.pushUrl = mock;

			var url = "http://republicproject.com/";

			mraid.open(url);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual({url: url});
		});

		it("Should fire error event when URL is invalid", function() {
			var mock = jasmine.createSpy('error');

			mraid.addEventListener('error', mock);

			RPModalKit.prototype.pushUrl = function(message, callback) {
				callback(false);
			};

			var url = "invalid";

			mraid.open(url);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when opening URL. Check if it is correct.');
	    expect(mock.mostRecentCall.args[1]).toEqual('open');
		});
	});

	describe("addEventListener", function() {

		beforeEach(function() {
			mraid.resetEventListeners();
		});

		it("Should add event listener", function() {

			var event = "ready";
			var listener = function() {console.log("Ready!");};

			mraid.addEventListener(event, listener);

			expect(mraid.listeners['ready'].length).toEqual(1);
			expect(mraid.listeners['ready'][0]).toEqual(listener);
		});

		it("Should add more than one event listener for the same event", function() {

			var event = "ready";
			var listener = function() {console.log("Ready!");};
			var otherListener = function() {console.log("I'm ready too!");};

			mraid.addEventListener(event, listener);
			mraid.addEventListener(event, otherListener);

			expect(mraid.listeners['ready'].length).toEqual(2);
			expect(mraid.listeners['ready'][0]).toEqual(listener);
			expect(mraid.listeners['ready'][1]).toEqual(otherListener);
		});

		it("Should throw if event not supported", function() {

			var addNotSupportedListener = function() {
				var event = "not_supported";
				var listener = function() {console.log("Not supported");};

				mraid.addEventListener(event, listener);
			};

			expect(addNotSupportedListener).toThrow();
		});

		it("Should throw if listener is not a function", function() {
			var addNonFunctionListener = function() {
				var event = "stateChange";
				var listener = "I am not a function";

				mraid.addEventListener(event, listener);
			};

			expect(addNonFunctionListener).toThrow();
		});
	});

	describe("removeEventListener", function() {

		beforeEach(function() {
			mraid.resetEventListeners();

			stateChange = "stateChange";
			stateChangeListener = function() {console.log("State have been changed!");};

			mraid.addEventListener(stateChange, stateChangeListener);

			ready = "ready";
			readyListener = function() {console.log("Ready!");};
			otherReadyListener = function() {console.log("I'm ready too!");};

			mraid.addEventListener(ready, readyListener);
			mraid.addEventListener(ready, otherReadyListener);
		});

		it("Should remove specific listener", function() {
			mraid.removeEventListener(stateChange, stateChangeListener);

			expect(mraid.listeners[stateChange].length).toEqual(0);
			expect(mraid.listeners[ready].length).toEqual(2);
		});

		it("Should remove all listeners if listener is not specified", function() {
			mraid.removeEventListener(ready);

			expect(mraid.listeners[ready].length).toEqual(0);
			expect(mraid.listeners[stateChange].length).toEqual(1);
		});

		it("Should not remove if listener not has been added before", function() {

			mraid.removeEventListener(ready, function() {console.log("I'm not a registered listener.")});

			expect(mraid.listeners[ready].length).toEqual(2);
			expect(mraid.listeners[stateChange].length).toEqual(1);
		});

		it("Should throw if event not supported", function() {

			var removeNotSupportedListener = function() {
				var event = "not_supported";
				var listener = function() {console.log("Not supported");};

				mraid.removeEventListener(event, listener);
			};

			expect(removeNotSupportedListener).toThrow();
		});

		it("Should throw if listener is not a function", function() {
			var removeNonFunctionListener = function() {
				var event = "stateChange";
				var listener = "I am not a function";

				mraid.removeEventListener(event, listener);
			};

			expect(removeNonFunctionListener).toThrow();
		});
	});

	describe("playVideo", function() {
		it("Should play video", function() {
			var mock = jasmine.createSpy('showVideoPlayer');

			RPModalKit.prototype.showVideoPlayer = mock;

			var url = "https://dl.dropbox.com/u/58610109/sampleVideo.avi";

			mraid.playVideo(url);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual({url: url});
		});

		it("Should fire error event when video URL is invalid", function() {
			var mock = jasmine.createSpy('error');

			mraid.addEventListener('error', mock);

			RPModalKit.prototype.showVideoPlayer = function(message, callback) {
				callback(false);
			};

			var url = "invalid";

			mraid.playVideo(url);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when playing video. Check if the URL is correct.');
	    expect(mock.mostRecentCall.args[1]).toEqual('playVideo');
		});
	});

	describe("createCalendarEvent", function() {
		it("Should create an event", function() {
			var mock = jasmine.createSpy('addEventToUserCalendar');

			RPCalendarEventKit.prototype.addEventToUserCalendar = mock;

			var calendarEvent = {
				description: "Mayan Apocalypse/End of World",
				location: "everywhere",
				start: "2012-12-21T00:00-05:00",
				end: "2012-12-22T00:00-05:00"
			};

			mraid.createCalendarEvent(calendarEvent);

			expect(mock).toHaveBeenCalled();
	    expect(mock.mostRecentCall.args[0].title).toEqual(calendarEvent.description);
	    expect(mock.mostRecentCall.args[0].startDate).toEqual(new Date(calendarEvent.start));
	    expect(mock.mostRecentCall.args[0].endDate).toEqual(new Date(calendarEvent.end));
	    expect(mock.mostRecentCall.args[0].location).toEqual(calendarEvent.location);
		});

		it("Should ignore invalid dates", function() {
			var mock = jasmine.createSpy('addEventToUserCalendar');

			RPCalendarEventKit.prototype.addEventToUserCalendar = mock;

			var calendarEvent = {
				description: "Mayan Apocalypse/End of World",
				location: "everywhere",
				start: "now",
				end: "tomorrow"
			};

			mraid.createCalendarEvent(calendarEvent);

			expect(mock).toHaveBeenCalled();
	    expect(mock.mostRecentCall.args[0].title).toEqual(calendarEvent.description);
	    expect(mock.mostRecentCall.args[0].startDate).toBeUndefined();
	    expect(mock.mostRecentCall.args[0].endDate).toBeUndefined();
	    expect(mock.mostRecentCall.args[0].location).toEqual(calendarEvent.location);
		});

		it("Should fire error event when could not create event", function() {
			var mock = jasmine.createSpy('error');

			mraid.addEventListener('error', mock);

			RPCalendarEventKit.prototype.addEventToUserCalendar = function(message, callback) {
				callback(false);
			};

			var calendarEvent = {};

			mraid.createCalendarEvent(calendarEvent);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when creating calendar event.');
	    expect(mock.mostRecentCall.args[1]).toEqual('createCalendarEvent');
		});
	});
	
	describe("getOrientationProperties", function() {
		it("Should return the orientation properties", function() {

			var orientationProperties = mraid.getOrientationProperties();

			expect(orientationProperties.allowOrientationChange).toEqual(true);
			expect(orientationProperties.forceOrientation).toEqual(mraid.ORIENTATIONS.none);
		});		
	});
	
	describe("setOrientationProperties", function() {
		it("Should store the orientation properties", function() {
			var newProperties = {
				allowOrientationChange: false,
				forceOrientation: mraid.ORIENTATIONS.portrait
			};

			var mock = jasmine.createSpy('changeOrientationProperties');
			RP.prototype.changeOrientationProperties = mock;

			mraid.setOrientationProperties(newProperties);
			
			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual(newProperties);
			
			var orientationProperties = mraid.getOrientationProperties();

			expect(orientationProperties.allowOrientationChange).toEqual(false);
			expect(orientationProperties.forceOrientation).toEqual(mraid.ORIENTATIONS.portrait);
		});
		
		it("Should fire error event when invalid forceOrientation is passed", function() {
			var error = jasmine.createSpy('error');
			mraid.addEventListener('error', error);

			var newProperties = {
				allowOrientationChange: false,
				forceOrientation: "upside-down"
			};

			mraid.setOrientationProperties(newProperties);

			expect(error).toHaveBeenCalled();
			expect(error.mostRecentCall.args[0]).toEqual('Error when setting orientation properties. Check if the properties are valid.');
	    expect(error.mostRecentCall.args[1]).toEqual('setOrientationProperties');
		});
		
		it("Should fire error event when invalid allowOrientationChange is passed", function() {
			var error = jasmine.createSpy('error');
			mraid.addEventListener('error', error);

			var newProperties = {
				allowOrientationChange: "false",
				forceOrientation: "none"
			};

			mraid.setOrientationProperties(newProperties);

			expect(error).toHaveBeenCalled();
			expect(error.mostRecentCall.args[0]).toEqual('Error when setting orientation properties. Check if the properties are valid.');
	    expect(error.mostRecentCall.args[1]).toEqual('setOrientationProperties');
		});
		
	});
	
	describe("getExpandProperties", function() {

		it("Should return the expand properties", function() {

			var expandProperties = mraid.getExpandProperties();

			expect(expandProperties.height).toEqual(-1);
			expect(expandProperties.width).toEqual(-1);
			expect(expandProperties.useCustomClose).toEqual(false);
			expect(expandProperties.isModal).toEqual(true);
		});
	});
	
	describe("setExpandProperties", function() {
		it("Should store the expand properties", function() {
			var newProperties = {
				width: 100,
				height: 50,
				useCustomClose: true,
				isModal: false //shoud be ignored
			};

			mraid.setExpandProperties(newProperties);

			var expandProperties = mraid.getExpandProperties();

			expect(expandProperties.width).toEqual(100);
			expect(expandProperties.height).toEqual(50);
			expect(expandProperties.useCustomClose).toEqual(true);
			expect(expandProperties.isModal).toEqual(true);
		});
		
		it("Should fire error event when there is no useCustomClose", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var newProperties = {
				width: 333,
				height: 432
			};

			mraid.setExpandProperties(newProperties);

			var expandProperties = mraid.getExpandProperties();

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when setting expand properties. Check if the properties are valid.');
	    expect(mock.mostRecentCall.args[1]).toEqual('setExpandProperties');

			expect(expandProperties.width).not.toEqual(333);
			expect(expandProperties.height).not.toEqual(432);
		});
		
		it("Should fire error event when invalid useCustomClose", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var newProperties = {
				useCustomClose: "false"
			};

			mraid.setExpandProperties(newProperties);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when setting expand properties. Check if the properties are valid.');
	    expect(mock.mostRecentCall.args[1]).toEqual('setExpandProperties');
		});
		
		it("Should use fullscreen when there is no width", function() {
			var newProperties = {
				height: 432,
				useCustomClose: true
			};

			mraid.setExpandProperties(newProperties);

			var expandProperties = mraid.getExpandProperties();

			expect(expandProperties.width).toEqual(-1);
			expect(expandProperties.height).toEqual(432);
		});
		
		it("Should use fullscreen when there is no height", function() {
			var newProperties = {
				useCustomClose: true
			};

			mraid.setExpandProperties(newProperties);

			var expandProperties = mraid.getExpandProperties();

			expect(expandProperties.width).toEqual(-1);
			expect(expandProperties.height).toEqual(-1);
		});
		
	});
	
	describe("useCustomClose", function() {
		it("Should set use custom close property", function() {

			var mock = jasmine.createSpy('useCustomClose');
			RP.prototype.useCustomClose = mock;

			mraid.useCustomClose(true);

			expect(mock).toHaveBeenCalledWith(true);
		});

		it("Should set expand property", function() {

			var mock = jasmine.createSpy('useCustomClose');
			RP.prototype.useCustomClose = mock;

			var shouldUseCustomClose = true;

			mraid.useCustomClose(shouldUseCustomClose);

			var expandProperties = mraid.getExpandProperties();

			expect(mock).toHaveBeenCalledWith(true);
			expect(expandProperties.useCustomClose).toEqual(shouldUseCustomClose);
		});
	});

	describe("expand", function() {

		afterEach(function() {
			RP.prototype.close = function(callback) {
				callback(true);
			};
			mraid.close();
	  });

		it("Should expand without URL and change the state", function() {
			var mock = jasmine.createSpy('onStateChange');
			mraid.addEventListener('stateChange', mock);

			var expand = jasmine.createSpy('expand');
			RP.prototype.expand = expand;

			mraid.expand();

			expect(expand).toHaveBeenCalled();
			expect(expand.mostRecentCall.args[1]).toEqual(mraid.getExpandProperties());

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual(mraid.STATES.EXPANDED);

			var state = mraid.getState();
			expect(state).toEqual(mraid.STATES.EXPANDED);
		});

		it("Should fire error event when expanding twice", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var expand = jasmine.createSpy('expand');
			RP.prototype.expand = expand;

			mraid.expand();
			mraid.expand();

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when expanding the ad. Check if the ad is not already expanded.');
	    expect(mock.mostRecentCall.args[1]).toEqual('expand');

			var state = mraid.getState();
			expect(state).toEqual(mraid.STATES.EXPANDED);
		});
	});

	describe("getScreenSize", function() {

		it("Should return the screen size", function() {

			var mock = jasmine.createSpy('getScreenSize');
			RP.getScreenSize = mock;

			var screenSize = mraid.getScreenSize();
			expect(mock).toHaveBeenCalled();
		});

	});

	describe("getMaxSize", function() {

		it("Should return the max size", function() {

			var mock = jasmine.createSpy('getMaxSize');
			RP.getMaxSize = mock;

			var maxSize = mraid.getMaxSize();
			expect(mock).toHaveBeenCalled();
		});

	});

	describe("resize", function() {
		beforeEach(function() {
			mraid.setResizeProperties(undefined);
		});

		it("Should fire error event when resizing without resize properties", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var resize = jasmine.createSpy('resize');
			RP.prototype.resize = resize;

			mraid.resize();

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when resizing the ad. Check if the resize properties are set.');
	    expect(mock.mostRecentCall.args[1]).toEqual('resize');
		});


		it("Should resize and change the state", function() {
			var mock = jasmine.createSpy('onStateChange');
			mraid.addEventListener('stateChange', mock);

			var resize = jasmine.createSpy('resize');
			RP.prototype.resize = resize;

			mraid.setResizeProperties({
				width: 250,
				height: 300
			});

			mraid.resize();

			expect(resize).toHaveBeenCalled();
			expect(resize.mostRecentCall.args[0]).toEqual(mraid.getResizeProperties());

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual(mraid.STATES.RESIZED);

			var state = mraid.getState();
			expect(state).toEqual(mraid.STATES.RESIZED);
		});

		it("Should fire error event when resizing after expand", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var expand = jasmine.createSpy('expand');
			RP.prototype.expand = expand;

			var resize = jasmine.createSpy('resize');
			RP.prototype.resize = resize;

			mraid.expand();

			mraid.setResizeProperties({
				width: 250,
				height: 300
			});

			mraid.resize();

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when resizing the ad. Check if the ad is not expanded.');
	    expect(mock.mostRecentCall.args[1]).toEqual('resize');

			var state = mraid.getState();
			expect(state).toEqual(mraid.STATES.EXPANDED);
		});
	});

	describe("getCurrentPosition", function() {

		it("Sould return the current position", function() {

			var mock = jasmine.createSpy('getCurrentPosition');
			RP.getCurrentPosition = mock;

			var currentPosition = mraid.getCurrentPosition();
			expect(mock).toHaveBeenCalled();
		});
	});
	
	describe("getDefaultPosition", function() {
		
		it("Should return the default position", function() {
			
			var mock = jasmine.createSpy('getDefaultPosition');
			RP.getDefaultPosition = mock;
			
			var defaultPosition = mraid.getDefaultPosition();
			expect(mock).toHaveBeenCalled();
		});
	});
	
	describe("isViewable", function() {
	
		it("Should become viewable and fire the corresponding event", function() {
			
			var mock = jasmine.createSpy('onViewableChange');
			mraid.addEventListener('viewableChange', mock);
			
			RP.onViewableChange(true);
			
			expect(mraid.isViewable()).toEqual(true);
			
			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual(true);
		});
		
		it("Should not fire again the event for the same value", function() {
			
			mraid.removeEventListener('viewableChange', mock);
			var mock = jasmine.createSpy('onViewableChange');
			mraid.addEventListener('viewableChange', mock);
			
			RP.onViewableChange(true);
			
			expect(mraid.isViewable()).toEqual(true);
			
			expect(mock).not.toHaveBeenCalled();
		});
	});

	describe("getResizeProperties", function() {
		beforeEach(function() {
			mraid.setResizeProperties(undefined);
		});

		it("Should return undefined when not set", function() {
			var resizeProperties = mraid.getResizeProperties();
			expect(resizeProperties).toBeUndefined();
		});

	});

	describe("setResizeProperties", function() {
		beforeEach(function() {
			mraid.setResizeProperties(undefined);
		});

		it("Should update the resize properties", function() {
			var resizeProperties = {
				width: 250,
				height: 300,
				offsetX: 0,
				offsetY: 0,
				allowOffscreen: false,
				customClosePosition: "center"
			};

			mraid.setResizeProperties(resizeProperties);

			var updatedProperties = mraid.getResizeProperties();

			expect(updatedProperties.width).toEqual(resizeProperties.width);
			expect(updatedProperties.height).toEqual(resizeProperties.height);
			expect(updatedProperties.offsetX).toEqual(resizeProperties.offsetX);
			expect(updatedProperties.offsetY).toEqual(resizeProperties.offsetY);
			expect(updatedProperties.allowOffscreen).toEqual(resizeProperties.allowOffscreen);
			expect(updatedProperties.customClosePosition).toEqual(resizeProperties.customClosePosition);
		});

		it("Should update the resize properties with default values for offset, customClosePosition and allowOffscreen", function() {
			var resizeProperties = {
				width: 250,
				height: 300
			};

			mraid.setResizeProperties(resizeProperties);

			var expected = {
				width: 250,
				height: 300,
				offsetX: 0,
				offsetY: 0,
				allowOffscreen: true,
				customClosePosition: 'top-right'
			};

			expect(mraid.getResizeProperties()).toEqual(expected);
		});

		it("Should fire error when there is no height", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var resizeProperties = {
				width: 250,
				offsetX: 0,
				offsetY: 0,
				allowOffscreen: false
			};

			mraid.setResizeProperties(resizeProperties);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when setting resize properties. Check if the properties are valid.');
	    expect(mock.mostRecentCall.args[1]).toEqual('setResizeProperties');
		});

		it("Should fire error when there is no width", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var resizeProperties = {
				height: 250,
				offsetX: 0,
				offsetY: 0,
				allowOffscreen: false
			};

			mraid.setResizeProperties(resizeProperties);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when setting resize properties. Check if the properties are valid.');
	    	expect(mock.mostRecentCall.args[1]).toEqual('setResizeProperties');
		});

		it("Should fire error when there is no dimensions", function() {
			var mock = jasmine.createSpy('error');
			mraid.addEventListener('error', mock);

			var resizeProperties = {
				offsetX: 0,
				offsetY: 0,
				allowOffscreen: false
			};

			mraid.setResizeProperties(resizeProperties);

			expect(mock).toHaveBeenCalled();
			expect(mock.mostRecentCall.args[0]).toEqual('Error when setting resize properties. Check if the properties are valid.');
	    	expect(mock.mostRecentCall.args[1]).toEqual('setResizeProperties');
		});
	});
});
