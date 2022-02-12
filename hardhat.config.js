require("@nomiclabs/hardhat-waffle");
const fs = require("fs");
const projectKey = fs.readFileSync(".secret").toString();
const projectId = "IHZhZpxl7Mu6qsmk_neNIM0iJqutXrnl";

// TODO: At the end of the project, we'll need to move any vulnerable information to a .env file.
// - Chain ID
// - ProjectKey
// - ProjectId
module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${projectId}`,
      accounts: [projectKey],
    },
    mainnet: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${projectId}`,
      accounts: [projectKey],
    },
  },
  solidity: "0.8.4",
};
