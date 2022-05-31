//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken" , "mkt"){}
    // This will create our ERC20  MyToken .
}