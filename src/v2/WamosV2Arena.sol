// SPDX-License-Identifier: MIT

pragma solidity <0.9.0;

/**
    create or join game - stake party - play - retrieve party
    TODO encode all storage
    TODO better way to determine if msg.sender is p1 or p2
 */

import "openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-solidity/contracts/token/ERC721/IERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./WamosV2.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

enum StakingStatus {
    UNSTAKED,
    REQUESTED,
    STAKED
}

// Tracks each game
struct GameData {
    address[2] players; //0->player1, 1->player2
    GameStatus status;
    uint256 partySize;
    bool party1IsStaked;
    bool party2IsStaked;
    uint256[3] party1;
    uint256[3] party2;
    uint256 createTime;
    uint256 lastMoveTime;
    uint256 turnCount;
    address victor;
}

// Tracks the status of a single wamo during a game
struct WamoStatus {
    bool inArena;
    int16 position;
    uint256 health;
    uint256 stamina;
    uint256 mana;
}

error GameDoesNotExist(uint256 gameId);
error NotPlayersTurnOrNotInGame(uint256 gameId, address sender);
error NotPlayerInGame(uint256 gameId, address sender);
error MoveOutOfBounds(uint256 wamoId, int16 attemptedIdenMutation);
error OpponentNotDefeated(uint256 gameId);
error GameNotFinished(uint256 gameId, address sender);

