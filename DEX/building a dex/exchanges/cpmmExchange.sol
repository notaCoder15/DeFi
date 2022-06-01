//SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../Ifactory.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract cpmmExchange is ERC20{

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

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }



    function _update(uint _reserve0 , uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }



    function swap(address _tokenIn , uint _amount) public returns(uint _amountOut){
        require(_tokenIn == address(token0) || _tokenIn == address(token1) , "Not valid token");

        (IERC20 tokenIn , IERC20 tokenOut ,uint reserveIn , uint reserveOut) = _tokenIn == address(token0) 
                                            ? (token0 , token1 , reserve0 , reserve1) 
                                            : (token1 , token0 , reserve1 , reserve0);

        uint _amountWithFee = (997 * _amount)/1000;

        _amountOut = (_amountWithFee * reserveOut)/(reserveIn + _amountWithFee);
        
        tokenIn.transferFrom(msg.sender , address(this) , _amount);
        tokenOut.transfer(msg.sender , _amountOut);

        (uint _reserve0 , uint _reserve1) = _tokenIn == address(token0) 
                                            ? (reserveIn + _amount , reserveOut - _amountOut)
                                            : (reserveOut - _amountOut , reserveIn + _amount);

        _update(_reserve0, _reserve1);

        emit Swap(tokenIn, _amount, tokenOut, _amountOut);

    }


    function addLiquidity(uint _amount0 , uint _amount1) public returns(uint _eqt){
        require(_amount0 * reserve1 == _amount1 * reserve0 , "Not equal value added");

        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        
        if(totalSupply() > 0){
            _eqt = (_amount0 * totalSupply()) / reserve0;
        }else{
            _eqt = _sqrt(_amount0 *_amount1);
        }

        _mint(msg.sender, _eqt);
        _update(token0.balanceOf(address(this)), token0.balanceOf(address(this)));

        emit LiquidityAdded(_amount0, _amount1, _eqt);
    }

    function removeLiquidity(uint _eqt) public returns(uint _amount0 , uint _amount1){
        
        _amount0 = (_eqt * reserve0 ) / totalSupply();
        _amount1 = (_eqt * reserve1 ) / totalSupply();

        _burn(msg.sender, _eqt);

        token0.transfer(msg.sender, _amount0);
        token1.transfer(msg.sender, _amount1);

        _update(reserve0 - _amount0, reserve1 - _amount1);

        emit LiquidityRemoved(_eqt, _amount0, _amount1);
        
    }

}