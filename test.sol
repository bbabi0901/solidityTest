// SPDX-License-Identifier: GPL-3.0 
pragma solidity ^0.8.14;  // 0.8.14 이상의 버전을 사용(^)

contract SimpleStorage {
    uint storedData; // 상태 변수 선언
    uint storedData2 = 20; // 상태변수 선언 및 초기화

		// 함수 정의
    function simpleFunction(uint x) public pure returns(uint) {
        uint a; //  지역변수 선언
        uint b = 1; // 지역변수 선언 및 초기화
        a = 1;
        uint result = a + b +x;
        return result;
    }
		
/* 
전역변수는 솔리디티만의 특수한 변수(또는 함수)로써 주로 블록체인에 관한 정보를 제공합니다.

전역변수는 block.number(현재 블록의 번호), msg.sender(Tx 송신자의 address) 등 컨트랙트를 생성할 당시에는 알 수 없는 블록체인에 관한 정보를 제공하여 컨트랙트의 사용성을 높여줍니다.

전역변수는 따로 선언이나 초기화 없이 불러와서 사용합니다. 
*/
    function f(uint start, uint daysAfter) public {
        if (block.timestamp >= start + daysAfter * 1 days) {
        // 여기서 block.timestamp는 전역변수
        }
    }
}

/* 
// 파일을 임포트 하는 방식은 자바스크립트에서 사용하는 방식과 동일합니다.

import "파일이름";

// 임포트하는 파일을 symbolName이라는 이름으로 사용
import * as symbolName from "파일이름";
import "파일이름" as symbolName;

// 파일의 일부분만 임포트 하는 경우
import {symbol1 as alias, symbol2} from "파일이름"; 
*/


// 컨트랙트를 address payable로 변환할 수도 있습니다.
// 만약 컨트랙트가 이더를 받을 수 있는 컨트랙트인 경우,
// address(컨트랙트)를 수행했을 때 address payable 형식의 주소값을 반환합니다.
contract sampleContract  {  // 이더를 받을 수 있는 컨트랙트
	constructor () payable { }
}

// address(C)는 address payable 형식의 주소값을 반환한다
address payable constant addr = address(sampleContract);  

// 반면, 컨트랙트가 이더를 받지 않는 컨트랙트인 경우,
// address(컨트랙트)를 수행했을 때 address 형식의 주소값을 반환합니다.
// 이 경우 결과값을 payable()에 넣어 address payable 형식으로 만들 수 있습니다.
// 이더를 받지 않는 컨트랙트
contract D {. 
	 constructor () { }
}

address addr = address(D); // address(D)는 address 형식의 주소값을 반환한다
address payable addr_p = payable(addr); // payable()을 사용해 address payable 형식의 주소값을 만들 수 있다.


// 열거형(enum)은 특정 값들로 집합을 지정하고, 집합에 있는 데이터만을 값으로 가집니다.
// 각 집합의 데이터는 내부적으로는 순서에 따라 0부터 1씩 올라가는 정수를 값으로 가집니다.

enum EvalLevel { Bad, Soso, Great } // 열거형 집합을 지정합니다.

EvalLevel kimblock = EvalLevel.Bad // 열거형으로 변수를 선언합니다.

int16 kimblockValue = int16(kimblock); // kimblock 열거형 값 0을 정수형으로 변환합니다.

데이터 저장 영역에는 세 종류가 있다고 위에서 다룬 적이 있습니다.

메모리: 프로그램이 동작하는 동안에만 값을 기억하고, 종료되면 값을 잃는 데이터 영역
스토리지: 블록체인에 기록되어 영구적으로 값이 유지되는 데이터 영역
calldata: 메모리와 비슷하지만 수정 불가능하고 비영구적인 데이터 영역
참조형 변수를 선언할 때는 메모리에 저장할지 스토리지에 저장할지 명시해야 합니다.

1-2. 바이트 배열(가변 크기)
바이트(bytes)는 특수한 형태의 배열입니다.
고정 크기 바이트배열과 다르게 크기를 정해놓지 않고, 입력값에 따라 크기가 달라집니다.

bytes로 가변 크기의 배열을 선언합니다.

1
bytes alphabets = 'abc';
1-3. 문자열(string)
문자열(string) 역시 특수한 형태의 배열로써, 바이트 배열(가변 크기)에 기반한 문자열 타입입니다.

string은 bytes와 동일하지만, index, push, length, concat 등을 지원하지 않습니다.
문자열 리터럴로 초기화합니다.

1
string name = 'kimblock';

