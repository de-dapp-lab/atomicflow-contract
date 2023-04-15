import { ethers } from 'hardhat'

async function main() {
  const recieverAddress = '0xD1049F82d75D5AdC81586DA8F9E85723eC4CA4a3'

  const SubscriptionManager = await ethers.getContractFactory(
    'SubscriptionManager'
  )
  const subscriptionManager = await SubscriptionManager.deploy(recieverAddress)

  await subscriptionManager.deployed()

  console.log(
    `Deployed to ${subscriptionManager.address} with 'reciever' set as ${recieverAddress}.`
  )
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
