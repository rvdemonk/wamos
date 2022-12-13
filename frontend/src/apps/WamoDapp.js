import React from "react";
import "../app.css";
import { ethers } from "ethers";
import WamosBattleV1Artifact from "../contracts/WamosBattleV1.json";
import WamosBattleV1contractAddress from "../contracts/WamosBattleV1-contract-address.json";
import WamosV1Artifact from "../contracts/WamosV1.json";
import WamosV1contractAddress from "../contracts/WamosV1-contract-address.json";
import { Menu } from "../components/Menu";
import { MenuOrJoin } from "../components/MenuOrJoin";
import { Join } from "../components/Join";
import { BattleGrid } from "../components/BattleGrid";
import { ApproveBattleStaking } from "../components/ApproveBattleStaking";
import { Loading } from "../components/Loading";
import { Lobby } from "../components/Lobby";

export class WamoDapp extends React.Component {
  constructor(props) {
    super(props);
    this.initialState = {
      _provider: undefined,
      attemptRetrieveStaking: false,
      battleAddress: undefined,
      block: undefined,
      cellIden: undefined,
      challengesReceived: [],
      challengesSent: [],
      expanded: false,
      gameData: undefined,
      gameDataList: [],
      gameDataListReady: false,
      gasLimit: 1122744,
      gasPrice: 8000000000,
      grid: undefined,
      grid_size: undefined,
      hasApprovedStaking: undefined,
      id: undefined,
      isPlayer1: undefined,
      isTurn: undefined,
      isTurnAddress: undefined,
      menuCreate: false,
      menuJoin: false,
      Player1: undefined,
      Player2: undefined,
      P1Address: props.address,
      P2Address: undefined,
      stageWamoMoveIndex: -1,
      showMoves: false,
      wamoActive: -1,
      wamoGroup: {},
      wamoGroupReady: false,
      wamosbattlev1: undefined,
      wamosv1: undefined,
    };
    this.state = this.initialState;
  }

  render() {
    // renders wamo battle dapp

    if (!this.state.wamosbattlev1 && !this.state.wamosv1) {
      this._initializeEthers();
    }
    return (
      <div>
        {!this.state.attemptRetrieveStaking && <Loading />}
        {!this.state.id &&
          this.state.attemptRetrieveStaking &&
          !this.state.hasApprovedStaking && (
            <ApproveBattleStaking
              state={this.state}
              approveBattleStaking={() => this._approveBattleStaking()}
              isBattleStakingApproved={() => this._isBattleStakingApproved()}
            />
          )}
        {!this.state.id &&
          this.state.hasApprovedStaking &&
          !this.state.menuCreate &&
          !this.state.menuJoin && (
            <MenuOrJoin
              toggleMenuCreate={() => this._toggleMenuCreate()}
              toggleMenuJoin={() => this._toggleMenuJoin()}
            />
          )}
        {!this.state.id && this.state.menuCreate && (
          <Menu
            state={this.state}
            challengesReceived={this.state.challengesReceived}
            createGame={(to) => this._createGame(to)}
            connectWallet={() => this.connectWallet}
          ></Menu>
        )}
        {!this.state.id && this.state.menuJoin && (
          <Join
            state={this.state}
            joinGameSent={(index) => this._joinGameSent(index)}
            joinGameReceived={(index) => this._joinGameReceived(index)}
            updateChallenges={() => this._updateChallenges()}
            getGameData={(id) => this._getGameData(id)}
          />
        )}
        {this.state.id && this.state.gameStatus === 0 && (
          <Lobby
            state={this.state}
            connectWamo={(wamoId, id) => this._connectWamo(wamoId, id)}
            getGameStatus={() => this._getGameStatus()}
          ></Lobby>
        )}
        {this.state.id && this.state.gameStatus === 1 && (
          <BattleGrid
            state={this.state}
            updateWamos={() => this._updateWamos()}
            expandProfile={() => this._expandProfile()}
            commitTurn={(
              targetWamoId,
              moveChoice,
              abilityChoice,
              isMoved,
              moveBeforeAbility,
              useAbility
            ) =>
              this._commitTurn(
                targetWamoId,
                moveChoice,
                abilityChoice,
                isMoved,
                moveBeforeAbility,
                useAbility
              )
            }
            makeActive={(wamoIndex) => this._makeActive(wamoIndex)}
            stageWamoMove={(targetId) => this._stageWamoMove(targetId)}
          ></BattleGrid>
        )}
      </div>
    );
  }

