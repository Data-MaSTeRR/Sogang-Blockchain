// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    // 각 사용자의 계정주소에 잔액을 매핑
    mapping(address => uint256) private balances;

    // Deposit 및 Withdrawal 이벤트 -> indexed를 활용하여 특정 계정주소에서 발생한 이벤트를 빠르게 찾을 수 있음.
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);

    // 컨트랙트 소유자의 주소를 저장 -> owner는 컨트랙트 내에서만.. private 변수
    address private owner;

    // 소유자만 실행할 수 있는 함수에 적용할 modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Error: caller is not the owner");
        _;
    }

    // 컨트랙트 생성자 함수: 소유자 주소를 설정
    constructor() {
        owner = msg.sender;
    }

    // 입금 함수: 이더를 컨트랙트에 입금하고 이벤트를 발생시킴
    function deposit() public payable {
        require(msg.value > 0, "Error: Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value); // Deposit 이벤트 발생
    }

    // 출금 함수: 자신의 계정에서 지정한 이더를 출금하고 이벤트를 발생시킴
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Error: Balance is not enough to withdraw");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount); // Withdrawal 이벤트 발생
    }

    // 잔액 조회 함수: 호출자의 본인의 계정 잔고를 반환
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    // 컨트랙트 잔액 조회 함수: 오직 소유자만 호출 가능
    function getContractBalance() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
