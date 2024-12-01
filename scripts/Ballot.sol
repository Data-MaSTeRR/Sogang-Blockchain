// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Ballot {

    struct Voter {                     
        uint weight;
        bool voted;
        uint vote;
    }
    struct Proposal {                  
        uint voteCount;
    }

    address public chairperson;
    mapping(address => Voter) voters;  
    Proposal[] proposals;

    
    //modifiers
   
    modifier onlyChair() {
        require(msg.sender == chairperson, "Not a Chairperson");
        _;
    }
     
    modifier validVoter() {
        require(voters[msg.sender].weight > 0, "Not a Registered Voter");
        _;
    }

    constructor (uint numProposals) {
        chairperson = msg.sender;
        
        for (uint8 prop = 0; prop < numProposals; prop ++)
            proposals.push(Proposal(0));
        
    }
    
     
    function register(address voter) public onlyChair {
        if (voter == chairperson)
            voters[chairperson].weight = 2; // weight 2 for testing purposes
        else 
            voters[voter].weight = 1;
        voters[voter].voted = false;
    }

   
    function vote(uint toProposal) public  validVoter {
      
        require (!voters[msg.sender].voted); 
        require (toProposal < proposals.length); 
        
        voters[msg.sender].voted = true;
        voters[msg.sender].vote = toProposal;   
        proposals[toProposal].voteCount += voters[msg.sender].weight;
    }

    function reqWinner() public view returns (uint winningProposal) {
       
        uint winningVoteCount = 0;
        for (uint prop = 0; prop < proposals.length; prop++) 
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                winningProposal = prop;
            }
    }
}