  async _initializeEthers() {
    // init ethers
    this._provider = new ethers.providers.Web3Provider(window.ethereum);

    // init battle contract
    this.state.wamosbattlev1 = new ethers.Contract(
      WamosBattleV1contractAddress.WamosBattleV1,
      WamosBattleV1Artifact.abi,
      this._provider.getSigner(0)
    );
    // init wamos contract
    this.state.wamosv1 = new ethers.Contract(
      WamosV1contractAddress.WamosV1,
      WamosV1Artifact.abi,
      this._provider.getSigner(0)
    );
    this._isBattleStakingApproved();
  }

  async _isBattleStakingApproved() {
    // checks if battle staking is approved

    try {
      await new Promise((r) => setTimeout(r, 2000));

      console.log("Connected user : ", this.state.P1Address);
      console.log("Battle Address : ", this.state.wamosbattlev1.address);

      const hasApprovedStaking = await this.state.wamosv1.isApprovedForAll(
        this.state.P1Address,
        this.state.wamosbattlev1.address
      );

      this.setState({ hasApprovedStaking });
      this.setState({ attemptRetrieveStaking: true });
    } catch (error) {
      console.log(error);
    }
  }

  async _approveBattleStaking() {
    // approves battle staking

    try {
      await new Promise((r) => setTimeout(r, 2000));
      await this.state.wamosv1.approveBattleStaking({
        gasLimit: this.state.gasLimit,
        gasPrice: this.state.gasPrice,
      });
      this.setState({ hasApprovedStaking: true });
    } catch (error) {
      console.log(error);
    }
  }

  _toggleMenuCreate() {
    // toggles this.state.menuCreate bool
    this.setState({ menuCreate: !this.state.menuCreate });
  }

  _toggleMenuJoin() {
    // toggles this.state.menuJoin bool
    this.setState({ menuJoin: !this.state.menuJoin });
  }

  async _joinGameSent(index) {
    // Join sent game by index

    var challengesSent = this.state.challengesSent;
    if (!challengesSent) {
      console.log("No invites sent");
    } else {
      const id = challengesSent[index];
      this._setGameData(id);
    }
  }

  async _joinGameReceived(index) {
    // Join received game by index

    var challengesReceieved = this.state.challengesReceived;
    if (!challengesReceieved) {
      console.log("No invites received");
    } else {
      const id = challengesReceieved[index];
      this._setGameData(id);
    }
  }

  async _createGame(Player2, partySize) {
    // Player1(user) creates game with Player2(opponent address)

    try {
      await new Promise((r) => setTimeout(r, 2000));
      const id = await this.state.wamosbattlev1.createGame(Player2);

      this.setState({
        P2Address: Player2,
      });

      this._setGameData(id);
    } catch (error) {
      console.log(error);
    }
  }

  async _getGameData(id) {
    // get game data for all games

    try {
      await new Promise((r) => setTimeout(r, 2000));

      const gameData = await this.state.wamosbattlev1.getGameData(id);

      this.state.gameDataList[id] = {
        id: gameData.id,
        players: gameData.players,
        status: gameData.status,
      };
      // console.log(this.state.gameDataList[i]);
    } catch (error) {
      console.log(error);
    }
  }

  async _setGameData(id) {
    //sets local game data from game id

    try {
      await new Promise((r) => setTimeout(r, 2000));

      id = !id._isBigNumber ? id.value.toString() : id;
      const gameData = await this.state.wamosbattlev1.getGameData(id);
      this.setState({
        id: id,
        gameData: gameData,
      });

      const players = gameData.players;

      this.setState({ Player1: players[0].toLowerCase() });
      this.setState({ Player2: players[1].toLowerCase() });

      if (players[0].toLowerCase() === this.state.P1Address) {
        this.setState({ isPlayer1: true });
        this.setState({ isTurn: true });
        this.setState({ P2Address: players[1].toLowerCase() });
      }
      if (players[1].toLowerCase() === this.state.P1Address) {
        this.setState({ isPlayer1: false });
        this.setState({ P2Address: players[0].toLowerCase() });
      }
      this._getGameStatus();
    } catch (error) {
      console.log(error);
    }
  }

