require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.7.3",
    networks: {
        hardhat: {
            forking: {
                url: "https://parity0.mainnet.makerfoundation.com:8545",
                blockNumber: 12734848,
            },
        },
    },
};
