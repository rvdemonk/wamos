import React from "react";
import { ethers } from "ethers";
import { Mint } from "./Mint";
import '../app.css';

import WamosV1Artifact from "../contracts/WamosV1.json";
import contractAddress from "../contracts/WamosV1-contract-address.json";

const MUMBAI_NETWORK_ID = '80001';
const WAMOSV1_PRICE =  ethers.utils.parseEther("0.01");
const GAS_LIMIT = ethers.utils.parseEther("0.000000000001");

export class WamoMint extends React.Component {
  constructor(props) {
    super(props);
    this.initialState = {
      _provider: undefined,
      isRequestFulfilled: false,
      wamosv1: undefined,
      mintPrice: undefined,
      mintInProgress: false,
      mintComplete: false,
      currentToken: undefined,
      selectedAddress: props.address,
    }
    this.state = this.initialState;
  };

  async componentDidMount() {
    this._initialize(this.state.selectedAddress);
  }

  render() {
    // if (!this.state.wamosv1) {
    //   this._initialize(this.state.selectedAddress);
    // }

    return (
      <div className={this.state.view}>
        <Mint 
        state={this.state} 
        mintRequest={() => this._mintRequest()} 
        mintSpawn={() => this._mintSpawn()}
        mintSpawnId={(wamoId) => this._mintSpawnId(wamoId)}
        resetMintData={() => this._resetMintData()}/>
      </div>
    );
  }

  _changeMintStatus () {
    this.state.mintInProgress = !this.state.mintInProgress;
  }

  async _connectWallet() {
    const [selectedAddress] = await window.ethereum.request({ method: 'eth_requestAccounts' });
    if (!this._checkNetwork()) {
      return;
    }
    this._initialize(selectedAddress);

    window.ethereum.on("accountsChanged", ([newAddress]) => {
      // To avoid errors, we reset the dapp state 
      if (newAddress === undefined) {
        return this._resetState();
      }
    
      this._initialize(newAddress);
    });
    
    // We reset the dapp state if the network is changed
    window.ethereum.on("chainChanged", ([networkId]) => {
      this._resetState();
    });
  }

  _initialize(userAddress) {
    // This method initializes the dapp
    // We first store the user's address in the component's state
    this.setState({
      selectedAddress: userAddress,
    });

    this._initializeEthers();
    
  }

  async _initializeEthers() {
    // We first initialize ethers by creating a provider using window.ethereum
    this._provider = new ethers.providers.Web3Provider(window.ethereum);

    // Then, we initialize the contract using that provider and the token's
    // artifact. You can do this same thing with your contracts.
    this.state.wamosv1 = new ethers.Contract(
      contractAddress.WamosV1,
      WamosV1Artifact.abi,
      this._provider.getSigner(0)
    );

    const mintPrice = await this.state.wamosv1.mintPrice();

    this.setState({mintPrice});
}

  _resetMintData() {
    this._changeMintStatus();
    this.setState({mintComplete: false});
  }

  async _mintRequest() {
    try {
      await new Promise(r => setTimeout(r, 1000));
    
      console.log(`\n ** BEGINNING MINT\n`);
      const tokenCountStart = await this.state.wamosv1.tokenCount();
      const requesttx = await this.state.wamosv1.requestSpawnWamo({ value: WAMOSV1_PRICE, gasLimit: GAS_LIMIT });    
      const requestId = await this.state.wamosv1.requestIds(tokenCountStart-1);      
      const tokenId = await this.state.wamosv1.getTokenIdFromRequestId(requestId);
      console.log(`Requested wamo spawn with tx ${requesttx.hash}`);
      console.log(`-> Spawning Wamo #${tokenId}`);

      this.setState({requestId: requestId, tokenId: tokenId});

      const startBlock = await this._provider.getBlockNumber();
      const blocksToWait = 20;
      let currentBlock;

      let isRequestFulfilled = await this.state.wamosv1.getSpawnRequestStatus(requestId);
      while (!isRequestFulfilled) {
        currentBlock = await this._provider.getBlockNumber();
        console.log(`[block ${currentBlock}] randomness not fulfillled...`);
        // isRequestFulfilled = await this.state.wamosv1.getSpawnRequestStatus(requestId);
        setTimeout(async () => {
          isRequestFulfilled = await this.state.wamosv1.getSpawnRequestStatus(requestId);
        }, 5000);

        if (currentBlock - startBlock > blocksToWait) {
          console.log(
            `-> exiting process: request unfulfilled after ${blocksToWait}`
          );
          break;
        }}
        
        if (isRequestFulfilled) {
          let requestData = await this.state.wamosv1.getSpawnRequest(requestId);
          const word = requestData.randomWord;
          console.log(`\nRequest fulfilled!\n`);
          console.log(`Wamo #${tokenId} seed: ${word}`);
          console.log(`--> PLEASE COMPLETE MINT :)`);

        this.setState({isRequestFulfilled: true});
        }

      this._changeMintStatus(); 
      this.setState({currentToken: tokenId});

      } catch (error) {
      console.log(error)
    }
}

  async _mintSpawn() {
    
    try {
      
      if (this.state.isRequestFulfilled) {
        let requestData = await this.state.wamosv1.getSpawnRequest(this.state.requestId);
        const word = requestData.randomWord;
        console.log(`\nRequest for wamo #${this.state.tokenId} fulfilled!\n`);
        console.log(`random word: ${word}`);
    
        // PHASE 2: COMPLETE MINT
        console.log(`\n ** COMPLETING MINT\n`);
        const completeSpawntx = await this.state.wamosv1.completeSpawnWamo(this.state.tokenId);
        // display traits
        console.log(`Loading traits...`);
        this._displayTraits(this.state.wamosv1, this.state.tokenId);
    
      } else {
        console.log("Randomness has not yet been fulfilled.")
      }

    } catch (error) {
      console.log(error)
    }
  }

  async _mintSpawnId(wamoId) {

    try {
      console.log(`\n ** COMPLETING MINT\n`);
      await this.state.wamosv1.completeSpawnWamo(wamoId);
      // display traits
      console.log(`Loading traits...`);
      this._displayTraits(this.state.wamosv1, wamoId);
    } catch (error) {
      console.log(error)
    }
  }

  async _displayTraits(wamosContract, wamoId) {
    let traits = await wamosContract.getWamoTraits(wamoId);
    if (traits.health._hex !== "0x00") {
      console.log(`**** type of traits data -> ${typeof traits}`)

      console.log(`\n---- Wamo #${wamoId} Traits ----\n`);
      for (const property in traits) {
        if (isNaN(Number(property))) {
          console.log(`${traits[property].toString()} | ${property}`);
        }
      }

    } else {
      console.log(`## waiting for traits to display....`)
      setTimeout(() => this._displayTraits(wamosContract, wamoId), 3000);
    }

    this.setState({mintComplete: true});
  }

  // This method just clears part of the state.
  _dismissTransactionError() {
    this.setState({ transactionError: undefined });
  }

  // This method just clears part of the state.
  _dismissNetworkError() {
    this.setState({ networkError: undefined });
  }

  // This is an utility method that turns an RPC error into a human readable
  // message.
  _getRpcErrorMessage(error) {
    if (error.data) {
      return error.data.message;
    }

    return error.message;
  }

  // This method resets the state
  _resetState() {
    this.setState(this.initialState);
  }

  // This method checks if Metamask selected network is Localhost:8545 
  _checkNetwork() {
    if (window.ethereum.networkVersion === MUMBAI_NETWORK_ID) {
      return true;
    }

    this.setState({ 
      networkError: 'Please connect to MUMBAI'
    });

    return false;
  }
}
