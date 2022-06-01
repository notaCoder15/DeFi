//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface Ifactory {

    event NewCSMMexchange(address indexed _token0 , address indexed _token1 , address indexed exchange);
    event NewCPMMexchange(address indexed _token0 , address indexed _token1 , address indexed exchange);
    event NewCMMMexchange(address[] indexed _tokens , address indexed exchange);

    function createCSMMexchange(address _token0 , address _token1) external returns(address);
    function createCPMMexchange(address _token0 , address _token1) external returns(address);
    function createCMMMexchange(address[] memory _tokens , uint[] memory _weights) external returns(address);

}