  async _updateGameData() {
    var id = this.state.id;
    id = !id._isBigNumber ? id.value.toString() : id;
    const gameData = await this.state.wamosbattlev1.getGameData(id);
    this.setState({
      gameData: gameData,
    });
  }

  _isTurn() {
    // evaluates whose turn it is

    if (this.state.isPlayer1 && this.state.gameData.turnCount % 2 === 0) {
      this.setState({ isTurn: true });
      this.setState({ isTurnAddress: this.state.Player1 });
    } else if (
      !this.state.isPlayer1 &&
      this.state.gameData.turnCount % 2 === 1
    ) {
      this.setState({ isTurn: true });
      this.setState({ isTurnAddress: this.state.Player2 });
    } else {
      this.setState({ isTurn: false });
    }
  }

  async _connectWamo(wamoId) {
    // connectWamo todo: change to batching
    try {
      await new Promise((r) => setTimeout(r, 2000));

      var id = this.state.id;
      id = !id._isBigNumber ? id.value.toString() : id;
      await this.state.wamosbattlev1.connectWamo(id, wamoId, {
        gasLimit: this.state.gasLimit,
        gasPrice: this.state.gasPrice,
      });
      console.log(`Wamo ${wamoId} has been staked`);
    } catch (error) {
      console.log(error);
    }
  }

  async _getPlayerParty() {
    // gets player party
    try {
      await new Promise((r) => setTimeout(r, 1000));

      var id = this.state.id;
      id = !id._isBigNumber ? id.value.toString() : id;
      const WamoChallenger = await this.state.wamosbattlev1.getPlayerParty(
        id,
        this.state.Player1,
        { gasLimit: this.state.gasLimit, gasPrice: this.state.gasPrice }
      );
      const WamoChallengee = await this.state.wamosbattlev1.getPlayerParty(
        id,
        this.state.Player2,
        { gasLimit: this.state.gasLimit, gasPrice: this.state.gasPrice }
      );
      const wamosList = [...WamoChallenger, ...WamoChallengee];

      let i = 0;
      while (i < wamosList.length) {
        const moves = await this.state.wamosv1.getWamoMovements(wamosList[i]);
        const abilities = await this.state.wamosv1.getWamoAbilities(
          wamosList[i]
        );
        const traits = await this.state.wamosv1.getWamoTraits(wamosList[i]);
        const position = await this.state.wamosbattlev1.getWamoPosition(
          id,
          wamosList[i]
        );
        const owner =
          i < wamosList.length / 2 ? this.state.Player1 : this.state.Player2;
        const isPlayer1 = i < wamosList.length / 2 ? true : false;
        const className = i < wamosList.length / 2 ? "player" : "ad";
        const wamoStatus = await this.state.wamosbattlev1.getWamoStatus(
          id,
          wamosList[i]
        );
        const health = wamoStatus.health;
        const mana = wamoStatus.mana;
        const stamina = wamoStatus.stamina;

        this.state.wamoGroup[i] = {
          wamoId: wamosList[i],
          id: wamosList[i].toString(),
          moves: moves,
          owner: owner.toLowerCase(),
          isPlayer1: isPlayer1,
          abilities: abilities,
          traits: traits,
          show: false,
          health: health,
          stamina: stamina,
          mana: mana,
          position: position,
          gridMoves: this._generateMoves(position, moves),
          className: className,
        };
        i++;
      }

      this.state.wamoGroupReady = true;
      this._initGrid();
    } catch (error) {
      console.log(error);
    }
  }

  async _initGrid() {
    //inits blank grid for html generation

    try {
      await new Promise((r) => setTimeout(r, 2000));

      const grid_size = await this.state.wamosbattlev1.GRID_SIZE();
      var grid = this._makeGrid(grid_size);

      this.setState({
        grid_size: grid_size,
        grid: grid,
      });
    } catch (error) {
      console.log(error);
    }
  }
  async _updateChallenges() {
    // updates the user's challenges

    const challengesReceived =
      await this.state.wamosbattlev1.getChallengesReceivedBy(
        this.state.P1Address
      );
    const challengesSent = await this.state.wamosbattlev1.getChallengesSentBy(
      this.state.P1Address
    );

    if (challengesReceived || challengesSent) {
      this.setState({ challengesReceived });
      this.setState({ challengesSent });
    }
  }

