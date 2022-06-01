//SPDX-License-Identifier:MIT
pragma solidity ^0.8.11;

interface IERC20 {
    // events
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    // view functions
    function totalSupply() external view returns (uint _totalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function allowance(address _owner, address _spender) external view returns (uint remaining);

    //functions that changes state
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);


}