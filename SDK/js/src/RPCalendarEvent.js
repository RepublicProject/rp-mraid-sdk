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