2. 구조체(struct)
구조체(struct)는 서로 다른 유형의 항목을 포함하는 집합으로, 사용자 정의 형식입니다.
구조체는 배열과 매핑의 내부에서 사용될 수 있으며, 반대로 구조체에 배열과 매핑을 포함할 수도 있습니다.

하지만 구조체가 동일한 구조체 타입의 멤버를 포함할 순 없습니다.

구조체는 다음과 같이 정의합니다.


contract exmapleC {
	struct User {
	    address account;
	    string lastName;
	    string firstName;
			mapping (uint => Funder) funders;
	}

	mapping (uint => User) users;
}

구조체를 사용할 때는 각 항목에 대한 값을 객체 형식으로 추가합니다.


contract exmapleC {

	struct User {
	    address account;
	    string lastName;
	    string firstName;
	}

	function newUser (address newAddress, string newLastName, string newFirstName){
	    User memory newOne = User({account: newAddress, lastName: newLastName, firstName: newFirstName});
	}
}

3. 매핑(mapping)
매핑(mapping)은 스토리지 데이터 영역에서 키-값 구조로 데이터를 저장할 때 사용하는 참조형입니다.

mapping(키 형식=> 값 형식) 변수명 형태로 선언합니다.

여기서 키 형식은 매핑, 구조체, 배열 제외한 유형의 값이 다 될 수 있습니다.

여기서 키, 값 형식은 매핑, 구조체, 배열을 포함한 모든 유형의 값이 다 될 수 있습니다.

1
mapping(address => int) public userAddress;

// 비트 연산자 체크
contract SolidityTest {

    // 변수 선언 및 초기화
    uint16 public a = 20;
    uint16 public b = 10;
		// a는 10100
		// b는 01010

    // &를 활용한 비트 AND 연산 및 초기화
    // and == 0
    uint16 public and = a & b;

    // |를 활용한 비트 OR 연산 및 초기화
    // or === 30
    uint16 public or = a | b;

    // ^를 활용한 비트 XOR 연산 및 초기화
    // or === 30
    uint16 public xor = a ^ b;

    // Initializing a variable
    // to '<<' value
    uint16 public leftshift = a << b;

    // Initializing a variable
    // to '>>' value
    uint16 public rightshift = a >> b;

    // Initializing a variable
    // to '~' value
    uint16 public not = ~a ;

}

// 삼항 연산자
uint result = (a > b? a-b : b-a);

public(default):
외부에서도 접근 가능
컨트랙트 내부, 외부, 클라이언트 코드에서 모두 호출 가능
external:
public과 비슷함
외부(external) 컨트랙트나 클라이언트 코드에서 호출 가능
컨트랙트 내부에서는 호출 불가능. f()로 호출 불가능
컨트랙트 내부로부터 불릴 경우 this.f() 와 같이 this를 활용한 호출 가능
internal:
컨트랙트 멤버와 상속된 컨트랙트에서 호출 가능
private :
컨트랙트 멤버만 호출 가능


payable
payable을 선언하면 함수에서 이더를 받을 수 있습니다.
view로 표시된 함수는 상태를 변경하지 않는 읽기 전용 함수입니다. 함수 범위 외의 데이터를 읽을 수는 있지만 이에 대한 변경은 불가능합니다.

pure는 스토리지에서 변수를 읽거나 쓰지 않는 함수입니다. 함수 범위 외의 데이터를 읽지 못하고, 변경할 수도 없는 함수입니다.

생성자 함수(constructor)
생성자 함수를 선언하면, 컨트랙트가 생성될 때 생성자 함수가 실행되며 컨트랙트의 상태를 초기화할 수 있습니다.

constructor 키워드를 사용해 생성자 함수를 선언할 수 있습니다.

생성자 함수는 컨트랙트 당 1개만 작성해야 합니다.
생성자 함수를 작성하지 않으면 자동으로 기본 생성자(default constructor)가 생성됩니다.
생성자 함수의 함수 접근 수준(visibility)은 internal 이거나 public이어야 하지만, 0.7 버전 이후부터는 visibility를 붙이지 않습니다(solidity v.0.7.0 에서 반영된 부분)
pragma solidity ^0.8.14;
contract exmapleC {

    address public account;

    constructor(address _account) {
        account = _account;
    }
}

selfdestruct
selfdestruct 함수를 사용하여 컨트랙트를 소멸할 수 있습니다.

selfdestruct(컨트랙트 생성자의 주소);



// modifier ; 함수 제어자
비슷한 역할을 하는 코드를 모아서 만든 특별한 형태의 함수입니다.

함수 선언에 modifier를 추가하여 함수에 변경자를 적용할 수 있습니다.

