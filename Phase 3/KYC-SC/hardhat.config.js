/** @type import('hardhat/config').HardhatUserConfig */

require("@nomiclabs/hardhat-waffle");

const ALCHEMY_API_KEY="VK_DaXCU-JiT0U8bPMpRCqdw11bLuxTr";
const GORELI_PRIVATE_KEY="a5946da123542a4841a34d84adb147f8b59551291338e3344be692d8e85684d6";

module.exports = {
  solidity: "0.8.18",
  networks:
  {
    goreli:
    {
      url: 'https://eth-goerli.g.alchemy.com/v2/{$ALCHEMY_API_KEY}',
      accounts: [`0x${GORELI_PRIVATE_KEY}`],
    }

  }
};


