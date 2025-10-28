/ SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DecentralizedVotingSystem
 * @dev A transparent and secure smart contract for conducting democratic votes
 */
contract DecentralizedVotingSystem {
    
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    address public admin;
    string public electionName;
    bool public votingActive;
    
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    uint256 public candidatesCount;
    uint256 public totalVotes;
    
    event VoterRegistered(address indexed voter);
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStarted();
    event VotingEnded();
    
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        _;
    }
    
    constructor(string memory _electionName) {
        admin = msg.sender;
        electionName = _electionName;
        votingActive = false;
    }
    
    /**
     * @dev Register a voter to participate in the election
     * @param _voter Address of the voter to register
     */
    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");
        require(_voter != address(0), "Invalid voter address");
        
        voters[_voter].isRegistered = true;
        voters[_voter].hasVoted = false;
        
        emit VoterRegistered(_voter);
    }
    
    /**
     * @dev Add a candidate to the election
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) public onlyAdmin {
        require(!votingActive, "Cannot add candidates while voting is active");
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
        
        emit CandidateAdded(candidatesCount, _name);
    }
    
    /**
     * @dev Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) public votingIsActive {
        require(voters[msg.sender].isRegistered, "You are not registered to vote");
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    /**
     * @dev Start the voting process
     */
    function startVoting() public onlyAdmin {
        require(!votingActive, "Voting is already active");
        require(candidatesCount > 0, "No candidates added");
        
        votingActive = true;
        emit VotingStarted();
    }
    
    /**
     * @dev End the voting process
     */
    function endVoting() public onlyAdmin {
        require(votingActive, "Voting is not active");
        
        votingActive = false;
        emit VotingEnded();
    }
    
    /**
     * @dev Get candidate details
     * @param _candidateId ID of the candidate
     */
    function getCandidate(uint256 _candidateId) public view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get the winning candidate
     */
    function getWinner() public view returns (uint256 winnerId, string memory winnerName, uint256 winnerVoteCount) {
        require(!votingActive, "Voting is still active");
        require(candidatesCount > 0, "No candidates available");
        
        uint256 maxVotes = 0;
        uint256 winningCandidateId = 0;
        
        for (uint256 i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winningCandidateId = i;
            }
        }
        
        require(winningCandidateId > 0, "No winner found");
        
        Candidate memory winner = candidates[winningCandidateId];
        return (winner.id, winner.name, winner.voteCount);
    }
    
    /**
     * @dev Get voter information
     * @param _voter Address of the voter
     */
    function getVoterInfo(address _voter) public view returns (
        bool isRegistered,
        bool hasVoted,
        uint256 votedCandidateId
    ) {
        Voter memory voter = voters[_voter];
        return (voter.isRegistered, voter.hasVoted, voter.votedCandidateId);
    }
}
