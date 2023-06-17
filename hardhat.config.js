require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');

const { privateKey } = require("./pp.json");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  networks: {
    shibuya: {
      url: "https://evm.shibuya.astar.network",
      chainId: 81,
      accounts: [privateKey],
    },

    astar: {
      url: "https://evm.astar.network",
      chainId: 592,
      accounts: [privateKey],
    },

    shiden: {
      url: "https://evm.shiden.astar.network",
      chainId: 336,
      accounts: [privateKey],
    },
  },
};
