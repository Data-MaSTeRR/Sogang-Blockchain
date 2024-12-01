// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20StdToken {
    
    // 각 주소별 잔액을 저장하는 매핑
    mapping (address => uint256) balances;
    // 계정별로 다른 주소에 대해 허용된 금액을 저장하는 매핑
    mapping (address => mapping (address => uint256)) allowed;
    // 전체 토큰의 총 발행량
    uint256 private total;
    // 토큰의 이름
    string public name;
    // 토큰의 심볼
    string public symbol;
    // 토큰의 소수점 자리 수 (여기서는 0으로 설정)
    uint8 public decimals;

    // 토큰 전송 이벤트
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 승인 이벤트
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // 컨트랙트 생성자: 이름, 심볼, 총 발행량을 설정하고 배포자에게 모든 토큰을 할당
    constructor(string memory _name, string memory _symbol, uint _totalSupply) {
        total = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = 0;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0x0), msg.sender, _totalSupply);
    }

    // 전체 토큰의 총 발행량을 반환
    function totalSupply() public view returns (uint256) {
        return total;
    }

    // 특정 주소가 소유한 토큰 수를 반환
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    // 특정 주소가 다른 주소에 대해 인출을 허용한 토큰 수를 반환
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // 토큰 전송 함수: 발신자에서 특정 주소로 _value 만큼의 토큰을 전송
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // 위임된 토큰 전송 함수: _from에서 _to로 _value 만큼의 토큰을 전송 (발신자가 위임받은 경우)
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowed[_from][msg.sender] >= _value, "Allowance exceeded");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // 토큰 소유자가 다른 주소에게 일정량의 토큰을 사용할 수 있는 권한을 부여
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}

