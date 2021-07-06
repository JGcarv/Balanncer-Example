const { expect } = require("chai");

describe("Greeter", function() {
   it("Should do a balancer swap", async()=> {
     const Swapper = await ethers.getContractFactory("Swapper");
    const swapper = await Swapper.deploy();

    const accounts = await ethers.getSigners();
    let val = ethers.BigNumber.from("20000000000000000000")
    

    await swapper.deployed();
    console.log("swapper Address",swapper.address)

    const weth = await ethers.getContractAt("IWETH","0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")

    let tx0 = await accounts[0].sendTransaction({
      to: weth.address,
      value: val
    });

    await weth.transfer(swapper.address, "14000000000000000000")
    await weth.approve("0xBA12222222228d8Ba445958a75a0704d566BF2C8", "14000000000000000000")
    await swapper.doBalancerSwap()
    assert.isTrue(false)
  })
});
