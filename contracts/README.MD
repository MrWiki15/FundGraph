# FundGraph Smart Contracts (Experimental Stage)

**⚠️ Warning:** These contracts are experimental and not part of the currently published MVP. Production use requires additional audits.

## Contract Architecture

### 1. `TokenFactory.sol`

- **Purpose:** HRC-20/HRC-721 token factory
- **Key Features:**
  - 5-second token creation (~$0.001 USD)
  - Auto-configures token properties
  - Native Hedera Token Service integration
- **Status:** Internal testing

### 2. `CrowdFund.sol`

- **Purpose:** Core fundraising engine
- **Workflow:**
  1. Create project with funding goal
  2. Accept HBAR donations
  3. Mint proportional tokens
  4. Release funds when goal met
- **Limitations:**
  - HBAR-only (no ERC-20 support)
  - Missing 2% fee implementation

### 3. `MilestoneVault.sol`

- **Purpose:** Conditional fund management
- **Mechanism:**  
  Donations → Locked funds → Milestone approval → Partial release
- **Warnings:**
  - Missing voting system
  - Requires oracle integration

### 4. `RewardHub.sol`

- **Purpose:** Reward ecosystem
- **Components:**
  - 15% APY staking
  - Discord role verification
  - Physical/digital rewards
- **Known Risks:**
  - Flash loan vulnerabilities
  - Centralized VIP role assignment

## Current Status

| Contract       | Audited | In MVP | Notes                  |
| -------------- | ------- | ------ | ---------------------- |
| TokenFactory   | ❌      | ❌     | Internal testing       |
| CrowdFund      | ❌      | ❌     | Needs gas optimization |
| MilestoneVault | ❌      | ❌     | PoC only               |
| RewardHub      | ❌      | ❌     | Active development     |
