import React, { Component } from "react";
import { ethers } from "ethers";
import { WamoProfile } from "../components/WamoProfile";
import "../app.css";

import WamosV2Artifact from "../contracts/WamosV2.json";
import WamosV2Address from "../contracts/WamosV2-contract-address.json";

const MUMBAI_NETWORK_ID = "80001";
const WAMOSV1_PRICE = ethers.utils.parseEther("0.01");
const GAS_LIMIT = ethers.utils.parseEther("0.000000000001");

export class WamoSpawner extends Component {
  constructor(props) {
    super(props);
    this.initialState = {
      _provider: undefined,
      wamos: undefined,
      wamosAddress: "unconnected",
      wamosTokenCount: undefined,
      mintPrice: undefined,
      isMintInProgress: false,
      isRequestFulfilled: false,
      isCompletionInProgress: false,
      isMintComplete: false,
      lastRequestId: 0,
      lastWamosSpawned: [],
      selectedAddress: props.address,
      testWamoId: undefined,
      testWamoTraits: {},
      testWamoAbilities: {},
    };
    this.state = this.initialState;
  }

  async componentDidMount() {
    this._initialize();
  }

  componentDidUpdate() {
    // console.log(this.state);
  }

  async _initialize() {
    this._provider = new ethers.providers.Web3Provider(window.ethereum);
    this.state.wamos = new ethers.Contract(
      WamosV2Address.WamosV2,
      WamosV2Artifact.abi,
      this._provider.getSigner(0)
    );

    const mintPrice = await this.state.wamos.mintPrice();
    const wamosAddress = await this.state.wamos.address;
    const wamosTokenCount = (await this.state.wamos.nextWamoId()) - 1;

    this.setState({
      mintPrice,
      wamosAddress,
      wamosTokenCount,
    });

    // //// FOR PROFILE TESTS /////
    // const testId = 26
    // const traits = await this.state.wamos.getTraits(testId);
    // this.setState({ testWamoId: 26})
    // this.setState({ testWamoTraits: traits });
  }

  sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  logTraits(traits) {
    for (const property in traits) {
      if (isNaN(Number(property))) {
        console.log(`${traits[property].toString()} | ${property}`);
      }
    }
  }

  async requestSpawn(numberToSpawn) {
    console.log(`** Requesting Wam0 spawn...`);
    const params = { value: WAMOSV1_PRICE, gasLimit: GAS_LIMIT };
    let requestEvent;
    try {
      // send request
      const requestTx = await this.state.wamos.requestSpawn(
        numberToSpawn,
        params
      );
      // update state
      this.setState({ isMintInProgress: true });
      // get request details from tx event
      const receipt = await requestTx.wait();
      requestEvent = receipt.events.find(
        (event) => event.event === "SpawnRequested"
      );
      const [buyerAddress, requestId, firstWamoId, number] = requestEvent.args;
      // todo remove testWamoId when contract redeployed
      this.setState({ lastRequestId: requestId, testWamoId: firstWamoId });
      console.log(
        `--> Spawn Request lodged\n\
        Request ID: ${requestId}\n\
        First Wamo ID: ${firstWamoId}`
      );

      if (requestEvent.args.requestId !== 0) {
        console.log(
          `Lets repeatedly check the fulfillment at timed intervals!!!!`
        );
        await this._checkRequest(requestId);
      } else {
        console.log(`Something went wrong with the request...`);
      }
    } catch (error) {
      console.log(error);
    }
  }

  async _checkRequest(requestId) {
    console.log(`checking request status...`);
    let requestData = await this.state.wamos.getRequest(requestId);
    let isFulfilled = requestData.isFulfilled;
    let waitCount = 0;
    const maxWait = 30;
    while (!isFulfilled) {
      // set state to request checking
      console.log(`entered check loop`);
      if (waitCount > maxWait) {
        console.log(`## Timed out waiting for request fulfillment...`);
        break;
      }
      waitCount++;
      await this.sleep(2000);
      requestData = await this.state.wamos.getRequest(requestId);
      isFulfilled = requestData.isFulfilled;
    }
    if (isFulfilled) {
      console.log(`Request Fulfilled!`);
      this.setState({ isRequestFulfilled: true });
    }
  }

