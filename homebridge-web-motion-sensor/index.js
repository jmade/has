var Service;
var Characteristic;
var HomebridgeAPI;
var http = require('http');

module.exports = function(homebridge) {
    Service = homebridge.hap.Service;
    Characteristic = homebridge.hap.Characteristic;
    HomebridgeAPI = homebridge;

    homebridge.registerAccessory("homebridge-web-motion-sensor", "web-motion-sensor", WebMotionSensor);
};

function WebMotionSensor(log, config) {
    this.log = log;
    this.name = config.name;
    this.port = config.port;
    this.motionDetected = false;
    this.bind_ip = config.bind_ip || "0.0.0.0";
    this.repeater = config.repeater || [];

    var that = this;
    this.server = http.createServer(function(request, response) {
        that.httpHandler(that,request);
        response.end('Successfully requested: ' + request.url);
    });

    // info service
    this.informationService = new Service.AccessoryInformation();

    this.informationService
        .setCharacteristic(Characteristic.Manufacturer, "Madewell Industires")
        .setCharacteristic(Characteristic.Model, config.model || "M1-0802")
        .setCharacteristic(Characteristic.SerialNumber, config.serial || "4BD53931-D4A9-4850-8E7D-8A51A842FA29");

    this.service = new Service.MotionSensor(this.name);

    this.service.getCharacteristic(Characteristic.MotionDetected)
        .on('get', this.getState.bind(this));

    this.server.listen(this.port, this.bind_ip, function(){
        that.log("Motion sensor server listening on: http://192.168.0.22:%s", that.port);
    });
}


WebMotionSensor.prototype.getState = function(callback) {
    callback(null, this.motionDetected);
};


WebMotionSensor.prototype.httpHandler = function(that,request) {

    for (var i = 0; i < that.repeater.length; i++) {
        http.get(that.repeater[i], function(res) {
            // one could do something with this information
        });
    }

    that.motionDetected = (request.url == '/motionOn');
    that.service.getCharacteristic(Characteristic.MotionDetected)
        .updateValue(that.motionDetected, null, "httpHandler");

};

WebMotionSensor.prototype.getServices = function() {
    return [this.informationService, this.service];
};
