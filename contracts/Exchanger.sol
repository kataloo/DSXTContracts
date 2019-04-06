pragma solidity ^0.5.0;

import "CurrencyContract.sol";

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
        uint256 _tradeRate
    )
        onlyBackend
        external
    {

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
        bytes memory _sign
    )
        internal
        pure
        returns (bool)
    {
        bytes32 message = _prefixed(keccak256(abi.encodePacked(_nonce, _value, _rate)));

        address signedBy = _recoverSigner(message, _sign);
        return signedBy == _signer;
    }

    function cancelOrder(uint32 _nonce) external {
        orders[msg.sender][_nonce] = Order({valueLeft: 0, isInitialized: true, isActive: false});
    }
}