  async _getGameStatus() {
    // gets game status

    try {
      await new Promise((r) => setTimeout(r, 2000));
      var id = this.state.id;

      id = !id._isBigNumber ? id.value.toString() : id;
      const gameStatus = await this.state.wamosbattlev1.getGameStatus(id);

      if (gameStatus === 1) {
        this._getPlayerParty();
      }

      this.setState({ gameStatus });
    } catch (error) {
      console.log(error);
    }
  }

  _generateMoves(iden, moves) {
    //generates move indexes for wamo at certain iden

    var theseMoves = [];
    for (let i = 0; i < moves.length; i++) {
      theseMoves[i] = iden + moves[i];
    }
    return theseMoves;
  }

  async _returnOwner(wamoId) {
    //returns owner of wamoId

    try {
      await new Promise((r) => setTimeout(r, 5000));
      const owner = await this.state.wamosv1.ownerOf(wamoId);
      return owner.toString();
    } catch (error) {
      console.log(error);
    }
  }

  async _stageWamoMove(targetId) {
    console.log("stageWamoMoves", targetId);
    this.state.stageWamoMoveIndex = targetId;
  }

  async _updateWamos() {
    //updates wamos todo: make this more efficient
    try {
      await new Promise((r) => setTimeout(r, 2000));

      var id = this.state.id;
      id = !id._isBigNumber ? id.value.toString() : id;

      if (this.state.Player1 && this.state.Player2 && this.state.wamoGroup) {
        let i = 0;

        while (i < Object.keys(this.state.wamoGroup).length) {
          const wamoStatus = await this.state.wamosbattlev1.getWamoStatus(
            id,
            this.state.wamoGroup[i].wamoId
          );

          this.state.wamoGroup[i].position = wamoStatus.positionIndex;
          this.state.wamoGroup[i].health = wamoStatus.health;
          this.state.wamoGroup[i].stamina = wamoStatus.stamina;
          this.state.wamoGroup[i].mana = wamoStatus.mana;

          this.state.wamoGroup[i].gridMoves = this._generateMoves(
            this.state.wamoGroup[i].position,
            this.state.wamoGroup[i].moves
          );
          console.log("Wamos updated");
          i++;
        }
        this._updateGameData();
        this._isTurn();
      }
    } catch (error) {
      console.log(error);
    }
  }

  _makeGrid(gridSize) {
    // Create a blank grid with the specified size

    const grid = Array(gridSize).fill(null);
    return grid.map(() => Array(gridSize).fill(""));
  }

  async _commitTurn(
    //commit turn for wamo in game

    targetWamoId,
    moveChoice,
    abilityChoice,
    isMoved,
    moveBeforeAbility,
    useAbility
  ) {
    if (this.state.isTurn) {
      try {
        await new Promise((r) => setTimeout(r, 5000));

        var id = this.state.id;
        id = !id._isBigNumber ? id.value.toString() : id;

        const wamoId = this.state.wamoGroup[this.state.wamoActive].wamoId;
        const targetId = this.state.wamoGroup[targetWamoId].wamoId;

        await this.state.wamosbattlev1.commitTurn(
          id,
          wamoId,
          targetId,
          moveChoice,
          abilityChoice,
          isMoved,
          moveBeforeAbility,
          useAbility,
          { gasLimit: this.state.gasLimit, gasPrice: this.state.gasPrice }
        );
      } catch (error) {
        console.log(error);
      }
    } else {
      console.log("not your turn big boy");
    }
  }
  _showMoves() {
    // toggles showmoves
    this.setState({ showMoves: !this.state.showMoves });
  }
  _makeActive(wamoIndex) {
    // sets active wamo
    this._showMoves();
    this.setState({ wamoActive: wamoIndex });
  }

  _expandProfile() {
    const expanded = this.state.expanded;
    this.setState({ expanded: !expanded });
  }
}
