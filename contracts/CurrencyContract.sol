pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

contract CurrencyContract {
    
    using SafeMath for uint256;

    IERC20 public currency;

    address public exchanger;

    mapping(address => uint256) public balances;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyExchanger() {
        require(msg.sender == exchanger);
        _;
    }

    constructor(address ERC20ContractAddress, address _executorContractAddress) public {
        currency = IERC20(ERC20ContractAddress);
        exchanger = _executorContractAddress;
    }

    function deposit(uint _amount) public {
        currency.transferFrom(msg.sender, address(this), _amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

    function withdraw(uint _amount) public {
        require(balances[msg.sender] >= _amount, "not enough tokens");
        currency.transfer(msg.sender, _amount);
    }

    function transferForOrder(uint256 _amount, address _from, address _to) public onlyExchanger {
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
    }

}