// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract bet {

    event NewBet(
    address addr, 
    uint amount, 
    Team teamBet
    );

    struct Bet {
    //string name;
    address addr;
    uint amount;
    Team teamBet;
    }

    struct Team {
        uint teamId;
        string teamName;
        uint totalBetAmount;
    }
/*
    struct Match {
        Team team1;
        Team team2;
    }
*/
   
    Bet[] public bets;
    Team[] public teams;
    //Match[] public oldMatches;
    uint public oldBetLength = 0;
        
    address payable conOwner;
    uint public totalBetMoney = 0;

    mapping (address => uint) public numBetsAddress;

    constructor() payable {
        conOwner = payable(msg.sender);
        teams.push(Team(0, "team0", 0));
        teams.push(Team(1, "team1", 0));

    }

    function getOwner() public view returns (address) {
        return (conOwner);
    }

    modifier onlyOwner() {
        require(conOwner == msg.sender, "Must be Contract Owner to do this");
        _;
    }
/*
    function updateTeamName(uint _teamId, string memory _name) public onlyOwner() {
        teams[_teamId].teamName = _name; 
    }
*/
    function createNewMatch(string memory _name0, string memory _name1) public onlyOwner() {
        teams[0].teamName = _name0;
        teams[1].teamName = _name1; 
        teams[0].totalBetAmount=0;
        teams[1].totalBetAmount=0;     
    }

    function getTeamTotalBetAmount (uint _teamId) public view returns (uint) {
        return teams[_teamId].totalBetAmount;
    }

    function createBet ( uint _teamId) external payable {       
        require (msg.sender != conOwner, "Contract owner can't make a bet");
        require (numBetsAddress[msg.sender] == 0, "you have already placed a bet");
        require (_teamId < teams.length, "Bet must be an active team");
        require (msg.value > 100000 wei, "Minimum bet must be larger than 100000 wei");

        bets.push(Bet(msg.sender, msg.value, teams[_teamId]));

        if (_teamId == 0) {
            teams[0].totalBetAmount += msg.value;
        } 
        if (_teamId == 1) {
            teams[1].totalBetAmount += msg.value;
        }

        numBetsAddress[msg.sender]++;

        //conOwner.transfer(msg.value);

        totalBetMoney += msg.value;

        emit NewBet(msg.sender, msg.value, teams[_teamId]);

    }

    function teamWinDistribution(uint winningTeamId) public payable onlyOwner() {
        require(winningTeamId < teams.length, "Winning team must be a valid ID");

        uint distro;
        if (winningTeamId == 0) {
            for (uint i = oldBetLength; i < bets.length; i++) {
                if (bets[i].teamBet.teamId == 0) {
                    address payable receiver = payable(bets[i].addr);
                    distro = (bets[i].amount * (10000 + (getTeamTotalBetAmount(1) * 10000 / getTeamTotalBetAmount(0)))) / 10000;
                    receiver.transfer(distro);                   
                }
            }
        } else {
            for (uint i = oldBetLength; i < bets.length; i++) {
                if (bets[i].teamBet.teamId == 1) {
                    address payable receiver = payable(bets[i].addr);
                    distro = (bets[i].amount * (10000 + (getTeamTotalBetAmount(0) * 10000 / getTeamTotalBetAmount(1)))) / 10000;

                    receiver.transfer(distro);
                }
            }
        }

        totalBetMoney = 0;
        teams[0].totalBetAmount = 0;
        teams[1].totalBetAmount = 0;

        for (uint i = 0; i < bets.length; i++) {
            numBetsAddress[bets[i].addr] = 0;
            bets[i].amount = 0;
        }
        oldBetLength = bets.length;

    }

}