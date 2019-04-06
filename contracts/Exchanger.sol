pragma solidity ^0.5.0;

import "CurrencyContract.sol";

contract Exchanger {
    address public owner;
    address public backend;

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

    mapping (address => mapping (uint32 => Order)) public orders;

    function exchange(
        address _sellerAddress,
        uint32 _sellerNonce,
        uint256 _sellerValue,
        uint256 _sellerRate,
        bytes calldata _sellerSign,
        address _buyerAddress,
        uint32 _buyerNonce,
        uint256 _buyerValue,
        uint256 _buyerRate,
        bytes calldata _buyerSign,
        uint256 _tradePrice
    )
        onlyBackend
        external
    {
        require(_checkSignature(_sellerAddress, _sellerNonce, _sellerValue, _sellerRate, false, _sellerSign));
        require(_checkSignature(_buyerAddress, _buyerNonce, _buyerValue, _buyerRate, true, _buyerSign));
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

    function _checkSignature(
        address _signer,
        uint32 _nonce,
        uint256 _value,
        uint256 _rate,
        bool _direction,
        bytes memory _sign
    )
        internal
        pure
        returns (bool)
    {
        bytes32 message = _prefixed(keccak256(abi.encodePacked(_nonce, _value, _rate, _direction)));

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
