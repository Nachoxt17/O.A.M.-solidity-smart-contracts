// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "../Libraries/TokenContracts/ERC20.sol";

contract USDOAM is ERC20 {
    constructor() ERC20("USDOAM", "USDOAM") {}
}
