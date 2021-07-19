const {assert } = require("chai");

describe("Becoming Rich", function () {
    let target = "0x45a10F35BeFa4aB841c77860204b133118B7CcAE";
    let daiAddress = "0x6b175474e89094c44da98b954eedeac495271d0f";
    let oneMillion = ethers.constants.WeiPerEther.mul("1000000");

    let dai;

    beforeEach(async () => {
        dai = await ethers.getContractAt("IERC20", daiAddress);
    });

    it("Impersonating account", async function () {
        let whale = "0x9f5990d880e1089D4Df0E63362184FD9148cDda0";

        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [whale],
        });

        const signer = await ethers.getSigner(whale);

        await dai.connect(signer).transfer(target, oneMillion.add("1"));

        let balance = await dai.balanceOf(target);
        assert.isTrue(balance.gt(oneMillion));
    });

    it("Changing the balance storage slot ", async () => {
        //the storage location is the hash of the padded string of the key(target address) + storage location of "balanceOf" variable on Dai code
        let storageKey = "0x00000000000000000000000045a10f35befa4ab841c77860204b133118b7ccae0000000000000000000000000000000000000000000000000000000000000005";
        let hash = ethers.utils.keccak256(storageKey);
        await network.provider.send("hardhat_setStorageAt", [daiAddress, hash, "0x00000000000000000000000000000000000000000000d3c229af83a148640000"]);

        let balance = await dai.balanceOf(target);
        assert.isTrue(balance.gt(oneMillion));
    });
});
