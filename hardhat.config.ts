import 'hardhat-typechain'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-waffle'
import '@eth-optimism/hardhat-ovm'
import 'hardhat-contract-sizer'

import { BigNumber, providers } from 'ethers'

import { extendEnvironment } from "hardhat/config";
extendEnvironment((hre) => {
  if (hre.network.name == 'optimism') {
    // Override Waffle Fixtures to be no-ops, because l2geth does not support
    // snapshotting
    // @ts-ignore
    hre.waffle.loadFixture = async (fixture: Promise<any>) => await fixture()

    // Temporarily set gasPrice = 0, until l2geth provides pre-funded l2 accounts.
    const provider = new providers.JsonRpcProvider("http://localhost:8545")
    provider.getGasPrice = async () => BigNumber.from(0)
    hre.ethers.provider = provider
  }
});

export default {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    optimism: {
      url: "http://localhost:8545",
      ovm: true,
    },
  },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1,
      },
      metadata: {
        // do not include the metadata hash, since this is machine dependent
        // and we want all generated code to be deterministic
        // https://docs.soliditylang.org/en/v0.7.6/metadata.html
        bytecodeHash: 'none',
      },
    },
  },
}
