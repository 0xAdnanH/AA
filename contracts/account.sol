// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title Account Contract
 * @dev This contract provides functionality for storing data and executing low-level operations.
 * It allows the contract owner to execute arbitrary transactions and manage stored data.
 */
contract account is Ownable {
    // Storage to store data with a key
    mapping(bytes32 => bytes) internal _store;

    // Events
    event DataChanged(bytes32 indexed dataKey, bytes dataValue);
    event Executed(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes dataToSend
    );

    //Errors
    error LowLevelCallFailed(address target, bytes dataToSend);
    error ERC725Y_MsgValueDisallowed();

    /**
     * @dev Execute a low-level operation or deploy a contract using create2.
     * @param operationType The type of operation. 0 for call, 1 for create2, other values are not supported.
     * @param target The target address to execute the operation on.
     * @param valueToSend The value in wei to send along with the call or create2 operation.
     * @param dataToSend The data to be sent along with the call or create2 operation.
     * @notice Only the contract owner can call this function.
     * @notice For call, the executed contract can emit an Executed event on success, otherwise, it reverts with LowLevelCallFailed.
     * @notice For create2, the deployed contract address must not be 0, otherwise, it will revert.
     * @notice For unsupported operationType, it will revert with "Op greater than 1".
     */

    function execute(
        uint256 operationType,
        address target,
        uint256 valueToSend,
        bytes memory dataToSend
    ) public payable onlyOwner {
        _execute(operationType, target, valueToSend, dataToSend);
    }

    /**
     * @dev Get the data associated with the given dataKey.
     * @param dataKey The key to look up the associated data.
     * @return dataValue The value associated with the provided dataKey.
     */

    function getData(
        bytes32 dataKey
    ) public view virtual returns (bytes memory dataValue) {
        dataValue = _getData(dataKey);
    }

    /**
     * @dev Set the data for the given dataKey.
     * @param dataKey The key to store the data.
     * @param dataValue The data to be stored.
     * @notice Only the contract owner can call this function.
     * @notice Ether transfer with the transaction is not allowed, otherwise, it reverts with ERC725Y_MsgValueDisallowed.
     */

    function setData(
        bytes32 dataKey,
        bytes memory dataValue
    ) public payable virtual onlyOwner {
        if (msg.value != 0) revert ERC725Y_MsgValueDisallowed();
        _setData(dataKey, dataValue);
    }

    /**
     * @dev Internal function to execute low-level operations.
     * @param operationType The type of operation. 0 for call, 1 for create2, other values are not supported.
     * @param target The target address to execute the operation on.
     * @param valueToSend The value in wei to send along with the call or create2 operation.
     * @param dataToSend The data to be sent along with the call or create2 operation.
     * @notice For call, the executed contract can emit an Executed event on success, otherwise, it reverts with LowLevelCallFailed.
     * @notice For create2, the deployed contract address must not be 0, otherwise, it will revert.
     * @notice For unsupported operationType, it will revert with "Op greater than 1".
     */

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

    /**
     * @dev Internal function to get the data associated with the given dataKey.
     * @param dataKey The key to look up the associated data.
     * @return dataValue The value associated with the provided dataKey.
     */

    function _getData(
        bytes32 dataKey
    ) internal view virtual returns (bytes memory dataValue) {
        return _store[dataKey];
    }

    /**
     * @dev Internal function to set the data for the given dataKey.
     * @param dataKey The key to store the data.
     * @param dataValue The data to be stored.
     */

    function _setData(
        bytes32 dataKey,
        bytes memory dataValue
    ) internal virtual {
        _store[dataKey] = dataValue;
        emit DataChanged(dataKey, dataValue);
    }

    /**
     * @dev Verify the validity of a signature.
     * @param _hash The hashed message that was signed.
     * @param _signature The signature to be verified.
     * @return magicValue 0x1626ba7e if the signature is valid for the contract owner, otherwise 0xffffffff.
     */

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
