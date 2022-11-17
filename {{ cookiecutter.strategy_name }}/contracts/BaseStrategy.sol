// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IVault.sol";

abstract contract BaseStrategy {
    address public vault;
    address public immutable asset;
    string public name;

    constructor(address _vault, string memory _name) {
        vault = _vault;
        name = _name;
        asset = IVault(vault).asset();
    }

    function maxDeposit(address receiver)
        public
        view
        virtual
        returns (uint256 maxAssets)
    {
        maxAssets = type(uint256).max;
    }

    function convertToAssets(uint256 shares) public view returns (uint256) {
        // 1:1
        return shares;
    }

    function convertToShares(uint256 assets) public view returns (uint256) {
        // 1:1
        return assets;
    }

    function totalAssets() public view returns (uint256) {
        return _totalAssets();
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == vault) {
            return _totalAssets();
        }
        return 0;
    }

    function deposit(uint256 assets, address receiver)
        public
        returns (uint256)
    {
        require(msg.sender == vault && msg.sender == receiver, "not owner");

        // transfer and invest
        IERC20(asset).transferFrom(vault, address(this), assets);
        _invest();
        return assets;
    }

    function maxWithdraw() public view returns (uint256) {
        return _maxWithdraw();
    }

    function _maxWithdraw()
        internal
        view
        virtual
        returns (uint256 withdraw_amount)
    {}

    function withdraw(uint256 amount) public returns (uint256) {
        require(msg.sender == vault && msg.sender == receiver, "not owner");
        uint256 amount_withdrawn = _withdraw(amount);
        IERC20(asset).transfer(vault, amount_withdrawn);
        return amount_withdrawn;
    }

    function _withdraw(uint256 amount)
        internal
        virtual
        returns (uint256 withdraw_amount)
    {}

    function _invest() internal virtual {}

    function _totalAssets() internal view virtual returns (uint256) {
        return IERC20(asset).balanceOf(address(this));
    }
}
