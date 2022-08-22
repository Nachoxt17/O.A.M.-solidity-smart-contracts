// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "./EnumerableSet.sol";
import "../Interfaces/IERC20.sol";

abstract contract CollectableDust {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public constant MATIC_ADDRESS =
        0x0000000000000000000000000000000000001010;
    /**address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;*/
    EnumerableSet.AddressSet internal protocolTokens;

    event DustSent(address _to, address token, uint256 amount);

    constructor() {}

    function _addProtocolToken(address _token) internal {
        require(
            !protocolTokens.contains(_token),
            "collectable-dust/token-is-part-of-the-protocol"
        );
        protocolTokens.add(_token);
    }

    function _removeProtocolToken(address _token) internal {
        require(
            protocolTokens.contains(_token),
            "collectable-dust/token-not-part-of-the-protocol"
        );
        protocolTokens.remove(_token);
    }

    function _sendDust(
        address _to,
        address _token,
        uint256 _amount
    ) internal {
        require(
            _to != address(0),
            "collectable-dust/cant-send-dust-to-zero-address"
        );
        require(
            !protocolTokens.contains(_token),
            "collectable-dust/token-is-part-of-the-protocol"
        );
        if (_token == MATIC_ADDRESS) {
            payable(_to).transfer(_amount);
        } else {
            IERC20(_token).transfer(_to, _amount);
        }
        emit DustSent(_to, _token, _amount);
    }
}
