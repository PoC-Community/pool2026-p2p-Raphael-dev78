// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Vault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable ASSET;
    uint256 public totalShares;
    mapping(address => uint256) public balances;

    error ZeroAmount();
    error InsufficientShares();
    error ZeroShares();

    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);
    event RewardAdded(uint256 amount);

    constructor(IERC20 asset_) Ownable(msg.sender) {
        ASSET = asset_;
    }

    function convertToShares(uint256 assets) external view returns (uint256) {
        return _convertToShares(assets);
    }

    function convertToAssets(uint256 shares) external view returns (uint256) {
        return _convertToAssets(shares);
    }

    function totalAssets() public view returns (uint256) {
        return ASSET.balanceOf(address(this));
    }

    function currentRatio() external view returns (uint256) {
        if (totalShares == 0) {
            return 1e18;
        }

        return (totalAssets() * 1e18) / totalShares;
    }

    function assetOf(address user) external view returns (uint256) {
        return _convertToAssets(balances[user]);
    }

    function previewDeposit(uint256 assets) external view returns (uint256) {
        return _convertToShares(assets);
    }

    function previewWithdraw(uint256 shares) external view returns (uint256) {
        return _convertToAssets(shares);
    }

    function deposit(uint256 assets) external nonReentrant returns (uint256 shares) {
        if (assets == 0) {
            revert ZeroAmount();
        }

        shares = _convertToShares(assets);
        if (shares == 0) {
            revert ZeroShares();
        }

        totalShares += shares;
        balances[msg.sender] += shares;

        ASSET.safeTransferFrom(msg.sender, address(this), assets);

        emit Deposit(msg.sender, assets, shares);
    }

    function withdraw(uint256 shares) public nonReentrant returns (uint256 assets) {
        if (shares == 0) {
            revert ZeroAmount();
        }
        if (balances[msg.sender] < shares) {
            revert InsufficientShares();
        }

        assets = _convertToAssets(shares);

        balances[msg.sender] -= shares;
        totalShares -= shares;

        ASSET.safeTransfer(msg.sender, assets);

        emit Withdraw(msg.sender, assets, shares);
    }

    function addReward(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) {
            revert ZeroAmount();
        }
        if (totalShares == 0) {
            revert ZeroShares();
        }

        ASSET.safeTransferFrom(msg.sender, address(this), amount);

        emit RewardAdded(amount);
    }

    function _convertToShares(uint256 assets) internal view returns (uint256) {
        uint256 assetsInVault = totalAssets();
        if (totalShares == 0 || assetsInVault == 0) {
            return assets;
        }

        return (assets * totalShares) / assetsInVault;
    }

    function _convertToAssets(uint256 shares) internal view returns (uint256) {
        if (totalShares == 0) {
            return shares;
        }
        uint256 assetsInVault = totalAssets();
        if (assetsInVault == 0) {
            return 0;
        }

        return (shares * assetsInVault) / totalShares;
    }
}