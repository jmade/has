var Accessory
var Service
var Characteristic
const http = require('http');


module.exports = function(homebridge) {
    Service = homebridge.hap.Service;
    Characteristic = homebridge.hap.Characteristic;
    homebridge.registerAccessory("homebridge-tv", "Television", Television);
};


function Television(log, config) {
  this.log = log;
  this.name = config.name;

  this.enabledServices = [];
  this.isOn = false;

  // info service
  this.informationService = new Service.AccessoryInformation();

  this.informationService
      .setCharacteristic(Characteristic.Manufacturer, "Madewell Industires")
      .setCharacteristic(Characteristic.Model, config.model || "M:TV-0001")
      .setCharacteristic(Characteristic.SerialNumber, config.serial || "DFB56975A9AC")
      .setCharacteristic(Characteristic.FirmwareRevision, "1.0.1");

  this.tvService = new Service.Television(this.name, "Television");

  this.tvService.setCharacteristic(Characteristic.ConfiguredName, this.name);



  this.tvService
    .getCharacteristic(Characteristic.Active)
    .on("set", this.setPowerState.bind(this));

  this.tvService
    .getCharacteristic(Characteristic.ActiveIdentifier)
    .on("set", this.setInput.bind(this));

  this.tvService.setCharacteristic(Characteristic.ActiveIdentifier, 1);

  this.tvService
    .getCharacteristic(Characteristic.RemoteKey)
    .on('set', function(newValue, callback) {
      console.log("set Remote Key => setNewValue: " + newValue);
      callback(null);
    });

  this.tvService
    .getCharacteristic(Characteristic.PowerModeSelection)
    .on('set', function(newValue, callback) {
      console.log("set PowerModeSelection => setNewValue: " + newValue);
      callback(null);
    });


  this.tvService
    .getCharacteristic(Characteristic.PictureMode)
    .on('set', function(newValue, callback) {
      console.log("set PictureMode => setNewValue: " + newValue);
      callback(null);
    });


  // Speaker
  // var speakerService = new Service.TelevisionSpeaker();

  // speakerService
  //   .setCharacteristic(Characteristic.Active, Characteristic.Active.ACTIVE)
  //   .setCharacteristic(Characteristic.VolumeControlType, Characteristic.VolumeControlType.ABSOLUTE);

  // speakerService.getCharacteristic(Characteristic.VolumeSelector)
  //   .on('set', function(newValue, callback) {
  //     console.log("set VolumeSelector => setNewValue: " + newValue);
  //     callback(null);
  //   });


  //this.tvService.addService(Service.TelevisionSpeaker);

  // Input Services

  this.inputHDMI1Service = createInputSource("hdmi1", "HDMI 1", 1);
  this.inputAppleTVService = createInputSource("atv", "AppleTV", 2);
  this.inputNintendoSwitchService = createInputSource("switch", "Nintendo Switch", 3);
  this.inputPlaystation4Service = createInputSource("ps4", "Playstation 4", 4);

  // this.remoteKeyService = createInputSource("ps4", "Playstation 4", 4, Characteristic.InputSourceType.HDMI);

  this.tvService.addLinkedService(this.inputHDMI1Service);
  this.tvService.addLinkedService(this.inputAppleTVService);
  this.tvService.addLinkedService(this.inputNintendoSwitchService);
  this.tvService.addLinkedService(this.inputPlaystation4Service);


  //this.enabledServices.push(speakerService);
  this.enabledServices.push(this.informationService);
  this.enabledServices.push(this.tvService);
  this.enabledServices.push(this.inputHDMI1Service);
  this.enabledServices.push(this.inputAppleTVService);
  this.enabledServices.push(this.inputNintendoSwitchService);
  this.enabledServices.push(this.inputPlaystation4Service);
}






//set input
Television.prototype.setInput = function(newValue, callback) {
  this.log("Set Input: ",newValue)
  var logboy = this.log
  if (newValue == 1)
        makeTVCall('hdmi1',logboy,callback);
        logboy("HDMI 1");
  if (newValue == 2)
        makeTVCall('atv',logboy,callback);
        logboy("HDMI 1");
  if (newValue == 3)
        makeTVCall('switch',logboy,callback);
        logboy("Nintendo Switch");
  if (newValue == 4)
        makeTVCall('ps4',logboy,callback);
        logboy("PS4");
}

//set power status
Television.prototype.setPowerState = function(state, callback) {
  this.log(this.powerOn)
  this.log("PowerState:", state);
  if (state) {
    //exec(this.oncmd);
    this.log("TV ON");
    var logger = this.log
    makeTVCall('powerOn',logger,callback);
  } else {
    //exec(this.offcmd);
    this.log("TV OFF");
    var logger = this.log
    makeTVCall('powerOff',logger,callback);
    };
  }
;


// getPowerState
Television.prototype.getPowerState = function(state, callback) {

  var logger = this.log
  makeTVCall('state',logger,callback);
};



Television.prototype.getServices = function() {
  return this.enabledServices;
};



function makeTVCall(endpoint,logboy,callback) {

  http.get( ('http://192.168.1.8:8080/tv/'+endpoint) , (resp) => {
    let data = '';

    // A chunk of data has been recieved.
    resp.on('data', (chunk) => {
      data += chunk;
    });

    // The whole response has been received. Print out the result.
    resp.on('end', () => {
      var parsed = JSON.parse(data);
      logboy(parsed);
      if (endpoint == 'state') {
        logboy(parsed.state);
        callback(null,parsed.state);
      } else {
        callback();
      }
      
    });
  }).on("error", (err) => {
    logboy(err);
    callback();
  });

}


//make the input
function createInputSource(id,name,number,type = Characteristic.InputSourceType.HDMI) {
  var input = new Service.InputSource(id, name);

  input
    .setCharacteristic(Characteristic.Identifier, number)
    .setCharacteristic(Characteristic.ConfiguredName, name)
    .setCharacteristic(
      Characteristic.IsConfigured,
      Characteristic.IsConfigured.CONFIGURED
    )
    .setCharacteristic(Characteristic.InputSourceType, type);
  return input;
}


