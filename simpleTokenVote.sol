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

abstract contract OwnerHelper {
    // 관리자 3명을 만들어야 한다.
    // 배열의 형식으로 관리를 해도 될 것;
    // 맵핑의 형식으로 관리를 해도 될 것;
    
    // mapping(차기 후보자 계정 => 투표개수)
    // 투표를 했는지 mapping(소유자 계정 => 후보자계정)


    // 제안서 -> 투표 -> 투표가 누적 3이면 결과 발표 & 반영
    // proposal
    // 제안서 제출자는 찬성 & emit transfer or add.
    // proposal -> struct -> {type: {transfer or add}, id: uint, from: , to: }
    
    // vote의 input으로는 proposal id, agree or disagree
    // vote 내부에서 check
    
    // struct Proposal {
    //     uint8 propsalType; 
    //     address from;
    //     address to;
    // }
    
    // Proposal public proposals;

  	address[3] private _owner;
    VoteStatus[3] private _owner_vote;

    // 변경함수
    // 변경함수(oldOwner, newOwner, vote)
    // 변경함수 = 3명일때 && 과반수이상의 관리자 동의
    // owner가 제출한 oldOwner, newOwner 비교 필요

    // owner 당 투표 상태
    enum VoteStatus {
      VOTE_WAIT, VOTE_DISAGREE, VOTE_AGREE
    }

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

    // 함수를 실행할 때, 내가 관리자에 포함되냐???
  	modifier onlyOwner {
      bool flag = isOwner(msg.sender);
			require(flag == true, "OwnerHelper: caller is not owner");
			_;
  	}

    // 새로운 오너가 유효한지 검사하는 수정자
    modifier checkNewOwner(address newOwner) {
      require(isOwner(newOwner) == false);
      require(newOwner != address(0x0));
      _;
    }

  	constructor() {
      _owner[0] = msg.sender;
  	}

    // 관리자가 누구냐?
    function owner() public view virtual returns (address[3] memory) {
      return _owner;
    }

    // 기존의 오너와 새로운 오너로 변경
  	function transferOwnership(address oldOwner, address newOwner) onlyOwner checkNewOwner(newOwner) public {
      require(isOwner(oldOwner) == true);
      require(isOwner(newOwner) == false);
      
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
    function addOwner(address newOwner) onlyOwner checkNewOwner(newOwner) public{
      uint i =0;
      for(i = 0; i< 3; i++){
        if(_owner[i] == address(0)) {
          _owner[i] = newOwner;
          break;
        }
      }
      require(i!=3,"Already Full");
    }

    // 세명의 투표를 받는 작업.


}

contract TokenLock is ERC20Interface, OwnerHelper {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) public _allowances;

    uint256 public _totalSupply;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    bool public _tokenLock;
    mapping (address => bool) public _personalTokenLock;

    constructor(string memory getName, string memory getSymbol) {
      _name = getName;
      _symbol = getSymbol;
      _decimals = 18;
      _totalSupply = 100000000e18;
      _balances[msg.sender] = _totalSupply;
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
      require(isTokenLock(sender, recipient) == false, "TokenLock: invalid token transfer");
      uint256 senderBalance = _balances[sender];
      require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
      _balances[sender] = senderBalance.sub(amount);
      _balances[recipient] = _balances[recipient].add(amount);
      
      createPersonalTokenLock(sender);
      createPersonalTokenLock(recipient);
      createTokenLock();
    }

    function isTokenLock(address from, address to) public view returns (bool lock) {
      lock = false;

      if(_tokenLock == true){
           lock = true;
      }

      if(_personalTokenLock[from] == true || _personalTokenLock[to] == true) {
           lock = true;
      }

    }
    
    // 1. 함수를 따로 만든다.
    // 2. 토큰을 전송하자마자 락을 걸어준다.
    
    // 토큰 전송하기 전에 personalTokenLock 
    function createTokenLock() onlyOwner public {
        require(_tokenLock == false);
        _tokenLock = true;
    }

    function createPersonalTokenLock(address _who) onlyOwner public{
      require(_personalTokenLock[_who] == false);
      _personalTokenLock[_who] = true;
    }

    function removeTokenLock() onlyOwner public {
      require(_tokenLock == true);
      _tokenLock = false;
    }

    function removePersonalTokenLock(address _who) onlyOwner public {
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