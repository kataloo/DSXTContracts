pragma solidity ^0.5.0;

import "CurrencyContract.sol";

contract Exchanger {
    address public owner;
    address public backend;
    uint256 BASE = 10000;

    using SafeMath for uint256;

    CurrencyContract currency1;
    CurrencyContract currency2;

    constructor(address _backend) public {
        owner = msg.sender;
        backend = _backend;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyBackend() {
        require(msg.sender == backend);
        _;
    }


    struct Order {
        uint256 valueLeft;
        bool isInitialized;
        bool isActive;
    }

    mapping (address => mapping (uint256 => Order)) public orders;

    function exchange(
        bytes calldata _sellerSign,
        bytes calldata _buyerSign,
        address _sellerAddress,
        address _buyerAddress,
//        uint256 _sellerNonce, 0
//        uint256 _sellerValue, 1
//        uint256 _sellerRate, 2
//        uint256 _buyerNonce, 3
//        uint256 _buyerValue, 4
//        uint256 _buyerRate, 5
//        uint256 _tradePrice 6
        uint256[7] calldata args
    )
        onlyBackend
        external
    {
        require(checkSignature(_sellerAddress, args[0], args[1], args[2], false, _sellerSign));
        require(checkSignature(_buyerAddress, args[3], args[4], args[5], true, _buyerSign));

        uint256 _sellerNonce = args[0];
        uint256 _sellerValue = args[1];
        uint256 _sellerRate = args[2];
        uint256 _buyerNonce = args[3];
        uint256 _buyerValue = args[4];
        uint256 _buyerRate = args[5];
        uint256 _tradePrice = args[6];

        require(_tradePrice > 0);

        if (!orders[_sellerAddress][_sellerNonce].isInitialized) {
            orders[_sellerAddress][_sellerNonce] = Order({
                valueLeft: _sellerValue,
                isInitialized: true,
                isActive: true
            });
        }
        require(orders[_sellerAddress][_sellerNonce].isActive);

        if (!orders[_buyerAddress][_buyerNonce].isInitialized) {
            orders[_buyerAddress][_buyerNonce] = Order({
                valueLeft: _buyerValue,
                isInitialized: true,
                isActive: true
            });
        }
        require(orders[_buyerAddress][_buyerNonce].isActive);

        require(_sellerRate == 0 || _sellerRate >= _tradePrice);
        require(_buyerRate == 0 || _buyerRate <= _tradePrice);

        uint256 tradeValue;
        if (orders[_sellerAddress][_sellerNonce].valueLeft < orders[_buyerAddress][_buyerNonce].valueLeft) {
            tradeValue = orders[_sellerAddress][_sellerNonce].valueLeft;
        } else {
            tradeValue = orders[_buyerAddress][_buyerNonce].valueLeft;
        }

        currency1.transferForOrder(tradeValue, _sellerAddress, _buyerAddress);
        currency2.transferForOrder(tradeValue.mul(_tradePrice) / BASE, _buyerAddress, _sellerAddress);

        orders[_sellerAddress][_sellerNonce].valueLeft = orders[_sellerAddress][_sellerNonce].valueLeft.sub(tradeValue);
        orders[_sellerAddress][_sellerNonce].valueLeft = orders[_buyerAddress][_buyerNonce].valueLeft.sub(tradeValue);
        if (orders[_sellerAddress][_sellerNonce].valueLeft == 0) {
            orders[_sellerAddress][_sellerNonce].isActive = false;
        }
        if (orders[_buyerAddress][_buyerNonce].valueLeft == 0) {
            orders[_buyerAddress][_buyerNonce].isActive = false;
        }
    }

    function _splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }

    function _recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = _splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function _prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function checkSignature(
        address _signer,
        uint256 _nonce,
        uint256 _value,
        uint256 _rate,
        bool _direction,
        bytes memory _sign
    )
        public
        pure
        returns (bool)
    {
        bytes32 message = keccak256(abi.encodePacked(_nonce, _value, _rate, _direction));

        address signedBy = _recoverSigner(message, _sign);
        return signedBy == _signer;
    }

    function cancelOrder(uint32 _nonce) external {
        orders[msg.sender][_nonce] = Order({valueLeft: 0, isInitialized: true, isActive: false});
    }

    function addCurrencyContracts(address _currency1, address _currency2) external onlyOwner {
        currency1 = CurrencyContract(_currency1);
        currency2 = CurrencyContract(_currency2);
    }
}
