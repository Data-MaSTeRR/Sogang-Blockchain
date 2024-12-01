// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager; // 관리자 주소
    address[] public players; // 참여자 리스트
    bool public isBettingOpen; // 베팅 가능 여부
    mapping(address => bool) private playerExists; // 참여 여부 확인을 위한 매핑

    // 이벤트 선언
    event PlayerEntered(address indexed player);
    event WinnerPicked(address indexed winner, uint amount);
    event BettingPhaseChanged(bool isOpen);

    // 관리자만 실행할 수 있는 restricted modifier
    modifier restricted() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    // 생성자: 계약 배포자를 관리자(manager)로 설정
    constructor() {
        manager = msg.sender;
        isBettingOpen = true; // 초기 베팅 단계 설정
    }

    // 참여자 목록 반환 함수
    function getPlayers() public view returns (address[] memory) {
        return players;
    }

    // 사용자가 로또에 참여하는 함수
    function enter() public payable {
        require(isBettingOpen, "Betting phase is closed"); // 베팅 가능 여부 확인
        require(msg.value == 1 ether, "Betting amount must be exactly 1 Ether");
        require(!playerExists[msg.sender], "Player has already entered");
        require(msg.sender != manager, "Manager cannot participate"); // 관리자 참여 금지

        players.push(msg.sender);
        playerExists[msg.sender] = true; // 참여 기록 저장

        emit PlayerEntered(msg.sender); // 참가자 정보 이벤트 기록
    }

    // 관리자만 호출 가능한 pickWinner 함수
    function pickWinner() public restricted {
        require(players.length > 0, "No players in the lottery");

        // 베팅 단계가 열려 있으면 닫기
        if (isBettingOpen) {
            setBettingPhase(false);
        }

        // 무작위 인덱스 생성
        uint winnerIndex = _random() % players.length;
        address winner = players[winnerIndex];
        uint prizeAmount = address(this).balance;

        // 컨트랙트 잔액을 승자에게 송금
        payable(winner).transfer(prizeAmount);

        emit WinnerPicked(winner, prizeAmount); // 우승자 정보 이벤트 기록

        // 게임 초기화
        _resetLottery();
    }

    // 무작위 인덱스를 생성하기 위한 내부 함수
    function _random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.number, block.timestamp, players.length)));
    }

    // 로또 초기화 함수
    function _resetLottery() private {
        for (uint i = 0; i < players.length; i++) {
            playerExists[players[i]] = false; // 참여 기록 초기화
        }
        delete players;
        isBettingOpen = true;

        emit BettingPhaseChanged(true); // 초기화 이벤트 기록
    }

    // 베팅 단계 변경 함수 (관리자만 호출 가능)
    function setBettingPhase(bool _isOpen) public restricted {
        require(isBettingOpen != _isOpen, "Betting phase is already in this state");
        isBettingOpen = _isOpen;

        emit BettingPhaseChanged(_isOpen); // 베팅 단계 변경 이벤트 기록
    }
}
