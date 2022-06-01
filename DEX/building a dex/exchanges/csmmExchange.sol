//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../Ifactory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract csmmExchange is ERC20{

    event Swap(IERC20 tokenIn , uint amountIn ,IERC20 tokenOut ,uint amountOut);
    event LiquidityAdded (uint _amount0 , uint _amount1 , uint indexed eqt);
    event LiquidityRemoved(uint indexed _eqt , uint _amount0 , uint _amount1);

    constructor() ERC20("Equity Token" , "EQT"){}

    Ifactory Factory;

    IERC20 token0;
    IERC20 token1;

    uint reserve0;
    uint reserve1;


    function setup(address _token0 , address _token1) public {
        require(address(Factory) == address(0) , "Setup function already called");
        Factory = Ifactory(msg.sender);

        token0 = IERC20(_token0);
        token1 = IERC20(_token1);

    }



    function _update(uint _reserve0 , uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }



    function swap(address _tokenIn , uint _amount) public returns(uint ){
        require(_tokenIn == address(token0) || _tokenIn == address(token1) , "Not valid token");

        (IERC20 tokenIn , IERC20 tokenOut) = _tokenIn == address(token0) 
                                            ? (token0 , token1) 
                                            : (token1 , token0);
        
        tokenIn.transferFrom(msg.sender ,address(this) , _amount);

        uint amountOut = (_amount*997)/ 1000 ;

        (uint _reserve0 , uint _reserve1) = _tokenIn == address(token0)
                                           ? (reserve0 + _amount , reserve1 - amountOut)
                                           : (reserve0 - amountOut , reserve1 + _amount);

        tokenOut.transfer(msg.sender , amountOut);
        _update(_reserve0, _reserve1);
        emit Swap(tokenIn, _amount, tokenOut, amountOut);
        return amountOut;

    }


    function addLiquidity(uint _amount0 , uint _amount1) public returns(uint){

        token0.transferFrom(msg.sender , address(this), _amount0);
        token1.transferFrom(msg.sender , address(this), _amount1);

        uint eqt;

        if(totalSupply() > 0){
            eqt = ((_amount0 + _amount1) * totalSupply()) / (reserve0 + reserve1);
        }else{
            eqt = _amount0 + _amount1;
        }

        _mint(msg.sender, eqt);
        _update(token0.balanceOf(address(this)), token1.balanceOf(address(this)));

        emit LiquidityAdded(_amount0, _amount1, eqt);
        return eqt;
    }

    function removeLiquidity(uint _eqt) public returns(uint _amount0 , uint _amount1){
        
        _amount0 = (reserve0 * _eqt) / totalSupply();
        _amount1 = (reserve1 * _eqt) / totalSupply();

        token0.transfer(address(this), _amount0);
        token1.transfer(address(this), _amount1);

        _burn(msg.sender, _eqt);
        _update(reserve0 - _amount0, reserve1 - _amount1);

        emit LiquidityRemoved(_eqt, _amount0, _amount1);
        
    }

}