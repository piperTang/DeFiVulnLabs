pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Add this import

contract GuessTheNewNumberChallenge {
    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));

        if (n == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract testDeploy is Test {
    GuessTheNewNumberChallenge public guessContract;

    function setUp() public {
        vm.deal(address(this), 10 ether);
        guessContract = new GuessTheNewNumberChallenge{value: 1 ether}();
    }

    function testGuess() public {
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
        // 确保合约部署成功
        console.log("before", address(this).balance / 1e18, "ETH");

        // 调用 guess 函数并转入 1 ether
        guessContract.guess{value: 1 ether}(answer);
        console.log("after", address(this).balance / 1e18, "ETH");

        // 验证是否完成挑战
        assertTrue(guessContract.isComplete());
    }

    receive() external payable {}
}
