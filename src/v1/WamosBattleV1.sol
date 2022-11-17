// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "openzeppelin/token/ERC721/IERC721Receiver.sol";
import "openzeppelin/token/ERC721/IERC721.sol";
import "chainlink-v0.8/VRFConsumerBaseV2.sol";
import "chainlink-v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "src/v1/interfaces/WamosV1Interface.sol";
import "src/v1/WamosV1.sol";

enum GameStatus {
    PREGAME,
    ONFOOT,
    FINISHED
}

/** @notice Stores state variables of game */
struct GameData {
    uint256 id;
    GameStatus status;
    uint256 createTime;
    uint256 lastMoveTime;
    uint256 turnCount;
    address[2] players;
    address challenger;
    address challengee;
}

/** @notice Stores and tracks state of a single Wamo during a battle  */
struct WamoStatus {
    // incomplete
    int16 positionIndex;
    uint256 health;
    uint256 stamina;
    uint256 mana;
    // focus?
}

/** @notice Stores status, source and outcome of vrf requests */
struct VRFRequest {
    bool exists;
    bool fulfilled;
    uint256 gameId;
    uint256 turnId;
    uint256 randomWord;
}

/** @notice Tracks the staking request status and staking status of a wamo */
struct StakingStatus {
    bool exists;
    bool stakeRequested;
    uint256 gameId;
    bool isStaked;
}

error GameDoesNotExist(uint256 gameId);
error NotPlayerOfGame(uint256 gameId, address addr);
error PlayerDoesNotOwnThisWamo(uint256 wamoId, address player);
error GameIsNotOnfoot(uint256 gameId);
error WamoMovementNotFound(uint256 gameId, uint256 wamoId, int16 indexMutation);
error InvalidAbilityIndex(uint256 gameId, address player);
error InvalidMoveIndex(uint256 gameId, address player);
error WamoHasNoHealth(uint256 gameId, uint256 wamoId);
error WamoNotInGame(uint256 gameId, uint256 wamoId);
error NotPlayersTurn(uint256 gameId, address player);
error PlayerFalselyClaimsVictory(uint256 gameId, address claimant);

