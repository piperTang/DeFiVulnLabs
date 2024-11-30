pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract GuessTheNumberChallenge {
    uint8 answer = 42;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (n == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract exploited is Test {
    GuessTheNumberChallenge public guessContract;

    function setUp() public {
        // 给测试合约充足的 ETH
        vm.deal(address(this), 10 ether);
        
        // 使用 try-catch 来部署合约，这样可以看到具体的错误信息
        try new GuessTheNumberChallenge{value: 1 ether}() returns (GuessTheNumberChallenge _contract) {
            guessContract = _contract;
        } catch Error(string memory reason) {
            console.log("Failed to deploy:", reason);
            revert(reason);
        }
    }

    function testGuess() public {
        // 确保合约部署成功
        console.log("before",address(this).balance/1e18,"ETH");
        require(address(guessContract) != address(0), "Contract not deployed");
        
        // 调用 guess 函数并转入 1 ether
        guessContract.guess{value: 1 ether}(42);
        console.log("after",address(this).balance/1e18,"ETH");
        
        // 验证是否完成挑战
        // assertTrue(guessContract.isComplete());
    }
    receive() external payable {}
}
