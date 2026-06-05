// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IWorldIdRouter {
    /**
     * @notice Cryptographically validates a World ID identity proof block.
     */
    function verifyProof(
        uint256 root,
        uint256 signalHash,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external view;
}

contract ZkGovernancePortal is Ownable {
    IWorldIdRouter public immutable worldIdRouter;

    struct Proposal {
        string descriptionIpfsHash;
        uint256 forVotes;
        uint256 againstVotes;
        bool active;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    
    // Maps a unique composite key (proposalId XOR nullifierHash) to voting status to ensure true Sybil resistance
    mapping(uint256 => bool) public nullifierVotes;

    event ProposalCreated(uint256 indexed proposalId, string descriptionIpfsHash);
    event VoteRecorded(uint256 indexed proposalId, bool support, uint256 currentFor, uint256 currentAgainst);

    constructor(address _worldIdRouter) Ownable(msg.sender) {
        worldIdRouter = IWorldIdRouter(_worldIdRouter);
    }

    function createProposal(string calldata ipfsHash) external onlyOwner {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            descriptionIpfsHash: ipfsHash,
            forVotes: 0,
            againstVotes: 0,
            active: true
        });

        emit ProposalCreated(proposalCount, ipfsHash);
    }

    /**
     * @notice Submits a Sybil-resistant, zero-knowledge biometric vote on an active proposal.
     */
    function castDemocraticVote(
        uint256 proposalId,
        bool support,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external {
        Proposal storage prop = proposals[proposalId];
        require(prop.active, "GovError: Target proposal is inactive");

        // Derive unique composite identifier to prevent identical human identities from dual-voting on this specific proposal
        uint256 uniqueVoteKey = uint256(keccak256(abi.encodePacked(proposalId, nullifierHash)));
        require(!nullifierVotes[uniqueVoteKey], "GovError: This identity has already voted on this proposal");

        // The signal hash securely binds the user's intended choice (support/against) to the validity proof payload
        uint256 signalHash = uint256(keccak256(abi.encodePacked(support)));

        // Call out to external World ID verification architecture
        worldIdRouter.verifyProof(
            root,
            signalHash,
            nullifierHash,
            proof
        );

        // Commit unique vote signature key to storage to isolate user interactions
        nullifierVotes[uniqueVoteKey] = true;

        if (support) {
            prop.forVotes++;
        } else {
            prop.againstVotes++;
        }

        emit VoteRecorded(proposalId, support, prop.forVotes, prop.againstVotes);
    }
}