contract WamosBattleV1 is IERC721Receiver, VRFConsumerBaseV2 {
    /** VRF CONSUMER CONFIG */
    bytes32 public vrfKeyHash;
    uint16 public vrfRequestConfirmations;
    uint32 public vrfNumWords;
    uint32 public vrfCallbackGasLimit;
    uint64 public vrfSubscriptionId;

    /** VRF CONSUMER DATA */
    mapping(uint256 => VRFRequest) requestIdToRequest;
    uint256[] public requestIds;
    uint256 public lastRequest;

    /** VRF COORDINATOR INTERFACE */
    VRFCoordinatorV2Interface vrfCoordinator;

    /** WAMOS INTERFACE */
    WamosV1 wamos;

    /** GAME CONSTANTS */
    int16 public constant GRID_SIZE = 16;
    uint256 public constant MAX_PLAYERS = 2;
    uint256 public constant PARTY_SIZE = 2;

    /** GAME CONTRACT DATA */
    uint256 public gameCount;
    // staking
    mapping(uint256 => StakingStatus) public wamoIdToStakingStatus;
    // number of wamos staked in gameId x by player y
    mapping(uint256 => mapping(address => uint256)) gameIdToPlayerToStakedCount;

    // invite system
    mapping(address => uint256[]) public addrToChallengesSent;
    mapping(address => uint256[]) public addrToChallengesReceived;

    // player name
    mapping(address => string) public addrToPlayerTag;

    /** GAME STATE STORAGE */
    //// META GAME
    // is player y ready in game x
    mapping(uint256 => mapping(address => bool)) public gameIdToPlayerIsReady;

    ///// GAME
    // game data
    mapping(uint256 => GameData) public gameIdToGameData;
    // ids of wamos in player y party for game id x
    mapping(uint256 => mapping(address => uint256[PARTY_SIZE]))
        public gameIdToPlayerToWamoPartyIds;
    // the state of wamo y in game x
    mapping(uint256 => mapping(uint256 => WamoStatus))
        public gameIdToWamoIdToStatus; // todo change to wamoIdToStatus
    // for game x, token id of wamo on index y, 0 if none
    mapping(uint256 => mapping(int16 => uint256)) gameIdToGridIndexToWamoId;

    /** EVENTS */
    event GameCreated();
    event WamoCreated();
    event GameStarted();

    constructor(
        address _wamosAddr,
        address _vrfCoordinatorAddr,
        bytes32 _vrfKeyHash,
        uint64 _vrfSubscriptionId
    ) VRFConsumerBaseV2(_vrfCoordinatorAddr) {
        // instantiate wamos interface
        wamos = WamosV1(_wamosAddr);
        // instantiate vrf coordinator interface
        vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinatorAddr);
        // configure coordinator variables
        vrfKeyHash = _vrfKeyHash;
        vrfSubscriptionId = _vrfSubscriptionId;
        vrfNumWords = 1;
        vrfCallbackGasLimit = 100000;
        vrfRequestConfirmations = 2;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////        MODIFIERS        ////////////////////
    /////////////////////////////////////////////////////////////////

    /** @notice Reverts function if msg.sender is not a player of gameId */
    modifier onlyPlayer(uint256 gameId) {
        if (
            gameIdToGameData[gameId].challenger != msg.sender &&
            gameIdToGameData[gameId].challengee != msg.sender
        ) {
            revert NotPlayerOfGame(gameId, msg.sender);
        }
        _;
    }

    /** @notice Reverts function if game gameId is not onfoot */
    modifier onlyOnfoot(uint256 gameId) {
        if (gameIdToGameData[gameId].status != GameStatus.ONFOOT) {
            revert GameIsNotOnfoot(gameId);
        }
        _;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////       GAME SET UP       ////////////////////
    /////////////////////////////////////////////////////////////////

    /**
     * @return id of new game created.
     */
    function createGame(address challengee) external returns (uint256) {
        address challenger = msg.sender;
        // initialise gamedata struct
        GameData memory game;
        game.id = gameCount++;
        game.players = [challenger, challengee];
        game.challenger = challenger;
        game.challengee = challengee;
        game.createTime = block.timestamp;
        game.status = GameStatus.PREGAME;
        // store game data
        gameIdToGameData[game.id] = game;
        // store challenge
        addrToChallengesSent[challenger].push(game.id);
        addrToChallengesReceived[challengee].push(game.id);
        return game.id;
    }

    // TODO allow for connection of multiple wamos at once to save gas
    function connectWamo(
        uint256 gameId,
        uint256 wamoId
    ) external onlyPlayer(gameId) {
        // TODO custom errors
        // check wamo is not already staked
        require(
            !wamoIdToStakingStatus[wamoId].isStaked,
            "Wamo is already staked!"
        );
        // check max wamos already not staked
        require(
            gameIdToPlayerToStakedCount[gameId][msg.sender] < PARTY_SIZE,
            "Maximum Wamos already staked!"
        );
        // check that sender owns wamo
        if (wamos.ownerOf(wamoId) != msg.sender) {
            revert PlayerDoesNotOwnThisWamo(wamoId, msg.sender);
        }
        // register staking request
        if (wamoIdToStakingStatus[wamoId].exists) {
            wamoIdToStakingStatus[wamoId].stakeRequested = true;
            wamoIdToStakingStatus[wamoId].gameId = gameId;
            wamoIdToStakingStatus[wamoId].isStaked = false;
        } else {
            wamoIdToStakingStatus[wamoId] = StakingStatus({
                exists: true,
                stakeRequested: true,
                gameId: gameId,
                isStaked: false
            });
        }
        // prompt wamo transfer
        wamos.safeTransferFrom(msg.sender, address(this), wamoId); // from, to, tokenId, data(bytes)
    }

    function playerReady(uint256 gameId) external onlyPlayer(gameId) {
        // TODO custom errors
        require(
            gameIdToGameData[gameId].status == GameStatus.PREGAME,
            "Must be pregame to start"
        );
        require(
            gameIdToPlayerToStakedCount[gameId][msg.sender] == PARTY_SIZE,
            "Player cannot be ready until sufficient wamos staked"
        );
        _loadWamos(gameId, msg.sender);
        gameIdToPlayerIsReady[gameId][msg.sender] = true;

        // todo simply see if other player is ready -- this player is clearly ready
        address challenger = gameIdToGameData[gameId].challenger;
        address challengee = gameIdToGameData[gameId].challengee;

        if (
            gameIdToPlayerIsReady[gameId][challenger] &&
            gameIdToPlayerIsReady[gameId][challengee]
        ) {
            gameIdToGameData[gameId].status = GameStatus.ONFOOT;
        }
    }

    function _loadWamos(uint256 gameId, address player) internal {
        uint256[PARTY_SIZE] memory party = gameIdToPlayerToWamoPartyIds[gameId][
            player
        ];
        for (uint256 i = 0; i < PARTY_SIZE; i++) {
            // TODO load full wamo stats when all traits are known
            uint256 wamoId = party[i];
            WamoTraits memory traits = wamos.getWamoTraits(wamoId);

            int16 startPosition;
            if (player == gameIdToGameData[gameId].challenger) {
                startPosition = 0 + int16(uint16(i));
            } else {
                startPosition = 255 - int16(uint16(i));
            }

            gameIdToWamoIdToStatus[gameId][wamoId] = WamoStatus({
                positionIndex: startPosition,
                health: traits.health,
                stamina: traits.stamina,
                mana: traits.mana
            });
        }
    }

    function onERC721Received(
        address operator, // should be wamos contract
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        if (operator == address(this)) {
            // match wamo with game and player (from)
            if (wamoIdToStakingStatus[tokenId].stakeRequested) {
                // get game id from staking request struct
                uint256 gameId = wamoIdToStakingStatus[tokenId].gameId;
                uint256 stakedCount = gameIdToPlayerToStakedCount[gameId][from];
                // toggle staked
                wamoIdToStakingStatus[tokenId].isStaked = true;
                // add wamo to players party in game
                // party array is fixed size, so set as index stakedCount
                gameIdToPlayerToWamoPartyIds[gameId][from][
                    stakedCount
                ] = tokenId;
                // add to stake count
                gameIdToPlayerToStakedCount[gameId][from]++;
            }
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    GAMEPLAY FUNCTIONS   ////////////////////
    /////////////////////////////////////////////////////////////////

    /**
     * @dev move and use ability in a single function call
     *  Design choice would save time (ie one transaction instead of two), however
     *  would likely increase gas, due to the number of require statements needed to
     *  confirm permissibility of move + ability combo.
     */
    function commitTurn(
        uint256 gameId,
        uint256 wamoId,
        uint256 moveChoice,
        uint256 abilityChoice,
        int16 targetGridIndex,
        bool moveBeforeAbility,
        bool useAbility
    ) external onlyPlayer(gameId) onlyOnfoot(gameId) {
        require(targetGridIndex < 256, "Target square must be on the grid!");
        if (abilityChoice >= wamos.ABILITY_SLOTS()) {
            revert InvalidAbilityIndex(gameId, msg.sender);
        }
        if (moveChoice >= wamos.MOVE_CHOICE()) {
            revert InvalidMoveIndex(gameId, msg.sender);
        }
        if (!wamoIdToStakingStatus[wamoId].isStaked) {
            revert WamoNotInGame(gameId, wamoId);
        }
        if (gameIdToWamoIdToStatus[gameId][wamoId].health == 0) {
            revert WamoHasNoHealth(gameId, wamoId);
        }
        uint256 turnCount = gameIdToGameData[gameId].turnCount;
        if (
            (msg.sender == gameIdToGameData[gameId].challenger &&
                turnCount % 2 == 1) ||
            (msg.sender == gameIdToGameData[gameId].challengee &&
                turnCount % 2 == 0)
        ) {
            revert NotPlayersTurn(gameId, msg.sender);
        }
        _commitTurn(
            gameId,
            wamoId,
            moveChoice,
            abilityChoice,
            targetGridIndex,
            moveBeforeAbility,
            useAbility
        );
    }

    function resign(
        uint256 gameId
    ) external onlyPlayer(gameId) onlyOnfoot(gameId) {
        // other player wins
        // TODO change so that this simply sets calls wamos health to zero
        address victor;
        address loser;
        if (msg.sender == gameIdToGameData[gameId].challenger) {
            victor = gameIdToGameData[gameId].challengee;
            loser = gameIdToGameData[gameId].challenger;
        } else {
            victor = gameIdToGameData[gameId].challenger;
            loser = gameIdToGameData[gameId].challengee;
        }
        _endGame(gameId, victor, loser);
    }

    function claimVictory(
        uint256 gameId
    ) external onlyPlayer(gameId) onlyOnfoot(gameId) {
        // get loser
        address loser;
        if (msg.sender == gameIdToGameData[gameId].challenger) {
            loser = gameIdToGameData[gameId].challengee;
        } else {
            loser = gameIdToGameData[gameId].challenger;
        }
        // check losers wamos
        uint256[PARTY_SIZE] memory loserParty = gameIdToPlayerToWamoPartyIds[
            gameId
        ][loser];
        uint256 partyHealth;
        for (uint i = 0; i < PARTY_SIZE; i++) {
            partyHealth =
                partyHealth +
                gameIdToWamoIdToStatus[gameId][loserParty[i]].health;
        }
        if (partyHealth == 0) {
            _endGame(gameId, msg.sender, loser);
        } else {
            revert PlayerFalselyClaimsVictory(gameId, msg.sender);
        }
    }

    /////////////////////////////////////////////////////////////////
    //////////////////// INTERNAL GAME FUNCTIONS ////////////////////
    /////////////////////////////////////////////////////////////////

    function _commitTurn(
        uint256 gameId,
        uint256 wamoId,
        uint256 moveChoice,
        uint256 abilityChoice,
        int16 targetGridIndex,
        bool moveBeforeAbility,
        bool useAbility
    ) internal {
        // get traits for attack and stamina/mana stats
        WamoTraits memory actorTraits = wamos.getWamoTraits(wamoId);

        int16 attackerPosition = gameIdToWamoIdToStatus[gameId][wamoId]
            .positionIndex;
        uint256 targetWamoId = gameIdToGridIndexToWamoId[gameId][
            targetGridIndex
        ];
        // move first? adjust position
        if (moveBeforeAbility) {
            attackerPosition = _setWamoPosition(
                gameId,
                wamoId,
                moveChoice,
                attackerPosition
            );
        }
        if (useAbility) {
            uint256 damage = _calculateDamage(
                gameId,
                wamoId,
                targetWamoId,
                abilityChoice
            );
            _dealDamage(gameId, targetWamoId, damage);
            // todo subtract energy cost
        }
        if (!moveBeforeAbility) {
            _setWamoPosition(gameId, wamoId, moveChoice, attackerPosition);
        }
        // todo update energy cost regen
        gameIdToWamoIdToStatus[gameId][wamoId].stamina +
            actorTraits.energyRegen;
        gameIdToWamoIdToStatus[gameId][wamoId].mana + actorTraits.energyRegen;
        // todo emit damage event
        // todo emit movement event
    }

    function _setWamoPosition(
        uint256 gameId,
        uint256 wamoId,
        uint256 moveChoice,
        int16 actorPosition
    ) internal returns (int16 newPosition) {
        // new
        int16 indexMutation = wamos.getWamoTraits(wamoId).movements[moveChoice];
        // erase prev pos
        gameIdToGridIndexToWamoId[gameId][actorPosition] = 0;
        // calculate new position
        newPosition = actorPosition + indexMutation;
        // map new index position to wamo id
        gameIdToGridIndexToWamoId[gameId][actorPosition] = wamoId;
        // store new position in wamo status
        gameIdToWamoIdToStatus[gameId][wamoId].positionIndex = newPosition;
        return newPosition;
    }

    function _calculateDamage(
        uint256 gameId,
        uint256 actingWamoId,
        uint256 targetWamoId,
        uint256 abilityChoice
    ) internal view returns (uint256 damage) {
        Ability memory a = wamos.getWamoAbility(actingWamoId, abilityChoice);
        // if target out of range the attack deals no damage
        if (
            euclideanDistance(
                gameIdToWamoIdToStatus[gameId][actingWamoId].positionIndex,
                gameIdToWamoIdToStatus[gameId][targetWamoId].positionIndex
            ) > a.range
        ) {
            damage = 0;
        } else if (
            (a.damageType == DamageType.MEELEE ||
                a.damageType == DamageType.RANGE) &&
            gameIdToWamoIdToStatus[gameId][actingWamoId].stamina < a.cost
        ) {
            damage = 0;
        } else if (
            a.damageType == DamageType.MAGIC &&
            gameIdToWamoIdToStatus[gameId][actingWamoId].mana < a.cost
        ) {
            damage = 0;
        } else {
            WamoTraits memory attacker = wamos.getWamoTraits(actingWamoId);
            WamoTraits memory defender = wamos.getWamoTraits(targetWamoId);
            // determine if attack is a critical hit
            uint256 crit = 1;
            if ((attacker.luck / (block.timestamp % 5) + a.accuracy) > 99) {
                crit = 2;
            }
            // isolate attack and defend stat
            uint256 att;
            uint256 def;
            if (a.damageType == DamageType.MEELEE) {
                att = attacker.meeleeAttack;
                def = defender.meeleeDefence;
                gameIdToWamoIdToStatus[gameId][actingWamoId].stamina - a.cost;
            } else if (a.damageType == DamageType.MAGIC) {
                att = attacker.magicAttack;
                def = defender.magicDefence;
                gameIdToWamoIdToStatus[gameId][actingWamoId].mana - a.cost;
            } else {
                att = attacker.rangeAttack;
                def = defender.rangeDefence;
                gameIdToWamoIdToStatus[gameId][actingWamoId].stamina - a.cost;
            }
            /////////////////    DAMAGE ALGORITHM    ////////////////////
            damage =
                ((((((2 * a.accuracy) / 50) + 10) * a.power * (att / def)) /
                    50) + 2) *
                (80 + (block.timestamp % 15));
            /////////////////////////////////////////////////////////////
        }
    }

    function _dealDamage(
        uint256 gameId,
        uint256 targetWamoId,
        uint256 damage
    ) internal {
        uint256 targetHealth = gameIdToWamoIdToStatus[gameId][targetWamoId]
            .health;
        if (damage > targetHealth) {
            gameIdToWamoIdToStatus[gameId][targetWamoId].health = 0;
        } else {
            gameIdToWamoIdToStatus[gameId][targetWamoId].health =
                targetHealth -
                damage;
        }
    }

    // TODO
    function _endGame(uint256 gameId, address victor, address loser) internal {
        // alter wamos record
        // distribute spoils
        // return wamos to players
        // toggle staking status to unstaked
        // toggle game status to finished
    }

    function _recordVictories(uint256 gameId, address victor) internal {
        uint256[PARTY_SIZE] memory party = gameIdToPlayerToWamoPartyIds[gameId][
            victor
        ];
        for (uint i = 0; i < PARTY_SIZE; i++) {
            wamos.recordWin(party[i]);
        }
    }

    function _recordDefeats(uint256 gameId, address loser) internal {
        uint256[PARTY_SIZE] memory party = gameIdToPlayerToWamoPartyIds[gameId][
            loser
        ];
        for (uint i = 0; i < PARTY_SIZE; i++) {
            wamos.recordWin(party[i]);
        }
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////     VIEW FUNCTIONS      ////////////////////
    /////////////////////////////////////////////////////////////////

    function getPlayerStakedCount(
        uint256 gameId,
        address player
    ) public view returns (uint256 wamosStaked) {
        wamosStaked = gameIdToPlayerToStakedCount[gameId][player];
        return wamosStaked;
    }

    function getWamoStakingStatus(
        uint256 wamoId
    ) public view returns (StakingStatus memory) {
        return wamoIdToStakingStatus[wamoId];
    }

    function isPlayerReady(
        uint256 gameId,
        address player
    ) public view returns (bool) {
        return gameIdToPlayerIsReady[gameId][player];
    }

    function getGameData(uint256 gameId) public view returns (GameData memory) {
        if (gameId >= gameCount) {
            revert GameDoesNotExist(gameId);
        }
        return gameIdToGameData[gameId];
    }

    function getGameStatus(uint256 gameId) public view returns (GameStatus) {
        return gameIdToGameData[gameId].status;
    }

    function getPlayerParty(
        uint256 gameId,
        address player
    ) public view returns (uint256[PARTY_SIZE] memory wamoIds) {
        wamoIds = gameIdToPlayerToWamoPartyIds[gameId][player];
        return wamoIds;
    }

    // @notice TODO reconsider returning an array here? tooo gassy? how else though?
    function getChallengesReceivedBy(
        address player
    ) public view returns (uint256[] memory) {
        return addrToChallengesReceived[player];
    }

    function getChallengesSentBy(
        address player
    ) public view returns (uint256[] memory) {
        return addrToChallengesSent[player];
    }

    // TODO new mapping? wamoId => positionIndex.
    // no need for nested mapping as wamo could only be in one game at a time?
    function getWamoPosition(
        uint256 gameId,
        uint256 wamoId
    ) public view returns (int16 positionIndex) {
        positionIndex = gameIdToWamoIdToStatus[gameId][wamoId].positionIndex;
        return positionIndex;
    }

    /**
     * @notice Returns the wamoID of the wamo occupying the specified grid tile index
     * @notice If the tile is unnocupied, a 0 is returned.
     */
    function getGridTileOccupant(
        uint256 gameId,
        int16 gridIndex
    ) public view returns (uint256 wamoId) {
        wamoId = gameIdToGridIndexToWamoId[gameId][gridIndex];
    }

    function getWamoStatus(
        uint256 gameId,
        uint256 wamoId
    ) public view returns (WamoStatus memory) {
        return gameIdToWamoIdToStatus[gameId][wamoId];
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////    CONTRACT SETTERS     ////////////////////
    /////////////////////////////////////////////////////////////////

    function setPlayerTag(string calldata newPlayerTag) public {
        addrToPlayerTag[msg.sender] = newPlayerTag;
    }

    /////////////////////////////////////////////////////////////////
    ////////////////////   OVERRIDE FUNCTIONS    ////////////////////
    /////////////////////////////////////////////////////////////////

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {}

    /////////////////////////////////////////////////////////////////
    ////////////////////   LIBRARY  FUNCTIONS    ////////////////////
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
}
