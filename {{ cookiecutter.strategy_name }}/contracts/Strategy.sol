// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/Math.sol";

import {IERC20, BaseStrategy} from "BaseStrategy.sol";

contract Strategy is BaseStrategy {
    constructor(address _vault, string memory _name)
        BaseStrategy(_vault, _name)
    {}

    // ******** OVERRIDE METHODS FROM BASE CONTRACT IF NEEDED ************
    // ******** CREATE NEEDED METHODS FOR THE STRATEGY ************
    function _maxWithdraw() internal view override returns (uint256) {
        return _totalAssets();
    }

    function _withdraw(uint256 amount) internal override returns (uint256) {
        return amount;
    }

    function _invest() internal override {}

    function _totalAssets() internal view override returns (uint256) {
        return IERC20(asset).balanceOf(address(this));
    }
}
