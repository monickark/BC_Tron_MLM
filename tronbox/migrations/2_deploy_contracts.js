var SmartGenie = artifacts.require("./SmartGenie.sol");

module.exports = function(deployer,network, accounts) {
  console.log(accounts);
  deployer.deploy(SmartGenie, "THfq1VXP4hyLfkG35dL3sjeomC5UHA2zVb", "THfq1VXP4hyLfkG35dL3sjeomC5UHA2zVb");
  // deployer.deploy(SmartGenie);
};
