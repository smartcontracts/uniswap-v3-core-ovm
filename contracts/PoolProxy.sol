// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

/// @notice Simple Proxy that passes calls to its implementation
/// @dev Trimmed down verion of the OpenZeppelin implementation: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/86694813099ba566f227b7d7a46c950baa364b64/contracts/proxy/Proxy.sol
contract PoolProxy {
    bytes32 constant public IMPL_KEY = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address _implementation) {
        assembly {
            sstore(IMPL_KEY, _implementation)
        }
    }

    /**
     * @dev Delegates the current call to the address returned by `_implementation()`.
     *
     * This function does not return to its internall call site, it will return directly to the external caller.
     */
    fallback() external {
        address _implementation;
        assembly {
            _implementation := sload(IMPL_KEY)
        }

        // solhint-disable-next-line no-inline-assembly
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), _implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
                // delegatecall returns 0 on error.
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }
}
