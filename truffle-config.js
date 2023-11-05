require('dotenv').config();
var HDWalletProvider = require("@truffle/hdwallet-provider");
 
const privateKey = process.env.PRIVATE_KEY;
const infuraKey =  process.env.INFURA_PROJECT_ID;
 
module.exports = {
  /**
  * Networks define how you connect to your ethereum client and let you set the
  * defaults web3 uses to send transactions. If you don't specify one truffle
  * will spin up a development blockchain for you on port 9545 when you
  * run `develop` or `test`. You can ask a truffle command to use a specific
  * network from the command line, e.g
  *
  * $ truffle test --network <network-name>
  */
 
  networks: {
  // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    rinkeby: {
      provider: () => new HDWalletProvider(privateKey, 'https://rinkeby.infura.io/v3/'+infuraKey),
      network_id: 4,       // Rinkeby's id
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    goerli: {
      provider: () => new HDWalletProvider(privateKey, 'https://goerli.infura.io/v3/'+infuraKey),
      network_id: 5,       // Ropsten's id
      gas: 8000000,       // Ropsten has a lower block limit than mainnet
      gasPrice: 200000000000,
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    sepolia:{
      provider: () => new HDWalletProvider(privateKey, 'https://sepolia.infura.io/v3/' + infuraKey),
      network_id: 11155111,       // Ropsten's id
      gas: 8000000,       // Ropsten has a lower block limit than mainnet
      gasPrice: 30000000000,
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true 
    },
    ropsten: {
      provider: () => new HDWalletProvider(privateKey, 'https://ropsten.infura.io/v3/'+infuraKey),
      network_id: 3,       // Ropsten's id
      // gas: 7000000,       // Ropsten has a lower block limit than mainnet
      // gasPrice: 20000000000,
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    mumbai: {
      provider: () => new HDWalletProvider(privateKey, "rpc url here"),
      network_id: 80001,       // mumbai's id
      gas: 8000000,       // mumbai has a lower block limit than mainnet
      gasPrice: 30000000000,
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    supernet: {
      provider: () => new HDWalletProvider(privateKey, `http://localhost:10001`),
      network_id: 100,       // mumbai's id
      gas: 8000000,       // mumbai has a lower block limit than mainnet
      gasPrice: 30000000000,
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    
    mainnet: {
      provider: () => new HDWalletProvider(privateKey, 'https://mainnet.infura.io/v3/'+infuraKey),
      network_id: 1,       // mainnet's id
      gas: 8000000,        // block limit
      gasPrice: 20000000000, //20 gewi 
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
    polygon: {
      provider: () => new HDWalletProvider(privateKey, `https://polygon-mainnet.infura.io/v3/`+infuraKey),
      network_id: 137,       // mumbai's id
      gas: 8000000,        // block limit
      gasPrice: 100000000000, // 100 gewi
      confirmations: 2,    // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200,  // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true     // Skip dry run before migrations? (default: false for public nets )
    },
  },
 
  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },
 
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.17",       // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  },
  plugins: [
    'truffle-plugin-verify',
    'truffle-contract-size'
  ],
  api_keys: {
    etherscan: process.env.ETHERSCAN_KEY,
    polygonscan: process.env.POLYGONSCAN_KEY
  }, 
 
  db: {
    enabled: false
  }
};
