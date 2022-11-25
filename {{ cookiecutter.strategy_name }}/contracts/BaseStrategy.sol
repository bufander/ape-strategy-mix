// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IVault.sol";

/*
    BaseContract to build a strategy for yearn-vaults v3
    Main methods have the same signature than an ERC4626 vault but do not need to comply with ERC4626 spec
    Only depositor allowed is the vault so some function parameters are ignored

    Abstract contract that is intented to be inherited by strategy instances, which only need to implement the internal functions
 */ 
abstract contract BaseStrategy {
    using SafeERC20 for IERC20;
    address public immutable vault;
    address public immutable asset;
    string public name;

    constructor(address _vault, string memory _name) {
        vault = _vault;
        name = _name;
        asset = IVault(vault).asset();
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        // NOTE: strategy reports a price per share of 1 (1 share == 1 unit of asset) because the only depositor will be a vault 
        // 1:1
        return shares;
    }

    function convertToShares(uint256 assets) public view returns (uint256) {
        // NOTE: strategy reports a price per share of 1 (1 share == 1 unit of asset) because the only depositor will be a vault 
        // 1:1
        return assets;
    }

    function totalAssets() public view returns (uint256) {
        return _totalAssets();
    }

    function balanceOf(address owner) public view returns (uint256) {
        // NOTE: the only depositor is the vault, which will own the claim for all the assets in the vault (at a 1.0 price per share)
        if (owner == vault) {
            return _totalAssets();
        }
        // any other owners will forcefully own 0
        return 0;
    }

    function maxDeposit(address receiver)
        public
        view
        virtual
        returns (uint256 maxAssets)
    {
        address _vault = vault;

        if (receiver != _vault) {
            return 0;
        }

        return _maxDeposit(_vault);
    }

    function deposit(uint256 assets, address receiver)
        public
        returns (uint256)
    {
        address _vault = vault;
        require(msg.sender == _vault && msg.sender == receiver, "not owner");

        // transfer and invest
        IERC20(asset).safeTransferFrom(_vault, address(this), assets);

        _invest();

        // NOTE: no need to calculate shares as the price is 1.0 with total assets
        return assets;
    }

    function tend() external {
        // function in charge of taking care of the investment
        // e.g. compounding, selling rewards, adjusting debt ratios, rebalancing in any way
        _tend();
    }

    function tendTrigger() external returns (bool) {
        // returns if the strategy should be tended or not
        return _tendTrigger();
    }

    function maxWithdraw(address owner) public view returns (uint256 maxAssets) {
        address _vault = vault;

        if (owner != _vault) {
            return 0;
        }

        return _maxWithdraw(_vault);
    }

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256) {
        address _vault = vault;
        require(msg.sender == _vault, "not owner");
        require(assets <= maxWithdraw(_vault), "withdraw more than max");
        assets = _withdraw(assets);
        IERC20(asset).transfer(_vault, assets);
        // NOTE: no need to burn shares
        return assets;
    }

    function aprAfterDebtChange(int256 delta) external returns (uint256) {
        return _aprAfterDebtChange(delta);
    }

    function _totalAssets() internal view virtual returns (uint256);

    function _maxDeposit(address owner)
        internal
        view
        virtual
        returns (uint256 maxAssets);

    function _invest() internal virtual;
    
    function _tend() internal virtual;
    
    function _tendTrigger() internal virtual returns (bool);

    function _withdraw(
        uint256 amount
    ) internal virtual returns (uint256 assets);

    function _maxWithdraw(address owner)
        internal
        view
        virtual
        returns (uint256 maxAssets);

    function _aprAfterDebtChange(int256 delta) internal virtual returns (uint256);
}
