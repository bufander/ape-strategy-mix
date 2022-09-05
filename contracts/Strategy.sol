// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import {ERC4626BaseStrategy, IERC20} from "@yearnvaultsv3/test/ERC4626BaseStrategy.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./interfaces/IVault.sol";

// Import interfaces for many popular DeFi projects, or add your own!
//import "../interfaces/<protocol>/<Interface>.sol";

contract Strategy is ERC4626BaseStrategy {
    using Math for uint256;

    constructor(
        address _vault,
        string memory _strategyName,
        string memory _strategySymbol
    )
        ERC4626BaseStrategy(_vault, IVault(_vault).asset())
        ERC20(_strategyName, _strategySymbol)
    {}

    // TODO: add comments and functions explanations
    // ******** OVERRIDE THESE METHODS FROM BASE CONTRACT ************

    function maxDeposit(address receiver)
        public
        view
        virtual
        override
        returns (uint256 maxAssets)
    {
        maxAssets = type(uint256).max;
    }

    function _freeFunds(uint256 _amount)
        internal
        override
        returns (uint256 _amountFreed)
    {}

    function totalAssets() public view override returns (uint256) {
        return _totalAssets();
    }

    function _totalAssets() internal view returns (uint256) {
        return IERC20(asset()).balanceOf(address(this));
    }

    function _invest() internal override {}

    function harvestTrigger() public view override returns (bool) {}

    function investTrigger() public view override returns (bool) {}

    function delegatedAssets()
        public
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
