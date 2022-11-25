// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/math/Math.sol";

import {IERC20, BaseStrategy} from "BaseStrategy.sol";

contract Strategy is BaseStrategy {
    constructor(address _vault, string memory _name)
        BaseStrategy(_vault, _name)
    {}

    function _totalAssets() internal view override returns (uint256) {
        // report the total amount of assets that the strategy holds
        // NOTE: output will be used by vault to evaluate the P&L of the strategy
        // if totalAssets > currentDebt -> profit
        // if totalAssets < currentDebt -> loss
        // recommendation is to report only when it can be considered profit (i.e. exclude very volatile tokens that still need to be sold)
        return IERC20(asset).balanceOf(address(this));
    }

    function _invest() internal override {
        // implement logic for depositing in underlying protocol
    }

    function _withdraw(
        uint256 amount
    ) internal override returns (uint256) {
        // implement logic for withdrawing funds from the underlying protocol
        return amount;
    }
 
    function _tend() internal override {
        // implement logic for taking care of the position
        // e.g. Compounding, readjusting debt ratios, ...
    }

    function _tendTrigger() internal override returns (bool) {
        // implement logic to tell keepers to call tend()
    }

    function _aprAfterDebtChange(int256 delta) internal override returns (uint256) {
        // estimate APR

        // default set to 0 to avoid misallocations (worst case scenario the strategy doesn't receive funds)
        return 0;
    }

    function _maxWithdraw(address owner)
        internal
        view
        override
        returns (uint256)
    {
        // Default: the strategy is fully liquid
        return _totalAssets();
    }

    function _maxDeposit(address owner)
        internal
        view
        override
        returns (uint256)
    {
        // Default: there are no deposit limitations
        return type(uint256).max;
    }


}
