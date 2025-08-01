// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IHederaTokenService.sol";

contract CrowdFund {
    address constant HEDERA_TOKEN_SERVICE = 0x167;

    // Estructura para almacenar información de proyecto
    struct Project {
        address tokenAddress;
        address creator;
        uint fundingGoal;
        uint fundsRaised;
        bool isActive;
    }

    // Mapeo de ID de proyecto a estructura
    mapping(uint => Project) public projects;
    // Contador de proyectos
    uint public projectCount;

    // Eventos
    event ProjectCreated(uint projectId, address tokenAddress, address creator);
    event DonationReceived(uint projectId, address donor, uint amount, uint tokensMinted);

    // Crea un nuevo proyecto de crowdfunding
    function createProject(
        address tokenAddress,
        uint fundingGoal
    ) external returns (uint projectId) {
        projectId = ++projectCount;
        
        projects[projectId] = Project({
            tokenAddress: tokenAddress,
            creator: msg.sender,
            fundingGoal: fundingGoal,
            fundsRaised: 0,
            isActive: true
        });

        emit ProjectCreated(projectId, tokenAddress, msg.sender);
        return projectId;
    }

    // Función para donar a un proyecto
    function donate(uint projectId) external payable {
        require(projects[projectId].isActive, "Project not active");
        require(msg.value > 0, "Donation must be > 0");
        
        Project storage project = projects[projectId];
        project.fundsRaised += msg.value;

        // Calcular tokens a mintear (1 HBAR = 100 tokens)
        uint tokensToMint = msg.value * 100;
        
        // Mintear tokens usando Hedera Token Service
        (int responseCode) = IHederaTokenService(HEDERA_TOKEN_SERVICE).mintToken(
            project.tokenAddress,
            tokensToMint,
            new bytes[](0)
        );
        
        require(responseCode == 22, "Minting failed");

        // Transferir tokens al donante
        IERC20(project.tokenAddress).transfer(msg.sender, tokensToMint);

        emit DonationReceived(projectId, msg.sender, msg.value, tokensToMint);

        // Verificar si se alcanzó la meta
        if (project.fundsRaised >= project.fundingGoal) {
            _distributeFunds(projectId);
        }
    }

    // Distribuir fondos al creador cuando se alcanza la meta
    function _distributeFunds(uint projectId) internal {
        Project storage project = projects[projectId];
        project.isActive = false;
        
        // Transferir HBAR al creador del proyecto
        payable(project.creator).transfer(project.fundsRaised);
    }
}