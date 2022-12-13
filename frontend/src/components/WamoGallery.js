import React from "react";
import "../app.css";
import { ethers } from "ethers";
import WamosV1Artifact from "../contracts/WamosV1.json";
import contractAddress from "../contracts/WamosV1-contract-address.json";

import { Gallery } from "./Gallery";
import { Loading } from "./Loading";

const MUMBAI_NETWORK_ID = "80001";

export class WamoGallery extends React.Component {
  constructor(props) {
    super(props);

    this.initialState = {
      _provider: undefined,

      allWamos: [],
      wamosv1: undefined,
      selectedAddress: props.address,
      getGalleryWamos: false,
      view: "day",
    };
    this.state = this.initialState;
  }

  render() {
    if (!this.state.wamosv1) {
      this._initializeEthers();
    }
    return (
      <div>
        {!this.state.getGalleryWamos && <Loading />}

        {this.state.getGalleryWamos && <Gallery state={this.state} />}
      </div>
    );
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

    this._getWamoFromParam();
  }

  async _getWamoFromParam() {
    try {
      await new Promise((r) => setTimeout(r, 2000));

      const totalSupply = await this.state.wamosv1.tokenCount();

      console.log(totalSupply.toNumber());

      let i = 0;

      while (i < totalSupply) {
        var wamoOwner = await this.state.wamosv1.ownerOf(i);
        this.state.allWamos[i] = [i, wamoOwner];
        i++;
      }

      this.setState({ getGalleryWamos: true });
    } catch (error) {
      console.log(error);
    }
  }
}
