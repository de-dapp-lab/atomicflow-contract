# Atomicflow Contract

## Components
* Contract
* UI: https://github.com/de-dapp-lab/atomicflow-ui
* Operator: https://github.com/de-dapp-lab/atomicflow-contract

## Protocol

### Overview

The protocol consists of three main functions
- Stream transfer
- Push-based Oracle
- Contract level gate

#### Stream transfer

The main module involved is Atomicflow operator, which is in charge of sending transitions to Intmax.

#### Push-based Oracle

The part that transfers Tx generation information in L2 to L1, consisting of Atomicflow operator that is in charge of updating and Lab state contract that stores information in L1.

#### Contract level gate

This is the part that returns appropriate information for calls from third party contracts and filters them like a token gate, and is handled by Lab status contract.


### Architecture

- Above: Simplest Model, Below: Trustless Model
- At the PoC level, we aim to implement the Simplest Model once, and at the Production level, we will seek a way to do it trustless.



### Terms

Alice = Lab user, Bob = 3rd party service user

### Protocol steps

**Simplest Model** 

1. Alice creates a plan on the Atomicflow operator 
2. Bob creates and pays out Bob's Intmax wallet on the Atomicflow operator by contracting with Alice, and the status data is created based on the payment key (the hash value of the plan id and payer address combined) calculated by the lab status contract. Status data is created based on the payment key (hash value of plan id and payer address combined) calculated by the Lab status contract. 3.
3. subscription starts when a certain amount of tokens are transferred to the wallet from which Bob was paid out.
4. during subscription, the following is repeated
   1. create a signed proof of transfer from Bob's wallet to Alice on the Atomicflow operator
   2. if Bob's Asset tree is out of balance, go to 1 on failure 
   3. After sending the proof to the Intmax aggregator, sign the returned Merkle proof of tx-hash and Merkle proof of asset root and return them to the aggregator.
   4. save the completed tx-hash on the Atomicflow operator

[In case of failure]

1. Update the information on failed payment status on the Atomicflow operator. 
2. Update the status of the relevant payment key in the Lab status contract as a failure.

![arch](https://user-images.githubusercontent.com/46660741/232258972-39cfd2a7-c9c7-4aff-96b6-43a827c66fb2.png)


## Requirements

- Node: +18.12
  - Recommend using `nodenv` to automatically load the version



## Command

```shell
# Basics

yarn compile
yarn test
yarn format


# Analytics

# Get gas estimation
yarn test:gas
# Get contract size
yarn csize
```

# Other part of Atomicflow Repository
## Client
https://github.com/de-dapp-lab/atomicflow-ui

## Server
https://github.com/de-dapp-lab/atomicflow-operator
