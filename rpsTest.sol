//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract RPS {
    constructor () payable {}

    event GameCreated(address originator, uint256 originator_bet, uint roomNum);
    event GameJoined(address originator, address taker, uint256 originator_bet, uint256 taker_bet);
    // event OriginatorWin(address originator, address taker, uint256 betAmount);
    // event TakerWin(address originator, address taker, uint256 betAmount);

    enum Hand {
        rock, paper, scissors
    }

    enum PlayerStatus {
        STATUS_WIN, STATUS_LOSE, STATUS_TIE, STATUS_PENDING
    }

    struct Player {
        address payable addr;
        uint playerBetAmount;
        Hand hand;
        PlayerStatus playerStatus;
    }

	enum GameStatus { 
		STATUS_NOT_STARTED, STATUS_STARTED, STATUS_COMPLETE, STATUS_ERROR
	}

    struct Game {
        Player originator;
        Player taker;
        uint256 betAmount;
        GameStatus gameStatus;
    }

    mapping(uint => Game) rooms; // rooms[0], rooms[1] 형식으로 접근할 수 있으며, 각 요소는 Game 구조체 형식.
	uint roomLen = 0; // rooms의 키 값입니다. 방이 생성될 때마다 1씩 올라간다.
    

    function createRoom (Hand _hand) public payable isValidHand(_hand) returns (uint roomNum) {
        rooms[roomLen] = Game({
            betAmount: msg.value,
            gameStatus: GameStatus.STATUS_NOT_STARTED,
            originator: Player({
                hand: _hand,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: msg.value
            }),
            taker: Player({
                hand: Hand.rock,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: 0
            })
        });
        roomNum = roomLen;
        roomLen ++;

        emit GameCreated(msg.sender, msg.value, roomNum);
    }

    modifier isValidHand(Hand _hand) {
        require((_hand == Hand.rock) || (_hand == Hand.paper) || (_hand == Hand.scissors));
        _;
    }

    function joinRoom(uint roomNum, Hand _hand) public payable isValidHand(_hand) {
        rooms[roomNum].taker = Player({
            hand: _hand,
            addr: payable(msg.sender),
            playerStatus: PlayerStatus.STATUS_PENDING,
            playerBetAmount: msg.value
        });
        rooms[roomNum].betAmount += msg.value;
        compareHands(roomNum);

        emit GameJoined(rooms[roomNum].originator.addr, msg.sender, rooms[roomNum].betAmount, msg.value);
    }

    function compareHands(uint roomNum) private {
        uint8 originator = uint8(rooms[roomNum].originator.hand);
        uint8 taker = uint8(rooms[roomNum].taker.hand);

        rooms[roomNum].gameStatus = GameStatus.STATUS_STARTED;

        // tie
        if (taker == originator){ // 비긴 경우
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_TIE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_TIE;
        }
        // originator wins
        else if ((taker +1) % 3 == originator) { // 방장이 이긴 경우
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_WIN;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_LOSE;
        }
        // taker wins
        else if ((originator + 1)%3 == taker){  // 참가자가 이긴 경우
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_LOSE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_WIN;
        } else { // else -> error
            rooms[roomNum].gameStatus = GameStatus.STATUS_ERROR;
        }
    }

    function checkTotalPay(uint roomNum) public view returns(uint roomNumPay){
        return rooms[roomNum].betAmount;
    }
/*     
    payout 함수는 방 번호를 인자로 받아, 게임 결과에 따라 베팅 금액을 송금하고, 게임을 종료합니다.

    컨트랙트에 있는 금액을 송금하기 위해서는 솔리디티에 내장된 transfer 함수를 사용
*/

    function payout(uint roomNum) public payable isPlayer(roomNum, msg.sender) {
        if (rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_TIE && rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_TIE) {
            rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
            rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
        } else {
            if (rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_WIN) {
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].betAmount);
            } else if (rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_LOSE) {
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].betAmount);
            } else {
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
            }
        }
        rooms[roomNum].gameStatus = GameStatus.STATUS_COMPLETE;
    }    

    modifier isPlayer(uint roomNum, address sender) {
        require(sender == rooms[roomNum].originator.addr || sender == rooms[roomNum].taker.addr);
        _;
    }

    modifier roomExists() {
        require(roomLen>0);
        _;
    }

    function getBiggestBetRoom() public view roomExists() returns(uint256) {
        uint256 largestRoom = 0;
        uint256 largest = 0;
        for(uint i=0; i < roomLen; i++) {
            if(rooms[i].betAmount > largest) {
                largest = rooms[i].betAmount;
                largestRoom = i;
            }
        }
        return largestRoom;
    }

    modifier isValidRoom (uint roomNum) {
        require(roomLen > roomNum && roomNum >= 0);
        _;
    }

    function getPlayerNum(uint roomNum) public view isValidRoom(roomNum) returns(uint256 playerNum){
        if(rooms[roomNum].gameStatus == GameStatus.STATUS_NOT_STARTED) playerNum = 1;
        else if(rooms[roomNum].gameStatus == GameStatus.STATUS_STARTED) playerNum = 2;
        else playerNum = 0;
    }

    function keccak(uint256 _hand, string memory _key) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(_hand, _key));
    }
}
