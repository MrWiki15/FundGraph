// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RewardHub is ReentrancyGuard {
    // Configuración de staking
    uint public constant STAKING_APY = 15; // 15% APY
    uint public constant REWARD_INTERVAL = 1 days;
    uint public constant VIP_THRESHOLD = 1000 * 10**18; // 1000 tokens para rol VIP

    // Mapeos para staking
    mapping(address => uint) public stakedBalances;
    mapping(address => uint) public lastRewardTime;
    mapping(address => uint) public pendingRewards;

    // Mapeo de verificación Discord
    mapping(address => bytes32) public discordVerifications;

    // Eventos
    event Staked(address indexed user, uint amount);
    event RewardClaimed(address indexed user, uint amount);
    event DiscordVerified(address indexed user, bytes32 discordId);

    // Stake tokens para ganar recompensas
    function stakeTokens(address tokenAddress, uint amount) external nonReentrant {
        require(amount > 0, "Amount must be > 0");
        
        // Transferir tokens al contrato
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        
        // Calcular recompensas pendientes
        _calculateRewards(msg.sender);
        
        // Actualizar balance staked
        stakedBalances[msg.sender] += amount;
        lastRewardTime[msg.sender] = block.timestamp;
        
        emit Staked(msg.sender, amount);
    }

    // Retirar tokens staked
    function unstakeTokens(address tokenAddress, uint amount) external nonReentrant {
        require(amount <= stakedBalances[msg.sender], "Insufficient staked balance");
        
        // Calcular recompensas pendientes
        _calculateRewards(msg.sender);
        
        // Actualizar balances
        stakedBalances[msg.sender] -= amount;
        
        // Transferir tokens de vuelta al usuario
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }

    // Reclamar recompensas
    function claimRewards(address tokenAddress) external nonReentrant {
        _calculateRewards(msg.sender);
        uint rewards = pendingRewards[msg.sender];
        require(rewards > 0, "No rewards to claim");
        
        pendingRewards[msg.sender] = 0;
        IERC20(tokenAddress).transfer(msg.sender, rewards);
        
        emit RewardClaimed(msg.sender, rewards);
    }

    // Verificar Discord ID para roles
    function verifyDiscord(bytes32 discordId) external {
        require(
            IERC20(getProjectToken(msg.sender)).balanceOf(msg.sender) >= VIP_THRESHOLD,
            "Insufficient token balance"
        );
        
        discordVerifications[msg.sender] = discordId;
        emit DiscordVerified(msg.sender, discordId);
    }

    // Función interna para calcular recompensas
    function _calculateRewards(address user) internal {
        if (stakedBalances[user] > 0) {
            uint timeElapsed = block.timestamp - lastRewardTime[user];
            uint periods = timeElapsed / REWARD_INTERVAL;
            
            if (periods > 0) {
                uint rewards = (stakedBalances[user] * STAKING_APY * periods) / (365 * 100);
                pendingRewards[user] += rewards;
                lastRewardTime[user] += periods * REWARD_INTERVAL;
            }
        }
    }

    // Función auxiliar para obtener token del proyecto (simplificada)
    function getProjectToken(address user) internal pure returns (address) {
        // En implementación real, mapear usuario a token
        return address(0);
    }
}