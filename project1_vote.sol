// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";



contract Voting is Ownable{

    uint proposalId;
    uint winningProposalId;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    mapping (address => Voter) public voter;
    Proposal[] public proposals;
    WorkflowStatus public workflowStatus;


    event VoterRegistered(address voterAddress, uint timestamp); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus, uint timestamp);
    event ProposalRegistered(uint proposalId, uint timestamp);
    event Voted (address voter, uint proposalId, uint timestamp);
   

   // Changes the workflow status & emits an event that tells the previous status and the new status
   function workflowStatusChanges (uint _status) public onlyOwner {
        require (_status >= 1 && _status < 6, "You don't have a workflow at this index");

        workflowStatus = WorkflowStatus(_status);
        emit WorkflowStatusChange(WorkflowStatus(_status - 1), WorkflowStatus(_status), block.timestamp);
   }

    // View the current workflow status
    function getWorkflowStatus() public view returns (WorkflowStatus) {
        return workflowStatus;
    }

    // Register the Voters
    function RegisteringVoters (address _voterAddress) public onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "Voter registration is closed.");
        require(!voter[_voterAddress].isRegistered, "Voter already registered");

        voter[_voterAddress].isRegistered = true;
        emit VoterRegistered(_voterAddress, block.timestamp);
    }  

    // Register a proposition
    function ProposalRegistration(string memory _description) public {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Proposal registration is closed.");
        require(voter[msg.sender].isRegistered, "You are not registrered to add a proposition.");

        proposals.push(Proposal(_description, 0));
        emit ProposalRegistered(proposalId, block.timestamp);
        proposalId++;
    }

    // Show the proposals registered
    function ProposalView(uint _proposalId) public view returns(string memory proposal) {
        return proposal = proposals[_proposalId].description;
    }

    // Register a vote
    function VotingProposal(uint _proposalIdVote) public {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "Voting session is closed.");
        require(voter[msg.sender].isRegistered, "You are not registrered to vote."); 
        require(!voter[msg.sender].hasVoted, "You already voted."); 

        proposals[_proposalIdVote].voteCount++;
        voter[msg.sender].hasVoted = true;
        voter[msg.sender].votedProposalId = _proposalIdVote;
        emit Voted (msg.sender, _proposalIdVote, block.timestamp);
    }

    // Show the participants
    function ParticipantsVoteView(address _address) public view returns(uint vote) {
        require(voter[msg.sender].isRegistered, "You are not registrered to vote."); 
        require(voter[_address].isRegistered, "The participant you entered is not registered for this vote."); 

        return vote = voter[_address].votedProposalId;
    }

    // Count the winning proposition
    function countVotes() public onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Voting session has not ended.");
        
        uint winningVoteCount = 0;
        
        for ( uint i = 0; i < proposals.length; i++) {
            if(proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            } 
        } 
        workflowStatusChanges(5);
    }

    // View the winning proposition
    function getWinner() public view returns (uint finalWinningProposalId) {
        require(voter[msg.sender].isRegistered, "You are not registrered to this vote."); 
        require(workflowStatus == WorkflowStatus.VotesTallied, "The votes aren't tallied yet.");

        return finalWinningProposalId = winningProposalId;
    }

}
