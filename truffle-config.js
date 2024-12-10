/**
 * Truffle configuration file.
 */
const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config(); // For environment variables like MNEMONIC and INFURA_PROJECT_ID

module.exports = {
  networks: {
    // Local development network (Ganache)
    development: {
      host: "127.0.0.1", // Localhost
      port: 7545, // Ganache default port
      network_id: "*", // Match any network ID
    },

    // Goerli testnet configuration (uncomment and configure as needed)
    // goerli: {
    //   provider: () => new HDWalletProvider(
    //     process.env.MNEMONIC,
    //     `https://goerli.infura.io/v3/${process.env.INFURA_PROJECT_ID}`
    //   ),
    //   network_id: 5,       // Goerli's network ID
    //   confirmations: 2,    // Wait for 2 confirmations
    //   timeoutBlocks: 200,  // Wait up to 200 blocks for deployment
    //   skipDryRun: true     // Skip dry run before migrations
    // },

    // Add more networks as required
  },

  mocha: {
    // Configure Mocha testing framework
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "0.8.24", // Match the Solidity version used in your contract
      settings: {
        optimizer: {
          enabled: true, // Enable optimization
          runs: 200, // Optimize for how many times the code will run
        },
        evmVersion: "istanbul", // Use the Istanbul EVM version (default for Solidity 0.8.x)
      },
    },
  },

  db: {
    enabled: false, // Truffle DB disabled by default
  },
};
