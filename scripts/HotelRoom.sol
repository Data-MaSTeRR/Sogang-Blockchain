// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelRoom {
    // 상태를 나타내는 열거형
    enum Status { Vacant, Occupied }
    Status public currentStatus;

    // 소유자 주소
    address public owner;

    // 이벤트 선언
    event Booked(address indexed _guest, uint _amount);

    // 생성자: 소유자 설정 및 초기 상태를 빈방으로 설정
    constructor() {
        owner = msg.sender;
        currentStatus = Status.Vacant;
    }

    // modifier: 방이 비어 있는지 확인
    modifier onlyWhileVacant() {
        require(currentStatus == Status.Vacant, "Room is already occupied.");
        _;
    }

    // modifier: 금액이 일정 수준 이상인지 확인
    modifier costs(uint _amount) {
        require(msg.value >= _amount, "Insufficient payment.");
        _;
    }

    // modifier: 호출자가 소유자인지 확인
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    // 예약 함수
    function book() public payable onlyWhileVacant costs(10 ether) {
        // 방 상태를 Occupied로 변경
        currentStatus = Status.Occupied;

        // 소유자에게 예약금 송금
        payable(owner).transfer(msg.value);

        // 이벤트 발생
        emit Booked(msg.sender, msg.value);
    }

    // 방 상태를 빈방으로 초기화하는 함수
    function reset() public onlyOwner {
        currentStatus = Status.Vacant;
    }
}
