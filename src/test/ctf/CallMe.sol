pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Add this import

contract CallMeChallenge {
    bool public isComplete = false;

    function callme() public {
        isComplete = true;
    }
}

contract testDeploy is Test {
    CallMeChallenge CallMeChallengeContract;

    function setUp() public {
        CallMeChallengeContract = new CallMeChallenge();
    }

    function test() public {
        CallMeChallengeContract.callme();
        console.logBool(CallMeChallengeContract.isComplete());
        console.log(
            "test",
            CallMeChallengeContract.isComplete()
        );
    }
}
