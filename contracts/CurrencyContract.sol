pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";


contract CurrencyContract {
    
    using SafeMath for uint256;

    IERC20 currency;

    mapping(address => uint256) balances;

    constructor(address ERC20ContractAddress) public {
        currency = IERC20(ERC20ContractAddress);
    }

    function deposit(uint _amount) public {
        currency.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

    function withdraw(uint _amount) public {
        require(balances[msg.sender] >= _amount, "not enough tokens");
        currency.transfer(msg.sender, _amount);
    }

}