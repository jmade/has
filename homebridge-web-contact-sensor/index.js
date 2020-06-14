var Service;
var Characteristic;
var HomebridgeAPI;
var http = require('http');

module.exports = function(homebridge) {
    Service = homebridge.hap.Service;
    Characteristic = homebridge.hap.Characteristic;
    HomebridgeAPI = homebridge;
    homebridge.registerAccessory("homebridge-web-contact-sensor", "web-contact-sensor", WebContactSensor);
};

function WebContactSensor(log, config) {
    this.log = log;
    this.name = config.name;
    this.port = config.port;

    this.isClosed = true;
    this.bind_ip = config.bind_ip || "0.0.0.0";

    var that = this;
    this.server = http.createServer(function(request, response) {
        that.httpHandler(that,request);
        response.end('Successfully requested: ' + request.url);
    });

    this.informationService = new Service.AccessoryInformation();

    this.informationService
        .setCharacteristic(Characteristic.Manufacturer, "Madewell Technologies")
        .setCharacteristic(Characteristic.Model, config.model || "HK-CTS-01")
        .setCharacteristic(Characteristic.SerialNumber, config.serial || "CTS-A5EC45-061420");

    this.service = new Service.ContactSensor(this.name);

    this.service.getCharacteristic(Characteristic.ContactSensorState)
        .on('get', this.getState.bind(this));

    this.server.listen(this.port, this.bind_ip, function(){
        that.log("Contact Sensor server listening on: http://192.168.1.22:%s", that.port);
    });
}


WebContactSensor.prototype.getState = function(callback) {
    callback(null, this.isClosed);
};


WebContactSensor.prototype.httpHandler = function(that,request) {
    that.isClosed = (request.url == '/doorClosed');
    that.service.getCharacteristic(Characteristic.ContactSensorState)
        .updateValue(that.isClosed, null, "httpHandler");
};

WebContactSensor.prototype.getServices = function() {
    return [this.informationService, this.service];
};
