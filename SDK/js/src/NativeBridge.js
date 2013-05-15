function NativeBridge(){
}

NativeBridge.prototype.callNativeMethod = function(methodName) {
	window.location = "objc: " + methodName;	
};

NativeBridge.prototype.callNativeMethodWithParameter = function(methodName, parameter) {
	window.location = "objc: " + methodName + "&" + parameter;	
};