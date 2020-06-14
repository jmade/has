
const PLUGIN_NAME = "MadeCam"

var Accessory, hap, UUIDGen;
var FFMPEG = require('./ffmpeg').FFMPEG;

module.exports = function(homebridge) {
  Accessory = homebridge.platformAccessory;

  hap = homebridge.hap;
  UUIDGen = homebridge.hap.uuid;

  homebridge.registerPlatform("homebridge-MadeCam", PLUGIN_NAME, ffmpegPlatform, true);
}

function ffmpegPlatform(log, config, api) {
  var self = this;

  self.log = log;
  self.config = config || {};

  if (api) {
    self.api = api;

    if (api.version < 2.1) {
      throw new Error("Unexpected API version.");
    }

    self.api.on('didFinishLaunching', self.didFinishLaunching.bind(this));
  }
}

ffmpegPlatform.prototype.configureAccessory = function(accessory) {
  // Won't be invoked
  console.log("THIS SHOULD NEVER PRINT!")
  self.log("THIS SHOULD NEVER PRINT!")
  
}

ffmpegPlatform.prototype.didFinishLaunching = function() {
  var self = this;

  self.log("Finished Launching")
  if (self.config.cameras) {
    var configuredAccessories = [];

    var cameras = self.config.cameras;
    cameras.forEach(function(cameraConfig) {
      var cameraName = cameraConfig.name;
      var videoConfig = cameraConfig.videoConfig;

      if (!cameraName || !videoConfig) {
        self.log("Missing parameters.");
        return;
      }

      var uuid = UUIDGen.generate(cameraName);
      var cameraAccessory = new Accessory(cameraName, uuid, hap.Accessory.Categories.CAMERA);
      var cameraSource = new FFMPEG(hap, videoConfig);

      cameraAccessory.getService(hap.Service.AccessoryInformation)
      // cameraAccessory.setCharacteristic(hap.Characteristic.Manufacturer, "Madewell Industries")
      // cameraAccessory.setCharacteristic(hap.Characteristic.Model, "Wyze v2")
      // cameraAccessory.setCharacteristic(hap.Characteristic.SerialNumber, "74514E1B08C2")
      // cameraAccessory.setCharacteristic(hap.Characteristic.FirmwareRevision, "0.0.3");

      cameraAccessory.on("identify", function (paired, callback) {
        self.log("identify");
        callback();
      });

      cameraAccessory.configureCameraSource(cameraSource);
      configuredAccessories.push(cameraAccessory);
    });

    self.api.publishCameraAccessories(PLUGIN_NAME, configuredAccessories);
  }
}
