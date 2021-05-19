const HelloWorld = artifacts.require("DMooze");

module.exports = function (deployer) {
  deployer.deploy(HelloWorld, "DMooze contract deployed");
};
