// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract MyGovernor is Governor, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
    uint256 public votingDelayValue;
    uint256 public votingPeriodValue;

    constructor(
        IVotes token,
        uint256 delay,
        uint256 period,
        uint256 quorumPercentage
    )
        Governor("MyGovernor")
        GovernorVotes(token)
        GovernorVotesQuorumFraction(quorumPercentage)
    {
        votingDelayValue = delay;
        votingPeriodValue = period;
    }

    function votingDelay() public view override returns (uint256) {
        return votingDelayValue;
    }

    function votingPeriod() public view override returns (uint256) {
        return votingPeriodValue;
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }
}
