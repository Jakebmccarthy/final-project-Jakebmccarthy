var SimpleStorage = artifacts.require("./SimpleStorage.sol");
var OnlineMarketplace = artifacts.require("./onlineMarketplace")
var SafeMath = artifacts.require("./SafeMath")

module.exports = function(deployer) {
  deployer.deploy(SimpleStorage);
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, OnlineMarketplace);
  deployer.deploy(OnlineMarketplace);
};
