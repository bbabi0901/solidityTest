// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address spender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Transfer(address indexed spender, address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 oldAmount, uint256 amount);
}

library SafeMath {
  	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256) {
	    uint256 c = a / b;
		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

// abstract contract: 추상 컨트랙트로 contract의 구현된 기능과 interface의 추상화 기능 모두를 포함.
// abstract contract는 만약 실제 contract에서 사용하지 않는다면 추상으로 표시되어 사용되지 않습니다.
abstract contract OwnerHelper {
    // 제안서 -> 투표 -> 투표가 누적 3이면 결과 발표 & 반영
    // proposal
    // 제안서 제출자는 찬성 & emit transfer or add.
    // proposal -> struct -> {type: {transfer or add}, id: uint, from: , to: }
    
    // vote의 input으로는 proposal id, agree or disagree
    // vote 내부에서 check
    
    // proposals
    event proposalEvent (uint id, ProposalType proposalType, address from, address to);

    enum ProposalType {
      TRANSFER, ADD
    }

    enum ProposalStatus {
      PROPOSAL_PENDING, PROPOSAL_WIN, PROPOSAL_LOSE
    }

    enum VoteStatus {
      VOTE_PENDING, VOTE_DISAGREE, VOTE_AGREE
    }

    struct Proposal {
      uint8 proposalType;
      address from;
      address to;
      ProposalStatus proposalStatus;
    }

    mapping(uint => Proposal) Proposals;
    mapping(uint => mapping(address => VoteStatus)) votes;
    uint proposalsLen = 0;

    function proposeOwner(ProposalType _proposalType, address from, address to) isValidOwner public {
      require(_proposalType == ProposalType.TRANSFER || (ProposalType.ADD == 1 && from == address(0)));
      Proposals[proposalsLen] = Proposal({
        proposalType: _proposalType,
        from: from,
        to: to,
        proposalStatus: ProposalStatus.PROPOSAL_PENDING
      });
      votes[proposalsLen][msg.sender] = VoteStatus.VOTE_AGREE;
      uint proposalId = proposalsLen;
      proposalsLen ++;
      emit proposalEvent(proposalId, _proposalType, from, to);
    }

    event voteDone(uint id, Proposal proposal)

    function vote(uint id, VoteStatus _vote) isValidOwner public {
      // 조건 성립시
      emit voteDone(id, )
    }

    // 문제 1. 한사람이 여러번 vote할 수 없도록 막아야함
    // 문제 2. vote를 다 했는지 체크
    // 문제 3. 한 proposal이 마무리 되야 넘어갈 수 있어야함
    // 방향성 -> proposal을 mapping 하지 않고, 그때 그때 처리 -> proposal id 불요 & status를 통해서 초기화할지 말지 결정.
  	
    
    address[3] private _owner;
  	event OwnershipTransferred(address indexed preOwner, address indexed nextOwner);

    function isOwner(address _addr) view private returns(bool) {
      bool flag = false;
      for(uint i = 0; i<3; i++){
        if(_addr == _owner[i]){
          flag = true;
        }
      }
      return flag;
    }

  	modifier isValidOwner {
      bool flag = isOwner(msg.sender);
			require(flag == true, "OwnerHelper: caller is not owner");
			_;
  	}

    // 새로운 오너가 유효한지 검사하는 수정자
    modifier isValidNewOwner (address newOwner) {
      require(isOwner(newOwner) == false);
      require(newOwner != address(0x0));
      _;
    }

  	constructor() {
      _owner[0] = msg.sender;
  	}

    function owner() public view virtual returns (address[3] memory) {
      return _owner;
    }

    // 기존의 오너와 새로운 오너로 변경
  	function transferOwnership(address oldOwner, address newOwner) isValidOwner isValidNewOwner(newOwner) public {
      require(isOwner(oldOwner));
      require(!isOwner(newOwner));
      
      uint idx = 0;
      while(idx < 3){
        if(_owner[idx] == oldOwner){
          break;
        }
        idx++;
      }
      _owner[idx] = newOwner;
	    emit OwnershipTransferred(oldOwner, newOwner);
  	}

    // 새로운 오너 추가
    function addOwner(address newOwner) isValidOwner isValidNewOwner(newOwner) public{
      uint i =0;
      for(i = 0; i< 3; i++){
        if(_owner[i] == address(0)) {
          _owner[i] = newOwner;
          break;
        }
      }
      require(i!=3,"Already Full");
    }
}

contract SimpleToken is ERC20Interface, OwnerHelper {
    // uint256의 자료형 데이터에는 SafeMath 라이브러리를 사용하도록
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    uint256 public _totalSupply;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    uint private E18 = 1000000000000000000;
    bool public _tokenLock;
    mapping (address => bool) public _personalTokenLock;

    constructor(string memory getName, string memory getSymbol) {
        _name = getName;
        _symbol = getSymbol;
        _decimals = 18;
        _totalSupply = 100000000 * E18;
        _balances[msg.sender] = _totalSupply; // 추가
        _tokenLock = true;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) external virtual override returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(_balances[msg.sender] >= amount,"ERC20: The amount to be transferred exceeds the amount of tokens held by the owner.");
        _approve(msg.sender, spender, currentAllowance, amount);
        return true;
    }
/* 
    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        emit Transfer(msg.sender, sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance, currentAllowance - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
    }
 */
        function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        emit Transfer(msg.sender, sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        // currentAllowance.sub(amount)에서 sub()이라는 SafeMath 라이브러리 함수를 사용
        _approve(sender, msg.sender, currentAllowance, currentAllowance.sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(isTokenLock(sender, recipient) == false, "TokenLock: invalid token transfer");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        // 마찬가지로 add()와 sub()이라는 SafeMath 라이브러리 함수를 사용
        _balances[sender] = senderBalance.sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
    }

    function isTokenLock(address from, address to) public view returns (bool lock) {
        lock = false;

        if(_tokenLock == true)
        {
             lock = true;
        }

        if(_personalTokenLock[from] == true || _personalTokenLock[to] == true) {
             lock = true;
        }
    }

    function lockToken() isValidOwner public {
      require(_tokenLock == false);
      _tokenLock = true;
    }

    function lockPersonalToken(address _who) isValidOwner public{
      require(_personalTokenLock[_who] == false);
      _personalTokenLock[_who] = true;
    }

    function removeTokenLock() isValidOwner public {
      require(_tokenLock == true);
      _tokenLock = false;
    }

    function removePersonalTokenLock(address _who) isValidOwner public {
      require(_personalTokenLock[_who] == true);
      _personalTokenLock[_who] = false;
    }

    function _approve(address owner, address spender, uint256 currentAmount, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, currentAmount, amount);
    }
}