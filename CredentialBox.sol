// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.10;

abstract contract OwnerHelper {
    address private owner;

    event OwnerTransferPropose(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() {
		owner = msg.sender;
  	}

    function transferOwnership(address _to) onlyOwner public {
        require(_to != owner);
        require(_to != address(0x0));
        emit OwnerTransferPropose(owner, _to);
    	owner = _to;
  	}
}

// IssuerHelper에서는 Issuer를 추가하고 삭제하는 기능이 존재합니다. 추가하고 삭제하는 기능은 onlyOwner로 제한되어 Owner만 컨트롤이 가능합니다.
abstract contract issuerHelper is OwnerHelper {
    mapping(address => bool) public issuers;

    event AddIssuer(address indexed _issuer);
    event DelIssuer(address indexed _issuer);

    modifier onlyIssuer {
        require(isIssuer(msg.sender) == true);
        _;
    }

    constructor() {
        issuers[msg.sender] = true;
    }

    function isIssuer(address _addr) public view returns (bool) {
        return issuers[_addr];
    }

    function addIssuer(address _addr) onlyOwner public returns (bool) {
        require(issuers[_addr] == false);
        issuers[_addr] = true;
        emit AddIssuer(_addr);
        return true;
    }

    function delIssuer(address _addr) onlyOwner public returns (bool) {
        require(issuers[_addr] == true);
        issuers[_addr] = false;
        emit DelIssuer(_addr);
        return true;
    }
}

contract CredentialBox is issuerHelper {
    uint256 private idCount;
    mapping(uint8 => string) private alumniEnum;
    mapping(uint8 => string) private statusEnum;

    // claimCredential에서 block.timestamp를 활용해 크리덴셜을 클레임한 시간을 크리덴셜에 저장할 수 있습니다.
    struct Credential{
        uint256 id;
        address issuer;
        uint8 alumniType;
        uint8 statusType;
        string value;
        uint256 createDate;
    }

    mapping(address => Credential) private credentials;

    constructor() {
        idCount = 1;
        alumniEnum[0] = "SEB";
        alumniEnum[1] = "BEB";
        alumniEnum[2] = "AIB";        
    }

    function claimCredential(address _alumniAddress, uint8 _alumniType, string calldata _value) public onlyOwner returns(bool) {
        Credential storage credential = credentials[_alumniAddress];
        require(credential.id == 0);
        credential.id = idCount;
        credential.issuer = msg.sender;
        credential.alumniType = _alumniType;
        credential.statusType = 0;
        credential.value = _value;
        credential.createDate = block.timestamp;

        idCount++;

        return true;
    }
    
    function getCredential(address _alumniAddress) public view returns(Credential memory) {
        return credentials[_alumniAddress];
    }

/*
솔리디티 내부에는 String을 검사하는 두 가지 방법이 있습니다.
첫 번째는 bytes로 변환하여 길이로 null인지 검사하는 방법, 두 번째는 keccak256 함수를 사용하여 두 스트링을 해쉬로 변환하여 비교하는 방법입니다. 
위의 코드에서는 첫 번째 방법을 이용하여 내부 alumniEnum의 Type이 중복되는 타입이 존재하는지 검사했습니다.
*/
    function addAlumniType(uint8 _type, string calldata _value) onlyIssuer public returns(bool) {
        require(bytes(alumniEnum[_type]).length == 0);
        alumniEnum[_type] = _value;
        return true;
    }

    function getAlumniType(uint8 _type) public view returns(string memory) {
        return alumniEnum[_type];
    }

    function addStatusType(uint8 _type, string calldata _value) onlyIssuer public returns(bool) {
        require(bytes(statusEnum[_type]).length == 0);
        statusEnum[_type] = _value;
        return true;
    }

    function getStatusType(uint8 _type) public view returns(string memory) {
        return statusEnum[_type];
    }

    function changeStatus(address _alumni, uint8 _type) onlyIssuer public returns (bool) {
        require(credentials[_alumni].id != 0);
        require(bytes(statusEnum[_type]).length != 0);
        credentials[_alumni].statusType = _type;
        return true;
    }
}

// contract CredentialBox {
//     address private issuerAddress;
//     uint256 private idCount;
//     mapping(uint8 => string) private alumniEnum;

//     struct Credential{
//         uint256 id;
//         address issuer;
//         uint8 alumniType;
//         string value;
//     }

//     mapping(address => Credential) private credentials;

//     constructor() {
//         issuerAddress = msg.sender;
//         idCount = 1;
//         alumniEnum[0] = "SEB";
//         alumniEnum[1] = "BEB";
//         alumniEnum[2] = "AIB";
//     }

//     function claimCredential(address _alumniAddress, uint8 _alumniType, string calldata _value) public returns(bool){
//         require(issuerAddress == msg.sender, "Not Issuer");
// 				Credential storage credential = credentials[_alumniAddress];
//         require(credential.id == 0);
//         credential.id = idCount;
//         credential.issuer = msg.sender;
//         credential.alumniType = _alumniType;
//         credential.value = _value;
        
//         idCount += 1;

//         return true;
//     }

//     function getCredential(address _alumniAddress) public view returns (Credential memory){
//         return credentials[_alumniAddress];
//     }
// }