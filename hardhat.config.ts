import '@typechain/hardhat'
import '@nomiclabs/hardhat-ethers'
import * as dotenv from 'dotenv'
import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import 'hardhat-contract-sizer'
import 'hardhat-abi-exporter'

dotenv.config()

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.18',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      goerli: process.env.GOERLISCAN_API_KEY ?? ''
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD'
  },
  typechain: {
    outDir: 'typechain-types',
    target: 'ethers-v5'
  },
  abiExporter: {
    runOnCompile: true,
    clear: true,
    flat: true
  }
}

export default config
