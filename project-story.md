# Wam0s Project Story
A project by team 3_RiGBY

## Inspiration

Could the genre of monster battling game be implemented as an open source protocol? Could the monsters be tradeable and sellable, allowing the time that players invest into their monsters to be reflected by a price? Could monster battling games be commodified?
With the alignment of new technologies blazing in our vision, we started to believe that a new kind of game can exist: a living, independent, perpetuating game, decentralised - bestowed with infinity.

## What It Does

Wam0s are Wallet Monsters.

The Wam0s Protocol is a decentralised monster battling game. 

The protocol allows any player to spawn Wam0s and battle their Wam0s against anyone in the world, without the need of a centralised authority.

The Wam0sV1 Contract is an NFT contract, an extension of the ERC721 contract standard. When a Wam0 is spawned,  the Chainlink VRF oracle is called to provide a random word. That random word is used to set the traits, special traits, and abilities of the Wam0. 

The Wam0sBattleV1 Contract is the BattleGrid where Wam0s battle and win glory. With an invite the player is taken to a Battle Lobby. Here,  both players must stake an equal number of Wam0s to the Wam0sBattleV1 contract to start the game. 

A turn based monster battle game on a board like a chess board, your Wam0s are pieces which can move and attack in unique ways.

The player with the last standing Wam0 wins all the glory. When the game is over, the result of the game is permenantly etched on the Wam0s records. The Wam0s are returned to their owner…never the same.

## How We Built It

We were struck by a vision of a decentralised PvP monster battle game protocol - an evolution of the games of our childhood that captured our imaginations, integrated into the interconnected world of the blockchain and designed for an open market economy.

The protocol was developed in a combined environment of foundry and hardhat: foundry for rapid contract compilation and testing, hardhat for scripting and console interactions with deployments on the mumbai testnet. A Test Driven Development philosophy was practiced throughout the development cycle, with tests being written in unison with source code.

The game grew from humble beginnings of players connecting their wallets to a minimal data structure and moving index positions around a grid, before the Wam0s ERC721 was created and the game was expanded to the complete staking and battling protocol that was submitted.

## Challenges We Ran Into

The primary challenge was creating a secure and comprehensive game protocol, which could account for all possible exceptions and user inputs while maintaining gas efficiency, in order to keep the game affordable for all players, and wrestling with the memory and stack limitations when working with solidity. This was partially solved by leveraging arrays, with players submitting their choice of move as an index of the array of movements or abilities available to their Wam0, rather than raw input.

A further challenge was converting the 256 bit random word generated by the Chainlink VRF consumption into the myriad of traits and abilities which defines each wamo. This was solved with a custom word splitting function, designed to split the large random word facilitaed by Chainlink into smaller 2 digit random numbers, providing a set of random data for the trait and ability generation functions.

## Accomplishments We're Proud Of

We're proud of designing and implementing what we believe to be the maturation of monster battle games: decentralised, permissionless, trustless, not reliant on any company or team of developers for continuation or perpetuation, built around an open market economy for game tokens. Just as the simple melodies of sine waves and simple 16 bit pixel art of the handheld monster battling games of our youth were products of technical limitations and necessity on the part of the developers, so too was the isolation of each players world and the confinement of their monsters to their game cartridge. The interconnected arena protocol we have implemented creates a world of vast interconnection - one world. 

Furthermore, even modern games and recent web3 games with inbuilt token economies rely on the application and servers of a centralised entity or company for persistence. If the company collapses, the decentralisation of the token system is useless, and the tokens are rendered unusable. Wam0s is a game that is not owned by anyone, but accessible by everyone. Wam0s is truly decentralised. Taking a step toward realising the vision of a totally decentralised token economy built on a trustless game logic protocol is what we view as our greatest achievement.

## What We learned

We learned that anything worth doing is not easy, but the drive fuelled by a clear purpose and a vision of crystal clear clarity makes work toward it a pleasure.

## What's Next

All eyes to the sky, an omen from the Wam0 G0ds! Wam0sV2 is on the horizon: breeding, battle grid terrain, gear, item synthesis, lending agreements, champion sponsorship, glory...