# Transfer USDC &rarr; Subnet as Native Token

The following example will show you how to send USDC on C-Chain to a Subnet as a native token using Teleporter and Foundry. This demo is conducted on a local network run by the CLI, but can be applied to Fuji Testnet and Avalanche Mainnet directly.

**All Avalanche Interchain Token Transfer contracts and interfaces implemented in this example are maintained in the [avalanche-interchain-token-transfer](https://github.com/ava-labs/avalanche-interchain-token-transfer/tree/main/contracts/src) repository.**

If you prefer full end-to-end testing written in Golang for bridging ERC20s, native tokens, or any combination of the two, you can view the test workflows directly in the [avalanche-interchain-token-transfer](https://github.com/ava-labs/avalanche-interchain-token-transfer/tree/main/tests/flows) repository.

Deep dives on each template interface can be found [here](https://github.com/ava-labs/avalanche-interchain-token-transfer/blob/main/contracts/README.md).

_Disclaimer: The avalanche-interchain-token-transfer contracts used in this tutorial are under active development and are not yet intended for production deployments. Use at your own risk._

Note: Avalanche is updating its terminology. What is currently called a "subnet" will soon be referred to as an "L1" or "Blockchain". However, for consistency with the current Avalanche CLI and the Avalanche Starter Kit, this tutorial will continue to use the term "subnet" in some instances.

## What we have to do

1. Create a Subnet and Deploy on Local Network
2. Deploy an ERC20 Contract (USDC Example) on C-Chain
3. Deploy the Interchain Token Transferer Contracts on C-Chain and Subnet
4. Register Remote Token with Home Transferer
5. Add Collateral and Start Sending Tokens
6. Check Balances

## Local Network Environment

For convenience, the private key `56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027` of the default airdrop address is stored in the environment variable `$PK` in `.devcontainer/devcontainer.json`. Furthermore, the RPC url for the C-Chain `local-c` and Subnet created with the name `mysubnet` on the local network is set in the `foundry.toml` file.

### Subnet Configuration and Deployment

To get started, create a Subnet configuration named "mysubnet":

```bash
avalanche blockchain create mysubnet
```

Your Subnet should have the following things:

- Teleporter enabled
- CLI should run an AWM Relayer
- Upon Subnet deployment, 100,000 tokens should be airdropped to the default ewoq address (0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC)
- Native Minter Precompile enabled with either your admin address or the pre-computed Remote token address

_Note: If you have created your Subnet using AvaCloud, you can add the Remote Token address [using the dashboard](https://support.avacloud.io/avacloud-how-do-i-use-the-native-token-minter)._

```bash
✔ Subnet-EVM
✔ I don&#39;t want to use default values
✔ Use latest release version
Chain ID: 12345
Token Symbol: USDC
✔ Define a custom allocation (Recommended for production)
Address to allocate to: 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC
Amount to allocate (in USDC units): 10
✔ Yes, I want to be able to mint additional the native tokens (Native Minter Precompile ON)
✔ Add an address for a role to the allow list
✔ Admin
✔ Enter the address of the account (or multiple comma separated): 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC
✔ Confirm Allow List
+---------+--------------------------------------------+
| Admins  | 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC |
+---------+--------------------------------------------+
| Manager |                                            |
+---------+--------------------------------------------+
| Enabled |                                            |
+---------+--------------------------------------------+
✔ Yes
✔ Low block size    / Low Throughput    12 mil gas per block
✔ No, I prefer to have constant gas prices
✔ No, use the transaction fee configuration set in the genesis block
✔ Yes, I want the transaction fees to be burned
✔ Yes, I want to enable my blockchain to interoperate with other blockchains and the C-Chain
✔ Yes
creating genesis for blockchain mysubnet
Installing subnet-evm-v0.6.10...
subnet-evm-v0.6.10 installation successful
✓ Successfully created blockchain configuration
```

Finally, deploy your Subnet:

```bash
avalanche blockchain deploy mysubnet
```

```bash
? Choose a network for the operation:
✔ Local Network
```

The CLI will output addresses and information that will be important for the rest of the tutorial:

```bash
✔ Local Network
Deploying [mysubnet] to Local Network
Backend controller started, pid: 5394, output at: /home/vscode/.avalanche-cli/runs/server_20240922_185257/avalanche-cli-backend.log
Installing avalanchego-v1.11.11...
avalanchego-v1.11.11 installation successful

Booting Network. Wait until healthy...
Node logs directory: /home/vscode/.avalanche-cli/runs/network_20240922_185300/node<i>/logs
Network ready to use.

Deploying Blockchain. Wait until network acknowledges...

Teleporter Messenger successfully deployed to c-chain (0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf)
Teleporter Registry successfully deployed to c-chain (0x17aB05351fC94a1a67Bf3f56DdbB941aE6c63E25)

Teleporter Messenger successfully deployed to mysubnet (0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf)
Teleporter Registry successfully deployed to mysubnet (0x3C4ac42e719716C49A0c03713A31738aeB1C7eF2)

using awm-relayer version (v1.4.0)
Installing AWM-Relayer v1.4.0
Executing AWM-Relayer...

Blockchain ready to use

+---------------------------------------------------------------------------------------------------------------+
|                                                    MYSUBNET                                                   |
+---------------+-----------------------------------------------------------------------------------------------+
| Name          | mysubnet                                                                                      |
+---------------+-----------------------------------------------------------------------------------------------+
| VM ID         | qDNsVQJfGpi2RfCcESbeZauGqPVjtXwoopVMtrGkdoUxmFKov                                             |
+---------------+-----------------------------------------------------------------------------------------------+
| VM Version    | v0.6.10                                                                                       |
+---------------+--------------------------+--------------------------------------------------------------------+
| Local Network | ChainID                  | 12345                                                              |
|               +--------------------------+--------------------------------------------------------------------+
|               | SubnetID                 | 2AKbBT8jFUfUsUJ2hhRiDUnAAajJdNhTKeNgEe3q77spMj1N8F                 |
|               +--------------------------+--------------------------------------------------------------------+
|               | Owners (Threhold=1)      | P-custom18jma8ppw3nhx5r4ap8clazz0dps7rv5u9xde7p                    |
|               +--------------------------+--------------------------------------------------------------------+
|               | BlockchainID (CB58)      | St7VkxkbFEVSucgr8YSpXZ28Be5Jvpgc663KD7NF2vMJ4fcoV                  |
|               +--------------------------+--------------------------------------------------------------------+
|               | BlockchainID (HEX)       | 0x3ac43af4354ed6e89f461764521586ea7a042fce4c8b1210db209c3f0fdc6ec6 |
+---------------+--------------------------+--------------------------------------------------------------------+

+-------------------------------------------------------------------------------------------+
|                                         TELEPORTER                                        |
+---------------+------------------------------+--------------------------------------------+
| Local Network | Teleporter Messenger Address | 0x253b2784c75e510dD0fF1da844684a1aC0aa5fcf |
|               +------------------------------+--------------------------------------------+
|               | Teleporter Registry Address  | 0x3C4ac42e719716C49A0c03713A31738aeB1C7eF2 |
+---------------+------------------------------+--------------------------------------------+

+---------------------------+
|           TOKEN           |
+--------------+------------+
| Token Name   | USDC Token |
+--------------+------------+
| Token Symbol | USDC       |
+--------------+------------+

+--------------------------------------------------------------------------------------------------------------------------------------+
|                                                       INITIAL TOKEN ALLOCATION                                                       |
+--------------------------+------------------------------------------------------------------+----------------+-----------------------+
| DESCRIPTION              | ADDRESS AND PRIVATE KEY                                          | AMOUNT (10^18) | AMOUNT (WEI)          |
+--------------------------+------------------------------------------------------------------+----------------+-----------------------+
| cli-teleporter-deployer  | 0x614D16825E7A35e857Fc34196c5A72F29172dC46                       | 600            | 600000000000000000000 |
| Teleporter Deploys       | 60b6522b8267b509ba3f5e417147ff574b9f19d3d514cf3a4b0af74167b4e851 |                |                       |
+--------------------------+------------------------------------------------------------------+----------------+-----------------------+
| Main funded account EWOQ | 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC                       | 10             | 10000000000000000000  |
|                          | 56289e99c94b6912bfc12adc093c9b51124f0dc54ac7a766b2bc5ccf558d8027 |                |                       |
+--------------------------+------------------------------------------------------------------+----------------+-----------------------+

+------------------------------------------------------------------------------------------------------------+
|                                         INITIAL PRECOMPILE CONFIGS                                         |
+-----------------------+--------------------------------------------+-------------------+-------------------+
| PRECOMPILE            | ADMIN ADDRESSES                            | MANAGER ADDRESSES | ENABLED ADDRESSES |
+-----------------------+--------------------------------------------+-------------------+-------------------+
| Warp                  | n/a                                        | n/a               | n/a               |
+-----------------------+--------------------------------------------+-------------------+-------------------+
| Native Minter         | 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC |                   |                   |
+-----------------------+--------------------------------------------+-------------------+-------------------+
| Fee Config Allow List | 0x8db97C7cEcE249c2b98bDC0226Cc4C2A57BF52FC |                   |                   |
+-----------------------+--------------------------------------------+-------------------+-------------------+
The allowlist is taken from the genesis and is not being updated if you make adjustments
via the precompile. Use readAllowList(address) instead.

+------------------------------------------------------------------------------------------------+
|                                        MYSUBNET RPC URLS                                       |
+-----------+------------------------------------------------------------------------------------+
| Localhost | http://127.0.0.1:9650/ext/bc/mysubnet/rpc                                          |
|           +------------------------------------------------------------------------------------+
|           | http://127.0.0.1:9650/ext/bc/St7VkxkbFEVSucgr8YSpXZ28Be5Jvpgc663KD7NF2vMJ4fcoV/rpc |
+-----------+------------------------------------------------------------------------------------+

+--------------------------------------------------------------------------+
|                                   NODES                                  |
+-------+------------------------------------------+-----------------------+
| NAME  | NODE ID                                  | LOCALHOST ENDPOINT    |
+-------+------------------------------------------+-----------------------+
| node1 | NodeID-7Xhw2mDxuDS44j42TCB6U5579esbSt3Lg | http://127.0.0.1:9650 |
+-------+------------------------------------------+-----------------------+
| node2 | NodeID-MFrZFVCXPv5iCn6M9K6XduxGTYp891xXZ | http://127.0.0.1:9652 |
+-------+------------------------------------------+-----------------------+
| node3 | NodeID-NFBbbJ4qCmNaCzeW7sxErhvWqvEQMnYcN | http://127.0.0.1:9654 |
+-------+------------------------------------------+-----------------------+
| node4 | NodeID-GWPcbFJZFfZreETSoWjPimr846mXEKCtu | http://127.0.0.1:9656 |
+-------+------------------------------------------+-----------------------+
| node5 | NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5 | http://127.0.0.1:9658 |
+-------+------------------------------------------+-----------------------+

+-------------------------------------------------------------+
|                      WALLET CONNECTION                      |
+-----------------+-------------------------------------------+
| Network RPC URL | http://127.0.0.1:9650/ext/bc/mysubnet/rpc |
+-----------------+-------------------------------------------+
| Network Name    | mysubnet                                  |
+-----------------+-------------------------------------------+
| Chain ID        | 12345                                     |
+-----------------+-------------------------------------------+
| Token Symbol    | USDC                                      |
+-----------------+-------------------------------------------+
| Token Name      | USDC Token                                |
+-----------------+-------------------------------------------+
```

From this output, take note of the following parameters:

- Funded Address (with 10 tokens),
- Teleporter Registry on C-Chain, and
- Teleporter Registry on Subnet

Set these parameters as environment variables so that we can manage them easily and also use them in the commands later.

```bash
export FUNDED_ADDRESS=<Funded Address (with 10 tokens)>
export TELEPORTER_REGISTRY_C_CHAIN=<Teleporter Registry on C-Chain>
export TELEPORTER_REGISTRY_SUBNET=<Teleporter Registry on Subnet>
```

## Deploy ERC20 (USDC Example) Contract on C-Chain

First step is to deploy the ERC20 contract. We are using the OpenZeppelin example contract here, and the contract is renamed to `ERC20.sol` for convenience. On Mainnet or Fuji tesnet you would use the Circle USDC contract address. For the purposes of this tutorial, we will deploy an example ERC20 contract that resembles the important specifications (6 decimals) of the USDC ERC20 contract.

```bash
forge create --rpc-url local-c --private-key $PK src/11-usdc-to-native-interchain-token-transfer/ERC20.sol:USDC
```

Now, make sure to add the contract address in the environment variables.

```bash
export ERC20_HOME_C_CHAIN=<"Deployed to" address>
```

If you deployed the above example contract, you should see a balance of 1,000,000 USDC tokens when you run the below command:

```bash
cast call --rpc-url local-c --private-key $PK $ERC20_HOME_C_CHAIN "balanceOf(address)(uint)" $FUNDED_ADDRESS
```

## Deploy Avalanche Interchain Token Transfer Contracts

We will deploy two Avalanche Interchain Token Transfer contracts. One on the source chain (which is C-Chain in our case) and another on the destination chain (mysubnet in our case).

### ERC20Home Contract

```bash
forge create --rpc-url local-c --private-key $PK lib/avalanche-interchain-token-transfer/contracts/src/TokenHome/ERC20TokenHome.sol:ERC20TokenHome --constructor-args $TELEPORTER_REGISTRY_C_CHAIN $FUNDED_ADDRESS $ERC20_HOME_C_CHAIN 6
```

Export the "Deployed to" address as an environment variable.

```bash
export ERC20_HOME_TRANSFERER_C_CHAIN=<"Deployed to" address>
```

### NativeTokenRemote Contract

In order to deploy this contract, we'll need the source chain BlockchainID (in hex). For Local network, you can easily find the BlockchainID using the `avalanche primary describe` command. Make sure you add it in the environment variables.

It's also recommended that you set the BlockchainID for mysubnet in order to avoid any issues later. It can be found using the `avalanche subnet describe <subnet-name>` command.

```bash
export C_CHAIN_BLOCKCHAIN_ID_HEX=yourcchainblockchainid
export SUBNET_BLOCKCHAIN_ID_HEX=yoursubnetblockchainid
```

Now, deploy the remote contract on mysubnet.

We're going to deploy the NativeTokenRemote contract with an initial reserve imbalance of 9 USDC. This will be the amount of tokens that we will be able to send cross-chain without having to collateralize first. We will keep 1 USDC for gas fees. Note that the amount is specified in Wei and is for 18 decimals as that is the number of decimals of USDC on our subnet.

```bash
forge create --rpc-url mysubnet --private-key $PK lib/avalanche-interchain-token-transfer/contracts/src/TokenRemote/NativeTokenRemote.sol:NativeTokenRemote --constructor-args \
"($TELEPORTER_REGISTRY_SUBNET,$FUNDED_ADDRESS,$C_CHAIN_BLOCKCHAIN_ID_HEX,$ERC20_HOME_TRANSFERER_C_CHAIN,6)" "USDC" 9000000000000000000 0
```

Export the "Deployed to" address as an environment variable.

```bash
export NATIVE_TOKEN_REMOTE_SUBNET=<"Deployed to" address>
```

### Granting Native Minting Rights to NativeTokenRemote Contract

In order to mint native tokens on Subnet when received from the C-Chain, the NativeTokenRemote contract must have minting rights. We pre-initialized the Native Minter Precompile with an admin address owned by us. We can use our rights to add this contract address as one of the enabled addresses in the precompile.

_Note: Native Minter Precompile Address = 0x0200000000000000000000000000000000000001_

Sending below transaction will add our remote token contract as one of the enabled addresses.

```bash
cast send --rpc-url mysubnet --private-key $PK 0x0200000000000000000000000000000000000001 "setEnabled(address)" $NATIVE_TOKEN_REMOTE_SUBNET
```

## Register Remote Token with Home Transferer

After deploying the Transferer contracts, you'll need to register the Remote token by sending a dummy message using the `registerWithHome` method. This message includes details which inform the home Transferer about your destination blockchain and settings, eg. `initialReserveImbalance`.

```bash
cast send --rpc-url mysubnet --private-key $PK $NATIVE_TOKEN_REMOTE_SUBNET "registerWithHome((address, uint256))" "(0x0000000000000000000000000000000000000000, 0)"
```

You can confirm that the remote token is registered by running the below command:

```bash
cast call --rpc-url mysubnet $NATIVE_TOKEN_REMOTE_SUBNET "isRegistered()(bool)"
```

You can now check the teleporter relay logs to see if the message was relayed successfully.

```bash
avalanche teleporter relayer logs
```

## Add Collateral and Start Sending Tokens

If you followed the instructions correctly, you should have noticed that we minted a supply of 10 USDC tokens on our Subnet. This increases the total supply of USDC token and its wrapped counterparts. We first need to collateralize the Home Transferer by sending an amount equivalent to `initialReserveImbalance` to the destination subnet from the C-Chain. Note: that this amount will not be minted on the subnet, so we recommend sending exactly an amount equal to `initialReserveImbalance`.

So the course of action in this section would be:

- Approve 9 USDC tokens for the Home Transferer contract to use them
- Call the `addCollateral` method on Home Transferer contract and send 9 USDC tokens to the remote contract
- Send 1 USDC tokens from c-chain to your address on the Subnet and check your new balance

### Approve tokens for the Home Transferer contract

You can increase/decrease the numbers here as per your requirements. (All values are mentioned in wei)

```bash
cast send --rpc-url local-c --private-key $PK $ERC20_HOME_C_CHAIN "approve(address, uint256)" $ERC20_HOME_TRANSFERER_C_CHAIN 9000000
```

### Add Collateral

Since we had an `initialReserveImbalance` of 9 USDC tokens on mysubnet, we'll send 9 tokens from our side via the transferer contract. (All values are in wei)

```bash
cast send --rpc-url local-c --private-key $PK $ERC20_HOME_TRANSFERER_C_CHAIN "addCollateral(bytes32, address, uint256)" $SUBNET_BLOCKCHAIN_ID_HEX $NATIVE_TOKEN_REMOTE_SUBNET 9000000
```

You can also confirm whether the Transferer is collateralized now by running the below command:

```bash
cast call --rpc-url mysubnet $NATIVE_TOKEN_REMOTE_SUBNET "isCollateralized()(bool)"
```

### Send Tokens Cross Chain

Now, send 1 USDC token to your funded address on the destination chain. (All values are in wei)

```bash
cast send --rpc-url local-c --private-key $PK $ERC20_HOME_TRANSFERER_C_CHAIN "send((bytes32, address, address, address, uint256, uint256, uint256, address), uint256)" "(${SUBNET_BLOCKCHAIN_ID_HEX}, ${NATIVE_TOKEN_REMOTE_SUBNET}, ${FUNDED_ADDRESS}, ${ERC20_HOME_C_CHAIN}, 0, 0, 250000, 0x0000000000000000000000000000000000000000)" 1000000
```

TIP: When sending tokens cross-chain, amount in wei on c-chain is 6 decimals, the emount in wei on the subnet is 18 decimals.

## Check Balances

```bash
cast balance --rpc-url mysubnet $FUNDED_ADDRESS
```

You can check your USDC balance on the C-Chain by running the below command:

```bash
cast call --rpc-url local-c $ERC20_HOME_C_CHAIN "balanceOf(address)(uint256)" $FUNDED_ADDRESS
```
