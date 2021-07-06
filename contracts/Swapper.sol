//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

interface IAsset {
    // solhint-disable-previous-line no-empty-blocks
}
interface IVault{

    enum PoolSpecialization { GENERAL, MINIMAL_SWAP_INFO, TWO_TOKEN }
    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    function getPool(bytes32 poolId) external returns (address, PoolSpecialization);

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external payable returns (uint256);

    /**
     * @dev Data for a single swap executed by `swap`. `amount` is either `amountIn` or `amountOut` depending on
     * the `kind` value.
     *
     * `assetIn` and `assetOut` are either token addresses, or the IAsset sentinel value for ETH (the zero address).
     * Note that Pools never interact with ETH directly: it will be wrapped to or unwrapped from WETH by the Vault.
     *
     * The `userData` field is ignored by the Vault, but forwarded to the Pool in the `onSwap` hook, and may be
     * used to extend swap behavior.
     */
    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IAsset assetIn;
        IAsset assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }


    /**
     * @dev Emitted for each individual swap performed by `swap` or `batchSwap`.
     */
    event Swap(
        bytes32 indexed poolId,
        IERC20 indexed tokenIn,
        IERC20 indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

}

contract Swapper {

  function doBalancerSwap() public payable {
        (address pool, ) = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8).getPool(0x5aa90c7362ea46b3cbfbd7f01ea5ca69c98fef1c000200000000000000000020);
        IVault.FundManagement memory funds = IVault.FundManagement(address(this), false, payable(address(this)), false);
        IVault.SingleSwap memory swap = IVault.SingleSwap(0x5aa90c7362ea46b3cbfbd7f01ea5ca69c98fef1c000200000000000000000020,IVault.SwapKind.GIVEN_IN,IAsset(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2),IAsset(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984), 1 ether, bytes(""));
        IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8).swap(swap,funds, 10 ether, block.timestamp + 1);
    }

}

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}
