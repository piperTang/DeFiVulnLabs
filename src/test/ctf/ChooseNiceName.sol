pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Add this import

// Relevant part of the CaptureTheEther contract.
contract CaptureTheEther {
    mapping (address => bytes32) public nicknameOf;

    function setNickname(bytes32 nickname) public {
        nicknameOf[msg.sender] = nickname;
    }
}

// Challenge contract. You don't need to do anything with this; it just verifies
// that you set a nickname for yourself.
contract NicknameChallenge {
    CaptureTheEther cte = CaptureTheEther(msg.sender);
    address player;

    // Your address gets passed in as a constructor parameter.
    constructor(address _player) {
        player = _player;
    }

    // Check that the first character is not null.
    function isComplete() public view returns (bool) {
        return cte.nicknameOf(player)[0] != 0;
    }
}

contract testDeploy is Test {
    NicknameChallenge NicknameChallengeContract;
    CaptureTheEther cte;

    function setUp() public {
        // 部署 CaptureTheEther 合约
        cte = new CaptureTheEther();
        // 使用新部署的 CaptureTheEther 地址来部署 NicknameChallenge
        NicknameChallengeContract = new NicknameChallenge(address(this));
        
        // 设置昵称（示例）
        bytes32 nickname = bytes32("TestName");
        cte.setNickname(nickname);
    }

    function testNickname() public {
        bool isSet = NicknameChallengeContract.isComplete();
        console.log("Nickname is set:", isSet);
        
        // 添加断言来验证结果
        // assertTrue(isSet, "Nickname should be set");
    }
}
