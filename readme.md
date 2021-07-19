# A hacky way to get rich!

This is a small repo showcasing how you can make use of hardhat's mainnet forking feature to artificially become a millionaire.

You can find the examples on [`test/gettingRich.js`](test/gettingRich.js) To run it, do it:
```bash
npm install
```
and then execute the test cases with:
```bash
npx hardhat test
```


### Impersonating accounts

One of the simpler methods is to just take ownership of an account that have a few extra DAI in it's wallet and send it to your desired address. Noticed though, that this same address needs to have a little bit of eth as well to pay for gas!

If this account does not have any eth, you can either send them a little bit with:

```javascript
signers = await ethers.getSigners()
//sending 1 eth
await signers[0].sendTransaction({to:desiredAddress, value: ethers.constants.WeiPerEther})
```

Or you can just create some new ETH into existence with another hardhat method:

```javascript
await network.provider.send("hardhat_setBalance", [
  desiredAddress,
  "0x1000",
]);
```

### Changing the storage slot of your address on DAI

This method uses another feature of hardhat that is the ability to change a contract's specific storage slot with:

```javascritp
// This will set the contract's first storage position (at index 0x0) to 1.
await network.provider.send("hardhat_setStorageAt", [
  "0x0d2026b3EE6eC71FC6746ADb6311F6d3Ba1C000B",
  "0x0",
  "0x0000000000000000000000000000000000000000000000000000000000000001",
]);
```
To make us a millionaire though, we need to figure it out what's the exact storage location that we want to modify. For this, we need to know a few things. First, how is the storage in the existing DAI address: 

```javascript
contract Dai is LibNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) external note auth { wards[guy] = 1; }
    function deny(address guy) external note auth { wards[guy] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "Dai/not-authorized");
        _;
    }

    // --- ERC20 Data ---
    string  public constant name     = "Dai Stablecoin";
    string  public constant symbol   = "DAI";
    string  public constant version  = "1";
    uint8   public constant decimals = 18;
    uint256 public totalSupply;

    mapping (address => uint)                      public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    mapping (address => uint)                      public nonces;

    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);

    ...
}
```
User's balances are located in the `balanceOf` mapping, which maps an address to a uint, therefore the slot we need to change is `balanceOf[targetAddress]`. Taking a look at the [solidity's storage layout rules](https://docs.soliditylang.org/en/v0.8.6/internals/layout_in_storage.html) we can figure it out how to calculate the exact location.

According to the rules, for a mapping at slot `p`:
> The value corresponding to a mapping key k is located at keccak256(h(k) . p) where . is concatenation and h is a function that is applied to the key depending on its type

Our key is an `address` of value `0x45a10f35befa4ab841c77860204b133118b7ccae` and the we need to have it padded to 32 bytes(that's what the `h` function does), giving us the string `00000000000000000000000045a10f35befa4ab841c77860204b133118b7ccae`

Our `p` value is `5`, since the `balanceOf` mapping is on the 5th index(`name` is on index `0`, `symbol` is on `1`, etc...). We once again need to pad the uint value to 32bytes, getting the string `0000000000000000000000000000000000000000000000000000000000000005`

Finally, to get the storage position, we just need to hash the concatenation of both strings:
```javascript
let storageKey = ethers.utils.keccak256(0x00000000000000000000000045a10f35befa4ab841c77860204b133118b7ccae0000000000000000000000000000000000000000000000000000000000000005)
```

Done! Now we just need to call the hardhat helper to change our balance to the desired value, just remember that it needs to be encoded in hexadecimal.


### Other Methods

There are other ways to get yourself a million Dai that are not showcased here. Here are a few ideas:

1. Mint dai, using the eth given to the default signers. For this, you would need to interact with Maker's smart contracts, by creating an account proxy, locking eth as collateral and the minting dai.

2. Buy on uniswap, or any other on-chain dex. Here you'll take the ETH you start with and the just exchange for DAI. Depending on the protocol you use, you might need to convert your ETH into WETH!