변경자: 함수를 실행하기 전, 요구 조건을 만족하는지 확인하는 작업

변경자를 작성할 때는 _;를 사용합니다. _;는 함수를 실행하는 시점을 나타내며, 변경자 코드는 _; 코드를 기준을 실행 시점이 달라집니다. _; 이전의 코드는 함수가 실행되기 전에 실행되고, _; 이후의 코드는 함수 실행이 종료되고 실행됩니다.

다음의 changeNum 변경자는 함수를 실행하기 전, num 상태 변수의 값을 1 올리고, 함수의 실행이 완료되면 num 상태 변수의 값을 1 내립니다.

int public num = 0;
modifier changeNum {
	num++;  // 함수 실행 전 실행됨
	_;  // 함수 실행
	num--; // 함수 실행 후 실행됨
}
changeNum 변경자는 다음과 같이 사용할 수 있습니다.

function func() public changeNum {
	if (num == 1) {
		// do something
	}
}

이벤트는 어떤 결과가 발생했을 때 해당 컨트랙트에서 dApp 클라이언트, 또는 다른 컨트랙트에게 전달합니다.

컨트랙트는 event 키워드를 사용해 이벤트를 설정하고, 때에 따라 emit 키워드를 사용해 이벤트를 실행합니다. 이벤트가 실행된 경우, 트랜잭션에 기록됩니다.

contract coinTransfer {
	// event 이벤트명(파라미터유형1 파라미터1, 파라미터유형2 파라미터2, ...);
	event Transfer(address from, address to, uint256 value);

	function transfer(address to, uint256 amount) {
		//...

		// emit 이벤트명(인자1, 인자2 ...)
		emit Transfer(msg.sender, to, amount);
	}
}
https://blog.naver.com/PostView.naver?blogId=tkdlqm2&logNo=222288367525&categoryNo=0&parentCategoryNo=0
https://nujabes403.medium.com/solidity-event%EC%97%90-%EB%8C%80%ED%95%B4%EC%84%9C-6ed040e12808


에러 핸들링
솔리디티에서 에러를 처리할 때는 assert, require, revert 함수를 사용합니다.

revert : 해당 함수를 종료하고 에러를 반환합니다.
require, assert: 설정한 조건이 참인지 확인하고, 조건이 거짓이면 에러를 반환합니다.
revert는 다음과 같이 사용할 수 있습니다.
function buy(uint amount) public payable {
    if (amount > msg.value / 2 ether)
        revert("Not enough Ether provided."); //에러를 반환하면서 에러 메시지를 지정할 수 있습니다

    // 송금 진행
}

require 는 그 자체로 if...revert 처럼 사용되는 게이트키퍼 역할을 합니다.

게이트키퍼(gatekeeper)
조건을 만족하면 특정 동작을 실행하고, 조건을 만족하지 않으면 실행하지 못하도록 하는 역할

가령, 위 VendingMachine 컨트랙트의 buy 함수는 아래의 코드와 완전히 동일하게 작동합니다.
function buy(uint amount) public payable {
    require(
        amount <= msg.value / 2 ether,  // 주어진 조건이 참이면 넘어가고, 거짓이면 에러 반환
        "Not enough Ether provided."  // 에러 메시지를 지정할 수 있습니다
    );

    // 송금 진행
}
assert는 require 와 사용법이 동일하나, 사용하지 않은 가스를 호출자에게 반환하지 않고, 공급된 가스를 모두 소모하며 상태를 원래대로 되돌립니다.


상속
솔리디티의 contract 객체는 상속을 지원합니다. 상속을 통해 컨트랙트에 기능들을 추가하고, 확장할 수 있습니다.

상속을 사용하려면 부모 컨트랙트에 is 키워드를 지정해줍니다.
솔리디티는 다중 상속도 지원합니다.
contract ChildContract is ParentContract1, ParentContract2, ParentContract3 {
  // ...
}
호출 방법:
1. 라이브러리 이름.메소드이름()
2. using 라이브러리 이름 for 데이터 타입

import "./UIntFunctions.sol";
contract Example {
    function isEven(uint x) public pure returns(bool) {
        return UIntFunctions.isEven(x);
    }
}

import "./UIntFunctions.sol";
contract Example {
    using UIntFunctions for uint;
    function isEven(uint x) public pure returns(bool) {
        return x.isEven();
    }
}

기본 문법 파트에서 다루지 않은 심화 개념들을 학습해보세요.
함수 오버로딩

함수 오버라이딩

추상 계약

인터페이스
크립트좀비를 통해 학습한 문법에 익숙해져보세요.
https://cryptozombies.io/ko/