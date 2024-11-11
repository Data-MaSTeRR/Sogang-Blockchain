// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding {
    
    struct Investor {
        address addr; // 투자자 주소
        uint amount; // 투자액
    }
    
    // investors 배열
    mapping(uint => Investor) public investors; // 투자자 추가할 때 key 증가

    address public owner; // 컨트랙트 소유자
    uint public numInvestors; // 투자자 수
    uint public deadline; // 마감일
    string public status; // 모금활동 상태(Funding, Campaign Succeeded, Campaign Failed)
    bool public ended; // 모금 종료여부
    uint public goalAmount; // 목표액
    uint public totalAmount; // 총 투자액

    modifier onlyOwner() {
        require(msg.sender == owner, "Error: caller is not the owner");
        _;
    }

    // 초기 설정: 컨트랙트의 소유자를 설정하거나 목표 금액, 마감일 등을 설정
    constructor(uint _duration, uint _goalAmount) {
        owner = msg.sender;

        deadline = block.timestamp + _duration;
        goalAmount = _goalAmount * 1 ether;
        status = "Funding";
        ended = false;

        numInvestors = 0;
        totalAmount = 0;
    }

    // 투자자가 투자할 때 호출하는 함수
    function fund() public payable {
        require(!ended, "Funding has ended"); // 모금이 끝나지 않아야,
        require(block.timestamp < deadline, "Deadline has passed"); // 마감일이 지나지 않아야,
        require(msg.value > 0, "Investment must be greater than 0"); // 투자금이 0보다 커야, funding이 가능

        investors[numInvestors] = Investor(msg.sender, msg.value); // 투자자 정보를 매핑에 저장
        numInvestors++; // 투자자 수 업데이트
        totalAmount += msg.value; // 총 투자액 업데이트
    }

    // 소유자가 모금을 종료할 때 호출하는 함수
    function checkGoalReached() public onlyOwner {
        require(block.timestamp >= deadline, "Campaign is still ongoing"); // 마감일이 지나야 모금 종료가능
        require(!ended, "Campaign already ended"); // 이미 모금을 종료했으면 모금을 다시 종료할 수 없음

        if (totalAmount >= goalAmount) {
            // 목표액 달성 시, 소유자에게 모든 이더 송금
            status = "Campaign Succeeded";
            payable(owner).transfer(totalAmount);
        } else {
            // 목표액 미달성 시, 투자자들에게 투자금 반환
            status = "Campaign Failed";
            for (uint i = 0; i < numInvestors; i++) {
                payable(investors[i].addr).transfer(investors[i].amount);
            }
        }

        ended = true;
    }

}
