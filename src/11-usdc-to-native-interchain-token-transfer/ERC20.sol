// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^ 0.8.18;

import "@openzeppelin/contracts@4.8.1/token/ERC20/ERC20.sol";

/* this is an example ERC20 token called USDC */

contract USDC is ERC20 {
    constructor() ERC20("USDC", "USDC") {
        _mint(msg.sender, 1000000 * 10 ** 6);
    }
}
