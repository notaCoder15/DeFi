//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../Ifactory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract cmmmExchange is ERC20{

    event Swap(IERC20 tokenIn , uint amountIn ,IERC20 tokenOut ,uint amountOut);
    event LiquidityAdded (uint[] _amounts , uint indexed _eqt);
    event LiquidityRemoved(uint indexed _eqt , uint[] _amounts);

    constructor() ERC20("Equity Token" , "EQT"){}

    Ifactory Factory;


    IERC20[] tokens;
    uint numberOfTokens;

    uint[] weights;
    uint[] reserves;


    function setup(address[] memory _tokens , uint _length , uint[] memory _weights) public {
        require(address(Factory) == address(0) , "Setup function already called");
        Factory = Ifactory(msg.sender);

        numberOfTokens = _length;
        for(uint i;i < _length; i++){
            tokens[i] = IERC20(_tokens[i]);
        }

        weights = _weights;

    }


// swaps betweent the given tokens

    function swap(address _tokenIn , uint _amount , address _tokenOut) public returns(uint _amountOut){
        
        uint i;
        uint o;

        for(uint a; a< numberOfTokens ; a++){
            if(address(tokens[a]) == _tokenIn){
                i = a;
            }
            if(address(tokens[a]) == _tokenOut){
                o = a;
            }
        }

        uint weightRatio = weights[i]/weights[o];

        tokens[i].transferFrom(msg.sender , address(this) , _amount);

        _amountOut = reserves[o] * (1 - (reserves[i]/(reserves[i] + _amount))**weightRatio) ;

        tokens[o].transfer(msg.sender , _amountOut);

        reserves[i] += _amount;
        reserves[o] -= _amountOut;

        emit Swap(tokens[i], _amount, tokens[o], _amountOut);

    }


    function addLiquidity(uint[] memory _amounts) public returns(uint _eqt){

        uint value = (_amounts[0] * weights[0]) / reserves[0];
        for(uint i =1 ; i< numberOfTokens ; i++){
            require((_amounts[i] * weights[i]) / reserves[i] == value , "Not equal value");
        }

        for(uint i ; i < numberOfTokens ; i++){
            tokens[i].transferFrom(msg.sender , address(this) , _amounts[i]);
        }

        if(totalSupply()>0){
            _eqt = (_amounts[0] * totalSupply()) / reserves[0] ;
        }else{
            _eqt=1;
            for(uint i; i< numberOfTokens ; i++){
                _eqt = _eqt * (reserves[i]**weights[i]);
            }
        }

        _mint(msg.sender, _eqt);

        for(uint i ; i< numberOfTokens ; i++){
            reserves[i] = reserves[i] + _amounts[i];
        }
        emit LiquidityAdded(_amounts, _eqt);
        
    }

    function removeLiquidity(uint _eqt) public returns(uint[] memory _amounts){
        
        for(uint i; i<numberOfTokens ;i++){
            _amounts[i] = (_eqt * reserves[i]) / totalSupply();
        }
        
        _burn(msg.sender, _eqt);

        for(uint i; i< numberOfTokens ; i++){
            tokens[i].transfer(msg.sender , _amounts[i]);
        }

        for(uint i; i< numberOfTokens ; i++){
            reserves[i] = reserves[i] - _amounts[i];
        }

        emit LiquidityRemoved(_eqt, _amounts);

    }

}