  async completeSpawn() {
    const requestId = this.state.lastRequestId;
    console.log(`** Completing spawn with requestId ${requestId}`);

    // send complete spawn transaction
    const completeTx = await this.state.wamos.completeSpawn(requestId);

    // set state
    this.setState({ isCompletionInProgress: true });

    console.log(`Getting tx receipt`);
    const receipt = await completeTx.wait();
    const completionEvent = receipt.events.find(
      (event) => event.event === "SpawnCompleted"
    );

    // const [, , firstWamoId, lastWamoId] = completionEvent.args;

    const firstWamoId = this.state.testWamoId;

    console.log(`first wamo id: ${firstWamoId}`);

    const traits = await this.state.wamos.getTraits(firstWamoId);
    const abilities = await this.state.wamos.getAbilities(firstWamoId);

    localStorage.setItem("lastWamoTraits", traits);
    localStorage.setItem("lastWamoAbilities", abilities);

    //// LOG TRAITS /////
    console.log(`\n---- Wamo #${firstWamoId} Traits ----\n`);
    for (const property in traits) {
      if (isNaN(Number(property))) {
        console.log(`${traits[property].toString()} | ${property}`);
      }
    }

    this.setState({
      isMintInProgress: false,
      isCompletionInProgress: false,
      isMintComplete: true,
      testWamoId: firstWamoId,
      testWamoTraits: traits,
      testWamoAbilities: abilities,
    });
  }

  async resetMint() {
    this.setState({
      isMintInProgress: false,
      isRequestFulfilled: false,
      isCompletionInProgress: false,
      isMintComplete: false,
    });
  }

  render() {
    const wamosAddress = this.state.wamosAddress.substring(0, 6);
    const tokenCount = this.state.wamosTokenCount;

    const handleRequest = () => {
      this.requestSpawn(1);
    };

    const handleComplete = () => {
      this.completeSpawn();
    };

    const handleSpawnAgain = () => {
      this.resetMint();
    };

    const TEST_TIME = false;
    //// FOR PROFILE TESTS
    if (TEST_TIME) {
      const wamoId = this.state.testWamoId;
      const traits = this.state.testWamoTraits;
      const abilities = this.state.testWamoAbilities;
      return (
        <div className="oozepits">
          <WamoProfile wamoId={wamoId} traits={traits} abilities={abilities} />
        </div>
      );
    }

    if (this.state.isMintComplete) {
      // display wamo profile
      const wamoId = this.state.testWamoId;
      const traits = this.state.testWamoTraits;
      const abilities = this.state.testWamoAbilities;
      // mint again goyim?
      return (
        <div className="article">
          <div className="x-center y-center a-center">
            <h2>Spawn Complete!</h2>
            <h3>You own: Wam0 #{wamoId.toString()}</h3>
          </div>

          <div className="x-center y-center a-middle a-center">
            <WamoProfile
              wamoId={wamoId}
              traits={traits}
              abilities={abilities}
            />
          </div>

          <button
            className="gen-button x-center y-center a-bottom a-center"
            onClick={handleSpawnAgain}
          >
            <h1>Spawn Again? </h1>
          </button>
        </div>
      );
    }
    if (this.state.isCompletionInProgress) {
      return (
        <div className="article">
          <div className="x-center y-center a-center">
            <h1>
              From the bubbling oozepits of the techno-rupture, new Wam0s are
              birthed...
            </h1>
          </div>
        </div>
      );
    }
    if (!this.state.isMintInProgress) {
      return (
        <div className="article">
          <div className="pop-count x-center y-center a-center">
            <h1>
              Wam0sV2_{wamosAddress ? wamosAddress.substring(0, 6) : "......"}
              population: {tokenCount ? tokenCount : "..."}
            </h1>
          </div>

          <button
            className="gen-button x-center y-center a-middle a-center"
            onClick={handleRequest}
          >
            <h1>Spawn a Wam0</h1>
          </button>
        </div>
      );
    }
    if (this.state.isMintInProgress && !this.state.isRequestFulfilled) {
      return (
        <div className="article">
          <div className="x-center y-center a-center">
            <h1>Communicating with the G0ds...</h1>
          </div>
        </div>
      );
    }
    if (this.state.isRequestFulfilled) {
      return (
        <div className="article">
          <div className="x-center y-center a-center">
            <h1>the G0ds are willing...</h1>
          </div>
          {this.state.isRequestFulfilled ? (
            <button
              className="gen-button x-center y-center a-middle a-center"
              onClick={handleComplete}
            >
              <h1>Complete Sacrifice? </h1>
            </button>
          ) : (
            <h4>waiting for fulfllment...</h4>
          )}
        </div>
      );
    }
  }
}
