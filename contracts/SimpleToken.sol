// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleToken is ERC20 {

    constructor () ERC20("Simple", "SimpleToken") {
        _mint(msg.sender, 200000 * (10 ** uint256(decimals())));
    }
}