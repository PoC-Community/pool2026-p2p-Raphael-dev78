// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Vault is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable ASSET;
    uint256 public constant MAX_FEE = 1000;
    uint256 public withdrawalFeeBps;
    address public governor;
    uint256 public totalShares;
    mapping(address => uint256) public balances;

    error ZeroAmount();
    error InsufficientShares();
    error ZeroShares();
    error OnlyGovernor();
    error FeeTooHigh();

    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Withdraw(address indexed user, uint256 assets, uint256 shares);
    event RewardAdded(uint256 amount);
    event WithdrawalFeeUpdated(uint256 oldFee, uint256 newFee);
    event GovernorUpdated(address indexed oldGovernor, address indexed newGovernor);

    constructor(IERC20 asset_) Ownable(msg.sender) {
        ASSET = asset_;
        governor = msg.sender;
        emit GovernorUpdated(address(0), msg.sender);
    }

    modifier onlyGovernor() {
        _onlyGovernor();
        _;
    }

    function _onlyGovernor() internal view {
        if (msg.sender != governor) {
            revert OnlyGovernor();
        }
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
        uint256 fee = (assets * withdrawalFeeBps) / 10_000;
        uint256 assetsAfterFee = assets - fee;

        balances[msg.sender] -= shares;
        totalShares -= shares;

        ASSET.safeTransfer(msg.sender, assetsAfterFee);

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

    function setGovernor(address newGovernor) external onlyOwner {
        address oldGovernor = governor;
        governor = newGovernor;
        emit GovernorUpdated(oldGovernor, newGovernor);
    }

    function setWithdrawalFee(uint256 newFeeBps) external onlyGovernor {
        if (newFeeBps > MAX_FEE) {
            revert FeeTooHigh();
        }

        uint256 oldFee = withdrawalFeeBps;
        withdrawalFeeBps = newFeeBps;
        emit WithdrawalFeeUpdated(oldFee, newFeeBps);
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
