# World ID ZK Governance Shield

In the DAO and decentralized governance models of 2026, standard token-weighted voting structures frequently devolve into plutocracies where whales dictate project directions. This repository implements a professional-grade **Sybil-Resistant Democratic Governance Engine** utilizing **World ID**.

By verifying unique human identities via biometric zero-knowledge proofs (ZKPs), this framework allows DAOs to execute democratic, one-person-one-vote paradigms alongside or instead of token-weighted voting, protecting governance proposals from flash-loan manipulation and bot networks.

## Governance Workflow
1. **Proposal Creation:** An admin or qualified participant posts a structured proposal hash on-chain.
2. **Proof Generation:** Voters verify their uniqueness inside the World App to generate a cryptographic ZK-proof bound to that specific proposal.
3. **Vote Cast:** The contract verifies the proof via the World ID Router precompile, tracking unique nullifiers to ensure each verified human votes exactly once per proposal.

## Setup Instructions
1. Install project dependencies: `npm install`
2. Configure your specific `app_id` and contract configurations inside `.env`.
3. Compile smart contracts using Hardhat: `npx hardhat compile`
4. Run the end-to-end proposal and voting simulation loop: `node simulateGovernance.js`
