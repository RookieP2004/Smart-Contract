// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract VotingSystem {
    struct Voter {
        bool registered;
        bool voted;
    }

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    address public owner;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor(address _owner, string[] memory candidateNames) {
        owner = _owner;
        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                id: i,
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }

    function registerVoter(address voter) public onlyOwner {
        if (voters[voter].registered) {
            revert("Voter is already registered");
        }
        voters[voter] = Voter({
            registered: true,
            voted: false
        });
    }

    function vote(uint candidateId) public {
        Voter storage sender = voters[msg.sender];
        if (!sender.registered) {
            revert("You must be registered to vote");
        }
        if (sender.voted) {
            revert("You have already voted");
        }
        if (candidateId >= candidates.length) {
            revert("Invalid candidate ID");
        }

        candidates[candidateId].voteCount += 1;
        sender.voted = true;

        // Ensure the vote count is not negative (just for demonstration)
        assert(candidates[candidateId].voteCount > 0);
    }

    function getCandidate(uint candidateId) public view returns (string memory, uint) {
        if (candidateId >= candidates.length) {
            revert("Invalid candidate ID");
        }
        Candidate memory candidate = candidates[candidateId];
        return (candidate.name, candidate.voteCount);
    }

    function endElection() public view onlyOwner {
        uint numCandidatesWithVotes = 0;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > 0) {
                numCandidatesWithVotes += 1;
            }
        }
        if (numCandidatesWithVotes < 2) {
            revert("Election must have at least two candidates with votes");
        }

        // Announce the winner
        uint winningVoteCount = 0;
        uint winningCandidateId;
        for (uint i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }

        // Here, you might emit an event with the winner's information (not shown)
    }
}
