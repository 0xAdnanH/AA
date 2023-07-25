// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract account is Ownable {
    mapping(bytes32 => bytes) internal _store;

    event DataChanged(bytes32 indexed dataKey, bytes dataValue);
    event Executed(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes dataToSend
    );
    error LowLevelCallFailed(address target, bytes dataToSend);
    error ERC725Y_MsgValueDisallowed();

    function execute(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes memory dataToSend
    ) public payable onlyOwner {
        _execute(operationType, target, valueToSend, dataToSend);
    }

    function getData(
        bytes32 dataKey
    ) public view virtual returns (bytes memory dataValue) {
        dataValue = _getData(dataKey);
    }

    function setData(
        bytes32 dataKey,
        bytes memory dataValue
    ) public payable virtual onlyOwner {
        if (msg.value != 0) revert ERC725Y_MsgValueDisallowed();
        _setData(dataKey, dataValue);
    }

    function _execute(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes memory dataToSend
    ) internal {
        if (operationType == 0) {
            (bool success, bytes memory returnData) = target.call{
                value: valueToSend
            }(dataToSend);
            if (success) {
                emit Executed(operationType, target, valueToSend, dataToSend);
            } else {
                revert LowLevelCallFailed(target, dataToSend);
            }
        } else if (operationType == 1) {
            address contract2Address;
            bytes32 salt;
            assembly {
                contract2Address := create2(
                    valueToSend,
                    add(dataToSend, 0x20),
                    mload(dataToSend),
                    salt
                )
            }
            require(contract2Address != address(0));
        } else {
            revert("Op greater than 1");
        }
    }

    function _getData(
        bytes32 dataKey
    ) internal view virtual returns (bytes memory dataValue) {
        return _store[dataKey];
    }

    function _setData(
        bytes32 dataKey,
        bytes memory dataValue
    ) internal virtual {
        _store[dataKey] = dataValue;
        emit DataChanged(dataKey, dataValue);
    }

    function isValidSignature(
        bytes32 _hash,
        bytes memory _signature
    ) public view returns (bytes4 magicValue) {
        address recovered = ECDSA.recover(_hash, _signature);
        if (recovered == owner()) {
            return 0x1626ba7e;
        } else {
            return 0xffffffff;
        }
    }
}