contract WamosV2Arena is IERC721Receiver {
    //// GAME CONSTANTS
    int16 public constant GRID_SIZE = 16;
    uint256 public constant MAX_PLAYERS = 2;
    uint256 public constant PARTY_SIZE = 2;

    //// WAMOS
    WamosV2 wamos;

    //// GAME CONTRACT DATA
    uint256 public gameCount;
    address immutable deployer;
    uint256 public timestamp;

    //// INVITE SYSTEM
    mapping(address => uint256[]) public addrToChallengesSent;
    mapping(address => uint256[]) public addrToChallengesReceived;

    //// PLAYER TAGS
    mapping(address => string) public addrToPlayerTag;

    //// GAME DATA
    // game data (struct, temp)
    mapping(uint256 => GameData) gameIdToGameDataStruct;
    // game data (encoded)
    mapping(uint256 => uint256) gameIdToGameData;
    // players
    mapping(uint256 => address[2]) gameIdToPlayers;
    // wamo staking status
    mapping(uint256 => StakingStatus) wamoIdToStakingStatus;
    // wamo status (struct, temp)
    mapping(uint256 => WamoStatus) wamoIdToWamoStatusStruct;
    // wamo status (encoded)
    mapping(uint256 => uint256) wamoIdToWamoStatus;

    //// EVENTS todo

    constructor(address _wamosAddr) {
        wamos = WamosV2(_wamosAddr);
        deployer = msg.sender;
        timestamp = block.timestamp;
    }

    //// MODIFIERS ////

    // todo
    modifier onlyPlayer(uint256 gameId) {
        if (msg.sender != gameIdToPlayers[gameId][0] && msg.sender != gameIdToPlayers[gameId][1]) {
            revert NotPlayerInGame(gameId, msg.sender);
        }
        _;
    }

    modifier onlyTurn(uint256 gameId) {
        address[2] memory players = gameIdToPlayers[gameId];
        uint256 turn = _getTurnCount(gameId);
        if (msg.sender != players[turn%2]) {
            revert NotPlayersTurnOrNotInGame(gameId, msg.sender);
        }
        _;
    }

    // todo
    modifier onlyOnFoot() {
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployer, "Function only callable by Arena Deployer");
        _;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////       GAME SET UP       ////////////////////
    /////////////////////////////////////////////////////////////////

    function createGame(
        address player2,
        uint256 partySize
    ) external returns (uint256 gameId) {
        // todo require statements
        address player1 = msg.sender;
        gameId = gameCount++;
        GameData memory game;
        game.createTime = block.timestamp;
        game.partySize = partySize;
        game.players = [player1, player2];
        game.status = GameStatus.PREGAME;
        gameIdToPlayers[gameId] = [msg.sender, player2];
        // // encode game data
        // uint256 gameData = _encodeGameData(game);
        // gameIdToGameData[gameId] = gameData;

        // todo temporary
        gameIdToGameDataStruct[gameId] = game;
    }

    // @dev atm only build for party size of three
    function connectWamos(
        uint256 gameId, 
        uint256[3] memory wamoIds
    ) external onlyPlayer(gameId) {
        // todo requirements
        // prompt transfers and flag wamo as staked
        for (uint i = 0; i < wamoIds.length; i++) {
            wamoIdToStakingStatus[wamoIds[i]] = StakingStatus.REQUESTED;
            wamos.safeTransferFrom(msg.sender, address(this), wamoIds[i]);
        }
        // flag players party as staked
        if (msg.sender == gameIdToGameDataStruct[gameId].players[0]) {
            gameIdToGameDataStruct[gameId].party1IsStaked = true;
            gameIdToGameDataStruct[gameId].party1 = wamoIds;
        } else {
            gameIdToGameDataStruct[gameId].party2IsStaked = true;
            gameIdToGameDataStruct[gameId].party2 = wamoIds;
        }
        
        _loadWamos(gameId, msg.sender, wamoIds);
        _assessGameStatus(gameId);
    }

    // @dev load wamos together or one at a time? loadwamo or loadwamos??
    function _loadWamos(
        uint256 gameId, 
        address player, 
        uint256[3] memory wamoIds
    ) internal {
        // check wamos have been received?
        // if so, register stake success status
        for (uint256 i=0; i< wamoIds.length; i++) {
            Traits memory traits = wamos.getTraits(wamoIds[i]);
            
            WamoStatus memory status;
            // initialise wamo arena status
            status.inArena = true;
            if (player == gameIdToGameDataStruct[gameId].players[0]) {
                status.position = int16(uint16(i));
            } else {
                status.position = int16(uint16(255-i));
            }
            status.health = traits.health;
            status.mana = traits.mana;
            status.stamina = traits.stamina;

            wamoIdToWamoStatusStruct[wamoIds[i]] = status;

            /////// ENCODING
            // uint256 wamoStatus;
            // // in arena
            // wamoStatus |= uint256(1);
            // // starting pos
            // if (player == gameIdToGameDataStruct[gameId].players[0]) {
            //     // p1 is staking
            //     wamoStatus |= uint256(i) << 1;
            // } else {
            //     // p2 is staking
            //     wamoStatus |= uint256(255-i) << 9;
            // }
            // // locally store traits that will mutate during battle
            // wamoStatus |= traits.health << 17;
            // wamoStatus |= traits.mana << 25;
            // wamoStatus |= traits.stamina << 33;
            // // store encoded wamo status         
            // wamoIdToWamoStatus[wamoIds[i]] = wamoStatus;
        }
    }

    function _assessGameStatus(uint256 gameId) internal {
        // if both parties are staked -> set game status to onfoot
        GameData memory game = gameIdToGameDataStruct[gameId];
        if (game.party1IsStaked && game.party2IsStaked) {
            gameIdToGameDataStruct[gameId].status = GameStatus.ONFOOT;
        }
    }

    function onERC721Received(
        address operator, // should be wamos contract
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        // if (operator == address(this)) {
        //     // todo any logic required?
        // }
        return IERC721Receiver.onERC721Received.selector;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    GAMEPLAY FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    function commitTurn(
        uint256 gameId,
        uint256 actingWamoId,
        uint256 targetWamoId,
        uint256 moveSelection,
        uint256 abilitySelection,
        bool isMoved, 
        bool moveBeforeAbility,
        bool useAbility
    ) external onlyTurn(gameId) {
        // todo require statements
        require(abilitySelection < 4, "Ability selection must be in [0,3]");
        require(moveSelection < 8, "Move selection must be in [0,7]");
        require(_getGameStatus(gameId) == GameStatus.ONFOOT, "Game must be onfoot!");
        // require wamo is not dead
        // game must be onfoot
        _incrementTurnCount(gameId);  
        _commitTurn(
            gameId,
            actingWamoId,
            targetWamoId,
            moveSelection,
            abilitySelection,
            isMoved, 
            moveBeforeAbility,
            useAbility
        );
        // todo REGEN PARTY HP,MANA,STAM
    }

    function resign(uint256 gameId) external onlyPlayer(gameId) {
        // no checks, game simply ends immediately
        address victor;
        address[2] memory players;
        if (msg.sender == players[0]) {
            victor = players[1];
        } else {
            victor = players[0];
        }
        _endGame(gameId, victor);
    }

    function claimVictory(uint256 gameId) external onlyPlayer(gameId) {
        // todo expand to account for variable party size
        uint256 partySize = 3;
        uint256[3] memory enemyParty = _getOpponentsParty(gameId, msg.sender);
        // check the party of the other play has been defeated
        uint256 wamoId;
        for (uint256 i=0; i<partySize; i++) {
            wamoId = enemyParty[i];
            if (_getWamoHealthStatus(wamoId) > 0) {
                revert OpponentNotDefeated(gameId);
            }
        }
        _endGame(gameId, msg.sender);
    }

    function retrieveWamos(uint256 gameId) external onlyPlayer(gameId) {
        // game must be over
        if (_getGameStatus(gameId) != GameStatus.FINISHED) {
            revert GameNotFinished(gameId, msg.sender);
        }
        uint256[3] memory party = _getPlayersParty(gameId, msg.sender);
        // prompt transfer of relevant wamos back to sender
        for (uint256 i=0; i<party.length; i++) {
            wamos.safeTransferFrom(address(this), msg.sender, party[i]);
        }
        // todo event
    }

    /////////////////////////////////////////////////////////////////
    //////////////////// INTERNAL GAME FUNCTIONS ////////////////////
    /////////////////////////////////////////////////////////////////

    function _endGame(uint256 gameId, address victor) internal {
        // todo update to encoded version
        gameIdToGameDataStruct[gameId].status = GameStatus.FINISHED;
        gameIdToGameDataStruct[gameId].victor = victor; // todo change to player index
        // todo add victory and loss to wamos stats
        // distribute glory and spoils
    }

    function _commitTurn(
        uint256 gameId,
        uint256 actingWamoId,
        uint256 targetWamoId,
        uint256 moveSelection,
        uint256 abilitySelection,
        bool isMoved, 
        bool moveBeforeAbility,
        bool useAbility
    ) internal {
        if (!isMoved && !useAbility) {
            return; // do nothing
        } else if (isMoved && !useAbility) {
            _moveWamo(actingWamoId, moveSelection);
        } else if (!isMoved && useAbility) {
            _useAbility(actingWamoId, targetWamoId, abilitySelection);
        } else {
            if (moveBeforeAbility) {
                _moveWamo(actingWamoId, moveSelection);
                _useAbility(actingWamoId, targetWamoId, abilitySelection);
            } else {
                _useAbility(actingWamoId, targetWamoId, abilitySelection);
                _moveWamo(actingWamoId, moveSelection);
            }
        }
    }

    function _moveWamo(uint256 wamoId, uint256 moveSelection) internal {
        int16 idenMutation = wamos.getMovement(wamoId, moveSelection);
        int16 currentIden = getWamoPosition(wamoId);
        int16 newIden = currentIden + idenMutation;
        if (newIden >= 0 && newIden < 256) {
            // valid move
            _setWamoPosition(wamoId, newIden);
        } else {
            // invalid move
            revert MoveOutOfBounds(wamoId, idenMutation);
        }
    }

    function _useAbility(
        uint256 actingWamoId, 
        uint256 targetWamoId, 
        uint256 abilitySelection
    ) internal {
        Ability memory ability = wamos.getAbility(actingWamoId, abilitySelection);
        // check that ability is in range
        //
        // if in range...
        uint256 damage = _calculateDamage(actingWamoId, targetWamoId, ability);
        _inflictDamage(targetWamoId, damage);
        // todo update wamo status to exact cost of ability
        // if dmg type magic -> subtract from mana, etc
    }

    function _calculateDamage(
        uint256 actingWamoId,
        uint256 targetWamoId,
        Ability memory ability
    ) internal returns (uint256 damage) {
        Traits memory attacker = wamos.getTraits(actingWamoId);
        Traits memory defender = wamos.getTraits(targetWamoId);

        // isolate relevant attack and defence stats
        uint256 att;
        uint256 def;
        if (ability.damageType == DamageType.MEELEE) {
            att = attacker.meeleeAttack;
            def = defender.meeleeDefence;
        } else if (ability.damageType == DamageType.MAGIC) {
            att = attacker.magicAttack;
            def = defender.magicDefence;
        }

        // doesnt include accuracy
        damage = ((( 100 * ability.power * (att/def) + 10) / 40) * (75+(block.timestamp%50))) / 100;

    }

    function _setWamoPosition(uint256 wamoId, int16 newIden) internal {
        // todo update to encoded version
        wamoIdToWamoStatusStruct[wamoId].position = newIden;
        // todo event: wamo, new iden
    }

    function _inflictDamage(uint256 targetWamoId, uint256 damage) internal {
        uint256 currentHealth = wamoIdToWamoStatusStruct[targetWamoId].health;
        if (damage < currentHealth) {
            wamoIdToWamoStatusStruct[targetWamoId].health = currentHealth - damage;
        } else {
            // dead
            wamoIdToWamoStatusStruct[targetWamoId].health = 0;
        }
        // todo emit event: wamo, damage, new hp
    }

    // todo
    function _regen(uint256 wamoId) internal {}

    function _incrementTurnCount(uint256 gameId) internal {
        gameIdToGameDataStruct[gameId].turnCount++;
        // todo replace with encoding solution
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    ENCODING FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    function _encodeGameData(
        GameData memory game
    ) public returns (uint256 gameData) {}

    /////////////////////////////////////////////////////////////////
    ////////////////////      VIEW FUNCTIONS     ////////////////////
    /////////////////////////////////////////////////////////////////

    function getChallengers(address player) public view returns (uint256[] memory) {
        return addrToChallengesReceived[player];
    }

    function getChallenges(address player) public view returns (uint256[] memory) {
        return addrToChallengesSent[player];
    }

    function getTurnCount(uint256 gameId) public view returns (uint256) {
        return _getTurnCount(gameId);
    }

    function _getTurnCount(uint256 gameId) internal view returns (uint256) {
        // todo update to encoded
        return gameIdToGameDataStruct[gameId].turnCount;
    }

    function getGameDataStruct(uint256 gameId) public view returns (GameData memory) {
        return gameIdToGameDataStruct[gameId];
    }

    function getGameStatus(uint256 gameId) public view returns (GameStatus) {
        return _getGameStatus(gameId);
    }

    function _getGameStatus(
        uint256 gameId
    ) internal view returns (GameStatus status) {
        // todo update to encoded
        status = gameIdToGameDataStruct[gameId].status;
    }

    function getWamoStatus(uint256 wamoId) public view returns (WamoStatus memory status) {
        // uint256 encodedStatus = wamoIdToWamoStatus[wamoId];
        // status.inArena = ( (encodedStatus & uint256(1)) == 1 ? true : false);
        // status.position = int8()
        status = wamoIdToWamoStatusStruct[wamoId];
    }

    function getWamoPosition(
        uint256 wamoId
    ) public view returns (int16 position) {
        // todo check game is onfoot?
        // todo update to encoded version 
        position = wamoIdToWamoStatusStruct[wamoId].position;
    }

    function getWamoHealthStatus(uint256 wamoId) external view returns (uint256) {
        return _getWamoHealthStatus(wamoId);
    }

    function _getWamoHealthStatus(
        uint256 wamoId
    ) internal view returns (uint256) {
        return wamoIdToWamoStatusStruct[wamoId].health;
    }

    function _getOpponentsParty(
        uint256 gameId, 
        address player
    ) internal view returns (uint256[3] memory party) {
        if (player == gameIdToPlayers[gameId][0]) {
            party = gameIdToGameDataStruct[gameId].party2;
        } else {
            party = gameIdToGameDataStruct[gameId].party1;
        }
    }

    function _getPlayersParty(
        uint256 gameId,
        address player
    ) internal view returns (uint256[3] memory party) {
        if (msg.sender == gameIdToPlayers[gameId][0]) {
            party = gameIdToGameDataStruct[gameId].party1;
        } else {
            party = gameIdToGameDataStruct[gameId].party2;
        }        
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    CONTRACT SETTERS     ////////////////////
    /////////////////////////////////////////////////////////////////

    function setPlayerTag(string calldata newPlayerTag) public {
        addrToPlayerTag[msg.sender] = newPlayerTag;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    LIBRARY  FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    function abs(int16 number) public pure returns (int16) {
        return number >= 0 ? number : -number;
    }

    function euclideanDistance(
        int16 p1,
        int16 p2
    ) public pure returns (int16 y) {
        int16 dx = (p2 % GRID_SIZE) - (p1 % GRID_SIZE);
        int16 dy = (p2 / GRID_SIZE - p1 / GRID_SIZE) + 1;

        // Heron's method for sqrt approximation
        int16 a = (dx ** 2 + dy ** 2);
        // begin method
        int16 z = (a + 1) / 2;
        y = a;
        while (z < y) {
            y = z;
            z = (a / z + z) / 2;
        }
    }

    function sqrtApprox(int16 x) public pure returns (int16 y) {
        int16 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////     ADMIN  FUNCTIONS    ////////////////////
    /////////////////////////////////////////////////////////////////

    function setWamoPosition(uint256 wamoId, int16 newIden) external onlyDeployer {
        _setWamoPosition(wamoId, newIden);
    }

    function setWamoHealth(uint256 wamoId, uint256 newHealth) external onlyDeployer {
        wamoIdToWamoStatusStruct[wamoId].health = newHealth;
    }

    function calculateDamage(
        uint256 actingWamoId,
        uint256 targetWamoId,
        Ability memory ability
    ) external returns (uint256 damage) {
        damage = _calculateDamage(actingWamoId, targetWamoId, ability);
    }
}
