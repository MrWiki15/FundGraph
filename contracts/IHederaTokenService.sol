// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IHederaTokenService {
    struct HederaToken {
        string name;
        string symbol;
        address treasury;
        bytes32 adminKey;
        bytes32 kycKey;
        bytes32 freezeKey;
        bytes32 wipeKey;
        bytes32 supplyKey;
        bytes32 feeScheduleKey;
        bool freezeDefault;
        uint64 expirationTime;
        address autoRenewAccount;
        uint32 autoRenewPeriod;
        string memo;
    }

    function createToken(
        HederaToken memory token,
        uint initialSupply,
        uint decimals
    ) external payable returns (int responseCode, address tokenAddress);

    function mintToken(
        address token,
        uint amount,
        bytes[] memory metadata
    ) external returns (int responseCode);

    function updateTokenAdminKey(
        address token,
        bytes memory adminKey
    ) external returns (int responseCode);
}