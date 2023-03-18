// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract Ballot {

  struct Voter {
    uint weight;
    bool voted;
    uint vote;
  }

  struct Candidate {
    string name;
    uint voteCount;
  }

  address public chairperson;

  mapping (address => Voter) public voters;

  Candidate[] public candidates;

  enum State { Created, Started, Ended }

  State public state;

  constructor (string[] memory candidateNames) {
    require(candidateNames.length <= 5, "only 5 candidate is allowed");
    chairperson = msg.sender;
    voters[chairperson].weight = 1;
    state = State.Created;

    for (uint i = 0; i < candidateNames.length; i++) {
      candidates.push(Candidate({
        name: candidateNames[i],
        voteCount: 0
      }));
    }
  }

  modifier SmartContractOwner() {
    require(msg.sender == chairperson, "only chairperson can start and end voting");
    _;
  }

  modifier CreatedState() {
    require(state == State.Created, "it must be in started");
    _;
  }

  modifier StartedState() {
    require(state == State.Started, "it must be in voting period");
    _;
  }

  modifier EndedState() {
    require(state == State.Ended, "it must be in Ended period");
    _;
  }

  function addCandidates(string[] memory candidateNames) public EndedState {
    state = State.Created;
     for (uint i = 0; i < candidateNames.length; i++) {
      candidates.push(Candidate({
        name: candidateNames[i],
        voteCount: 0
      }));
    }
  }

  function startVote() public SmartContractOwner CreatedState {
    state = State.Started;
  }

  function endVote() public SmartContractOwner StartedState {
    state = State.Ended;
  }

  function giveRightToVote(address voter) public SmartContractOwner StartedState {
    require(!voters[voter].voted, "The voter already voted.");
    require(voters[voter].weight == 0);

    voters[voter].weight = 1;
  }

  function vote(uint candidate) public StartedState {
    Voter storage sender = voters[msg.sender];
    require(sender.weight != 0, "Needs to be given right to vote");
    require(!sender.voted, "Already Voted.");

    sender.voted = true;
    sender.vote = candidate;

    candidates[candidate].voteCount += sender.weight;
  }

  function winner() public EndedState view returns (string memory winnerName_) {
    uint winnerVoteCount = 0;
    for (uint i = 0; i < candidates.length; i++) {
      if(candidates[i].voteCount > winnerVoteCount) {
        winnerVoteCount = candidates[i].voteCount;
        winnerName_ = candidates[i].name;
      }
    }
  }
}