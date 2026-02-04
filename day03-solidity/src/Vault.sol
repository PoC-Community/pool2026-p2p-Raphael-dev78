// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    IERC20 public immutable ASSET;
    uint256 public totalAssets;
    uint256 public totalShares;
    mapping(address => uint256) public balances;

    constructor(IERC20 asset_) {
        ASSET = asset_;
    }

    function convertToShares(uint256 assets) external view returns (uint256) {
        if (totalShares == 0) {
            return assets;
        }

        return (assets * totalShares) / totalAssets;
    }

    function convertToAssets(uint256 shares) external view returns (uint256) {
        if (totalShares == 0) {
            return shares;
        }

        return (shares * totalAssets) / totalShares;
    }
}
