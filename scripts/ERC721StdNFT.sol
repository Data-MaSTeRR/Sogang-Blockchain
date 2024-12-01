// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC165 인터페이스: 컨트랙트가 지원하는 인터페이스를 확인하는 기능 제공
interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// ERC721 인터페이스: NFT 표준 함수 및 이벤트 정의
interface ERC721 is ERC165 {
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

// ERC721TokenReceiver 인터페이스: 안전한 전송 시 받는 컨트랙트가 이 인터페이스를 구현해야 함
interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns (bytes4);
}

// ERC721 표준 NFT 컨트랙트 구현
contract ERC721StdNFT is ERC721 {
    // 컨트랙트 생성자 주소 저장
    address public founder;

    // 토큰 ID와 소유자 매핑
    mapping(uint256 => address) internal _ownerOf;
    // 소유자 주소와 보유 토큰 수 매핑
    mapping(address => uint256) internal _balanceOf;
    // 토큰 ID와 승인된 주소 매핑
    mapping(uint256 => address) internal _approvals;
    // 소유자 주소와 운영자 권한 매핑
    mapping(address => mapping(address => bool)) public _operatorApprovals;

    // NFT 이름과 심볼
    string public name;
    string public symbol;

    // 생성자: 초기화 및 5개의 토큰 생성
    constructor(string memory _name, string memory _symbol) {
        founder = msg.sender; // 컨트랙트 배포자를 founder로 설정
        name = _name; // NFT 이름 설정
        symbol = _symbol; // NFT 심볼 설정
        for (uint256 tokenID = 1; tokenID <= 5; tokenID++) {
            _mint(msg.sender, tokenID); // 초기 토큰 생성
        }
    }

    // 내부 함수: 새 토큰 발행
    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address"); // 0 주소에 민팅 불가
        require(_ownerOf[id] == address(0), "already minted"); // 이미 발행된 토큰은 민팅 불가
        _balanceOf[to]++; // 소유자의 토큰 개수 증가
        _ownerOf[id] = to; // 토큰 소유자 설정
        emit Transfer(address(0), to, id); // Transfer 이벤트 발생
    }

    // 외부 함수: 새 토큰 발행
    function mintNFT(address to, uint256 tokenID) public {
        require(msg.sender == founder, "not an authorized minter"); // 민팅 권한 확인
        _mint(to, tokenID); // 민팅 수행
    }

    // 특정 NFT의 소유자 반환
    function ownerOf(uint256 _tokenId) external view override returns (address) {
        address owner = _ownerOf[_tokenId];
        require(owner != address(0), "token doesn't exist"); // 토큰 존재 확인
        return owner;
    }

    // 특정 주소의 NFT 보유 개수 반환
    function balanceOf(address _owner) external view override returns (uint256) {
        require(_owner != address(0), "balance query for zero address"); // 유효한 주소 확인
        return _balanceOf[_owner];
    }

    // 특정 NFT에 대한 승인된 주소 반환
    function getApproved(uint256 _tokenId) external view override returns (address) {
        require(_ownerOf[_tokenId] != address(0), "token doesn't exist"); // 토큰 존재 확인
        return _approvals[_tokenId];
    }

    // 특정 소유자와 운영자 권한 확인
    function isApprovedForAll(address _owner, address _operator) external view override returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    // 특정 NFT 전송 권한 부여
    function approve(address _approved, uint256 _tokenId) external payable override {
        address owner = _ownerOf[_tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not authorized"
        ); // 권한 확인
        _approvals[_tokenId] = _approved; // 승인된 주소 설정
        emit Approval(owner, _approved, _tokenId); // Approval 이벤트 발생
    }

    // 모든 NFT 전송 권한 설정 또는 해제
    function setApprovalForAll(address _operator, bool _approved) external override {
        _operatorApprovals[msg.sender][_operator] = _approved; // 운영자 권한 설정
        emit ApprovalForAll(msg.sender, _operator, _approved); // ApprovalForAll 이벤트 발생
    }

    // NFT 전송 (외부 함수)
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable override {
        require(
            msg.sender == founder || 
            msg.sender == _ownerOf[_tokenId] ||
            msg.sender == _approvals[_tokenId] ||
            _operatorApprovals[_ownerOf[_tokenId]][msg.sender],
            "not authorized"
        ); // 권한 확인
        _transferFrom(_from, _to, _tokenId); // 내부 전송 로직 호출
    }

    // NFT 전송 (내부 함수)
    function _transferFrom(address _from, address _to, uint256 _tokenId) private {
        address owner = _ownerOf[_tokenId];
        require(_from == owner, "from != owner"); // 소유자 확인
        require(_to != address(0), "transfer to zero address"); // 유효한 주소 확인

        _balanceOf[_from]--; // 발신자의 토큰 개수 감소
        _balanceOf[_to]++; // 수신자의 토큰 개수 증가
        _ownerOf[_tokenId] = _to; // 소유권 이전

        delete _approvals[_tokenId]; // 기존 승인 정보 삭제
        emit Transfer(_from, _to, _tokenId); // Transfer 이벤트 발생
    }

    // 안전한 NFT 전송 (데이터 포함)
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable override {
        _safeTransferFrom(_from, _to, _tokenId, data);
    }

    // 안전한 NFT 전송 (데이터 없이)
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable override {
        _safeTransferFrom(_from, _to, _tokenId, "");
    }

    // 내부 함수: 안전한 NFT 전송
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) internal {
        require(
            msg.sender == founder || 
            msg.sender == _ownerOf[_tokenId] ||
            msg.sender == _approvals[_tokenId] ||
            _operatorApprovals[_ownerOf[_tokenId]][msg.sender],
            "not authorized"
        ); // 권한 확인

        _transferFrom(_from, _to, _tokenId); // 일반 전송 로직 호출

        require(
            _to.code.length == 0 ||
            ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) ==
            ERC721TokenReceiver.onERC721Received.selector,
            "unsafe recipient"
        ); // 수신자가 컨트랙트일 경우 인터페이스 구현 확인
    }

    // 컨트랙트가 특정 인터페이스를 지원하는지 확인
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(ERC721).interfaceId ||
            interfaceId == type(ERC165).interfaceId;
    }
}
