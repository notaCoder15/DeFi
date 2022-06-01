//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./exchanges/csmmExchange.sol";
import "./exchanges/cpmmExchange.sol";
import "./exchanges/cmmmExchange.sol";

// this contarct is used to create exchange contracts between tokens

contract factory{

    event NewCSMMexchange(address indexed _token0 , address indexed _token1 , address indexed exchange);
    event NewCPMMexchange(address indexed _token0 , address indexed _token1 , address indexed exchange);
    event NewCMMMexchange(address[] indexed _tokens , address indexed exchange);


    mapping (address => mapping(address => address)) CSMMtokenToExchange;      // mapping of token addressed with exchange addresses
    mapping (address => mapping(address => address)) CPMMtokenToExchange;       // mapping of token addressed with exchange addresses

    mapping (address => mapping (address => bool)) CSMMtokenTotoken;        // mapping to check if exchange already created
    mapping (address => mapping (address => bool)) CPMMtokenTotoken;        // mapping to check if exchange already created


// this function creates a Constant Sum Automated market maker contract between the input tokes
    function createCSMMexchange(address _token0 , address _token1) external returns(address){
        require(_token0 != address(0) && _token1 != address(0) , "not valid token addresses");
        require(CSMMtokenTotoken[_token0][_token1] == false && CSMMtokenTotoken[_token1][_token0] == false , "Exchange already exists");

        csmmExchange Exchange = new csmmExchange();
        Exchange.setup(_token0 , _token1);

        CSMMtokenToExchange[_token0][_token1] = address(Exchange);
        CSMMtokenToExchange[_token1][_token0] = address(Exchange);

        CSMMtokenTotoken[_token0][_token1] = true;
        CSMMtokenTotoken[_token1][_token0] = true;

        emit NewCSMMexchange(_token0, _token1, address(Exchange));
        return address(Exchange);
    }


// this function creates a Constant Product Automated market maker contract between the input tokes
    function createCPMMexchange(address _token0 , address _token1) external returns(address){
        require(_token0 != address(0) && _token1 != address(0) , "not valid token addresses");
        require(CPMMtokenTotoken[_token0][_token1] == false && CPMMtokenTotoken[_token1][_token0] == false , "Exchange already exists");

        cpmmExchange Exchange = new cpmmExchange();
        Exchange.setup(_token0 , _token1);

        CPMMtokenToExchange[_token0][_token1] = address(Exchange);
        CPMMtokenToExchange[_token1][_token0] = address(Exchange);

        CPMMtokenTotoken[_token0][_token1] = true;
        CPMMtokenTotoken[_token1][_token0] = true;

        emit NewCPMMexchange(_token0, _token1, address(Exchange));
        return address(Exchange);
    }


// this function creates a Constant Mean Automated market maker contract between the input tokes
    function createCMMMexchange(address[] memory _tokens , uint[] memory _weights) external returns(address){
        uint len = _tokens.length;

        cmmmExchange Exchange = new cmmmExchange();
        Exchange.setup(_tokens , len , _weights);

        emit NewCMMMexchange(_tokens, address(Exchange));
        return address(Exchange);
    }

}