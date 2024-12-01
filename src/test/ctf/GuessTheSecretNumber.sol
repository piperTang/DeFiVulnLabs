pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract GuessTheSecretNumberChallenge {
    bytes32 answerHash =
        0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);

        if (keccak256(abi.encodePacked(n)) == answerHash) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract exploited is Test {
    GuessTheSecretNumberChallenge public guessContract;

    function setUp() public {
        // 给测试合约充足的 ETH
        vm.deal(address(this), 10 ether);

        guessContract = new GuessTheSecretNumberChallenge{value: 1 ether}();
    }

    function testGuess() public {
        bytes32 targetHash = 0xdb81b4d58595fbbbb592d3661a34cdca14d7ab379441400cbfa1b78bc447c365;
        console.log("before", address(this).balance / 1e18, "ETH");
        console.log(
            "before GuessTheSecretNumberChallenge contract",
            address(guessContract).balance / 1e18,
            "ETH"
        );
        require(address(guessContract) != address(0), "Contract not deployed");

        // 遍历所有可能的 uint8 值（0-255）并打印匹配的结果
        for (uint8 i = 0; i < 255; i++) {
            bytes32 hash = keccak256(abi.encodePacked(i));
            if (hash == targetHash) {
                console.log("Found match! Number:", i);
                console.logBytes32(hash);
                guessContract.guess{value: 1 ether}(i);
                break;
            }
        }
        console.log("after", address(this).balance / 1e18, "ETH");
        console.log(
            "after GuessTheSecretNumberChallenge contract",
            address(guessContract).balance / 1e18,
            "ETH"
        );

        // 验证是否完成挑战
        assertTrue(guessContract.isComplete());
    }

    receive() external payable {}
}
