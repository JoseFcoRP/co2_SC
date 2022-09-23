// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CO2Token is ERC20 {
    constructor() ERC20("Co2", "COO") {} 

    function mint(address _account, uint256 _amount) public {
        _mint(_account, _amount);
    }

    function burn(address _account, uint256 _amount) public {
        require(this.balanceOf(_account)>=_amount);
        _burn(_account, _amount);
    }
}