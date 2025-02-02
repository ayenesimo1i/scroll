// SPDX-License-Identifier: MIT

pragma solidity =0.8.24;

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {WETH} from "solmate/tokens/WETH.sol";

import {ScrollStandardERC20} from "../libraries/token/ScrollStandardERC20.sol";
import {ScrollStandardERC20Factory} from "../libraries/token/ScrollStandardERC20Factory.sol";
import {IScrollStandardERC20Factory} from "../libraries/token/IScrollStandardERC20Factory.sol";

contract ScrollStandardERC20FactoryTest is DSTestPlus {
    ScrollStandardERC20 private impl;
    ScrollStandardERC20Factory private factory;

    function setUp() public {
        impl = new ScrollStandardERC20();
        factory = new ScrollStandardERC20Factory(address(impl));
    }

    function testDeployFactoryRevert() external {
        // zero address as ERC20 implementation address, revert
        hevm.expectRevert("zero implementation address");
        new ScrollStandardERC20Factory(address(0));
    }

    function testDeployL2Token(address _gateway, address _l1Token) external {
        // call by non-owner, should revert
        hevm.startPrank(address(1));
        hevm.expectRevert("Ownable: caller is not the owner");
        factory.deployL2Token(_gateway, _l1Token);
        hevm.stopPrank();

        // call by owner, should succeed
        address computed = factory.computeL2TokenAddress(_gateway, _l1Token);
        hevm.expectEmit(true, true, false, false);
        emit IScrollStandardERC20Factory.DeployToken(_l1Token, computed);
        address deployed = factory.deployL2Token(_gateway, _l1Token);
        assertEq(computed, deployed);
    }
}
