// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/access/Ownable.sol";

contract MilestoneVault is Ownable {
    // Estructura para hitos
    struct Milestone {
        uint amount;
        bool approved;
        string description;
        uint deadline;
    }
    
    // Mapeo de proyecto a hitos
    mapping(uint => Milestone[]) public projectMilestones;
    // Fondos bloqueados por proyecto
    mapping(uint => uint) public lockedFunds;
    
    // Eventos
    event MilestoneAdded(uint projectId, uint milestoneId, uint amount);
    event MilestoneApproved(uint projectId, uint milestoneId);
    event FundsReleased(uint projectId, uint milestoneId, uint amount);

    // Añadir un nuevo hito (solo creador del proyecto)
    function addMilestone(
        uint projectId,
        uint amount,
        string memory description,
        uint deadline
    ) external onlyOwner {
        projectMilestones[projectId].push(Milestone({
            amount: amount,
            approved: false,
            description: description,
            deadline: deadline
        }));
        
        emit MilestoneAdded(projectId, projectMilestones[projectId].length - 1, amount);
    }

    // Aprobar un hito (podría ser por votación comunitaria o oráculo)
    function approveMilestone(uint projectId, uint milestoneId) external onlyOwner {
        require(!projectMilestones[projectId][milestoneId].approved, "Already approved");
        require(
            block.timestamp <= projectMilestones[projectId][milestoneId].deadline, 
            "Deadline passed"
        );
        
        projectMilestones[projectId][milestoneId].approved = true;
        emit MilestoneApproved(projectId, milestoneId);
    }

    // Liberar fondos cuando se aprueba el hito
    function releaseFunds(uint projectId, uint milestoneId) external {
        Milestone storage milestone = projectMilestones[projectId][milestoneId];
        require(milestone.approved, "Milestone not approved");
        require(milestone.amount <= lockedFunds[projectId], "Insufficient locked funds");
        
        lockedFunds[projectId] -= milestone.amount;
        payable(owner()).transfer(milestone.amount);
        
        emit FundsReleased(projectId, milestoneId, milestone.amount);
    }

    // Bloquear fondos para un proyecto (llamado desde CrowdFund)
    function lockFunds(uint projectId) external payable {
        lockedFunds[projectId] += msg.value;
    }
}