// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NameResgitry {
    
    struct ContractInfo {
        address contractOwner;
        address contractAddress;
        string description;
    }

    address public owner; // NameRegistry의 소유자
    uint public numContracts; // 등록된 계약의 수

    mapping(string => ContractInfo) public registeredContracts;

    // NameRegistry의 소유자(전체 관리자)가 전체 계약들을 관리하는데 사용 -> unregisterContract 함수
    modifier onlyOwner() {
        require(msg.sender == owner, "Error: caller is not the contract manager");
        _;
    }

    // 특정 계약의 소유자만 그 계약에 접근할 수 있게함 -> 개별 계약의 정보를 바꿀 때 사용
    modifier onlyContractOwner(string memory _name) {
        require(msg.sender == registeredContracts[_name].contractOwner, "Error: caller is not the contract owner");
        _;
    }

    // 초기 설정: 계약 배포 시 소유자를 설정하고 계약 수를 0으로 초기화
    constructor() {
        owner = msg.sender;
        numContracts = 0;
    }

    // 컨트랙트 안에 주소정보가 없으면 컨트랙트 등록
    function registerContract(string memory _name, address _contractAddress, string memory _description) public {
        require(registeredContracts[_name].contractAddress == address(0), "Contract with this name already registered");
        
        registeredContracts[_name] = ContractInfo({
            contractOwner: msg.sender,
            contractAddress: _contractAddress,
            description: _description
        });
        
        numContracts++; // 계약 수 증가
    }
    
    // 특정 계약의 주소가 있으면 해당 그 계약을 삭제 (NameRegistry의 소유자만 가능)
    function unregisterContract(string memory _name) public onlyOwner {
        require(registeredContracts[_name].contractAddress != address(0), "Contract does not exist");

        delete registeredContracts[_name]; // 등록된 계약 삭제
        numContracts--; // 계약 수 감소
    }

    // 특정 계약의 새 소유자가 주소정보를 가지고 있으면 소유자 변경 (특정 계약 소유자만 가능)
    function changeOwner(string memory _name, address _newOwner) public onlyContractOwner(_name) {
        require(_newOwner != address(0), "Invalid new owner address");
        registeredContracts[_name].contractOwner = _newOwner;
    }

    // 특정 계약의 소유자 주소를 반환
    function getOwner(string memory _name) public view returns (address) {
        require(registeredContracts[_name].contractAddress != address(0), "Contract does not exist");
        return registeredContracts[_name].contractOwner;
    }

    // 특정 계약의 주소 변경 (특정 계약 소유자만 가능)
    function setAddr(string memory _name, address _addr) public onlyContractOwner(_name) {
        require(_addr != address(0), "Invalid address");
        registeredContracts[_name].contractAddress = _addr;
    }

    // 특정 계약의 주소를 반환
    function getAddr(string memory _name) public view returns (address) {
        require(registeredContracts[_name].contractAddress != address(0), "Contract does not exist");
        return registeredContracts[_name].contractAddress;
    }

    // 특정 계약의 설명 변경 (특정 계약 소유자만 가능)
    function setDescription(string memory _name, string memory _description) public onlyContractOwner(_name) {
        registeredContracts[_name].description = _description;
    }

    // 특정 계약의 설명을 반환
    function getDescription(string memory _name) public view returns (string memory) {
        require(registeredContracts[_name].contractAddress != address(0), "Contract does not exist");
        return registeredContracts[_name].description;
    }
    
}
