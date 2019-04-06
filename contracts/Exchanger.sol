pragma solidity ^0.5.0;

contract Exchanger {
    address public backend;

    constructor(address _backend) public {
        backend = _backend;
    }

    modifier onlyBackend() {
        require(msg.sender == backend);
        _;
    }


    struct Order {
        uint256 valueLeft;
        bool isInited;
        bool isActive;
    }

    mapping (address => mapping (uint32 => Order)) public orders;

    function exchange(
        address _seller,
        uint32 _sellerNonce,
        uint256 _sellerValue,
        uint256 _sellerRate,
        bytes32 _sellerSign,
        address _buyer,
        uint32 _buyerNonce,
        uint256 _buyerValue,
        uint256 _buyerRate,
        bytes32 _buyerSign,
        uint256 _tradeValue,
        uint256 _tradeRate
    )
        onlyBackend
        external
    {
        // exchange method
    }

    function cancelOrder(uint32 _nonce) external {
        orders[msg.sender][_nonce] = Order({valueLeft: 0, isInited: true, isActive: false});
    }
}
