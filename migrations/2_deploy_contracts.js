const MultiWarehouseInventory = artifacts.require("MultiWarehouseInventory");

module.exports = function (deployer) {
  deployer.deploy(MultiWarehouseInventory);
};
