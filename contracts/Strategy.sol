// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import {BaseStrategy, IERC20} from "@yearnvaultsv3/test/BaseStrategy.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

// Import interfaces for many popular DeFi projects, or add your own!
//import "../interfaces/<protocol>/<Interface>.sol";

contract Strategy is BaseStrategy {
    string internal strategyName;
    uint256 public minDebt;
    uint256 public maxDebt;

    constructor(address _vault, string memory _strategyName)
        BaseStrategy(_vault)
    {
        strategyName = _strategyName;
    }

    // TODO: add comments and functions explanations
    // ******** OVERRIDE THESE METHODS FROM BASE CONTRACT ************

    function name() external view override returns (string memory) {
        return strategyName;
    }

    function setMinDebt(uint256 _minDebt) external {
        minDebt = _minDebt;
    }

    function setMaxDebt(uint256 _maxDebt) external {
        maxDebt = _maxDebt;
    }

    function investable() external view override returns (uint256, uint256) {
        return (minDebt, maxDebt);
    }

    function withdrawable()
        external
        view
        override
        returns (uint256 _withdrawable)
    {}

    function _freeFunds(uint256 _amount)
        internal
        override
        returns (uint256 _amountFreed)
    {}

    function totalAssets() external view override returns (uint256) {
        return _totalAssets();
    }

    function _totalAssets() internal view returns (uint256) {
        return 0;
    }

    function _emergencyFreeFunds(uint256 _amountToWithdraw) internal override {}

    function _invest() internal override {}

    function _harvest() internal override {}

    function _migrate(address _newStrategy) internal override {}

    function harvestTrigger() external view override returns (bool) {}

    function investTrigger() external view override returns (bool) {}

    function delegatedAssets()
        external
        view
        override
        returns (uint256 _delegatedAssets)
    {}

    function _protectedTokens()
        internal
        view
        override
        returns (address[] memory _protected)
    {}
}
