pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract DeployChallenge {
    // This tells the CaptureTheFlag contract that the challenge is complete.
    function isComplete() public pure returns (bool) {
        return true;
    }
}

contract testDeploy is Test {
  DeployChallenge  DeployChallengeContract;
  
  function setUp() public {
    DeployChallengeContract = new DeployChallenge();
  }

  function test() public  {
    console.log("DeployChallengeContract",DeployChallengeContract.isComplete());
  }
}