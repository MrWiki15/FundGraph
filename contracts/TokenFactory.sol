// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "./IHederaTokenService.sol";

contract TokenFactory {
    // Dirección del servicio de tokens de Hedera
    address constant HEDERA_TOKEN_SERVICE = 0x167;
    
    // Evento para registrar la creación de tokens
    event TokenCreated(
        address indexed creator,
        address tokenAddress,
        string name,
        string symbol
    );

    // Función para crear un nuevo token
    function createToken(
        string memory name, 
        string memory symbol,
        uint initialSupply
    ) external payable returns (address tokenAddress) {
        // Parámetros para la creación del token
        IHederaTokenService.HederaToken memory token = IHederaTokenService.HederaToken({
            name: name,
            symbol: symbol,
            treasury: address(this), // Temporalmente poseído por el contrato
            adminKey: bytes32(0),
            kycKey: bytes32(0),
            freezeKey: bytes32(0),
            wipeKey: bytes32(0),
            supplyKey: bytes32(0),
            feeScheduleKey: bytes32(0),
            freezeDefault: false,
            expirationTime: type(uint64).max,
            autoRenewAccount: address(0),
            autoRenewPeriod: 0,
            memo: ""
        });

        // Crear el token usando el servicio HTS
        (int responseCode, address createdToken) = IHederaTokenService(HEDERA_TOKEN_SERVICE)
            .createToken(token, initialSupply, 0);
        
        require(responseCode == 22, "Token creation failed"); // 22 = SUCCESS en Hedera

        // Transferir propiedad al creador
        IHederaTokenService(HEDERA_TOKEN_SERVICE).updateTokenAdminKey(
            createdToken, 
            abi.encodePacked(msg.sender)
        );

        emit TokenCreated(msg.sender, createdToken, name, symbol);
        return createdToken;
    }
}