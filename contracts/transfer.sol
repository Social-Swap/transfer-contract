// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
pragma experimental ABIEncoderV2;

contract Transfer {
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    struct Call {
        address target;
        bytes callData;
    }
    struct Result {
        bool success;
        bytes returnData;
    }

    function transfer(Call[] memory calls) public payable returns (uint256 blockNumber, bytes[] memory returnData) {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {
            address target = calls[i].target;
            bytes memory callData = calls[i].callData;
            if (target == ETH) {
                bytes32 toAddressBytes;
                uint256 toValue;
                assembly {
                    toAddressBytes := mload(add(add(callData, 0x20), 0x0))
                    toValue := mload(add(add(callData, 0x20), 0x20))
                }
                address payable toAddress = payable(address(uint160(uint256(toAddressBytes))));
                (bool success, bytes memory ret) = toAddress.call{value: toValue}("");

                require(success, "Transfer: call failed");
                returnData[i] = ret;
            } else {
                address fromAddress;
                assembly {
                    fromAddress := mload(add(add(callData, 20), 16))
                }
                require(msg.sender == fromAddress, "Invalid address");
                (bool success, bytes memory ret) = target.call(callData);
                require(success, "Transfer: call failed");
                returnData[i] = ret;
            }
        }
    }

}
