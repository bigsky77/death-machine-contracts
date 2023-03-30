import asyncio
from starknet_py.contract import Contract
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.networks import MAINNET, TESTNET
from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.account.account import Account
from starknet_py.net.signer.stark_curve_signer import StarkCurveSigner
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.udc_deployer.deployer import Deployer
import os
from dotenv import load_dotenv

load_dotenv(.env.local)

# Local network
key = os.getenv('KEY')
local_network_client = GatewayClient("http://localhost:5050")
testnet_client = GatewayClient(TESTNET)

key_pair = KeyPair.from_private_key(key=key)
signer = StarkCurveSigner(0x037120cfd86ce59565ff1c2e26f3383e0871bf95fe3fe6e905204d1e1a2238b8, key_pair, StarknetChainId.TESTNET)
account = Account(client=testnet_client, address=0x037120cfd86ce59565ff1c2e26f3383e0871bf95fe3fe6e905204d1e1a2238b8, signer=signer)

async def start():
    from random import randint

    with open('./build/death_machine.json') as dm_contract_file:
        dm_compiled_contract = dm_contract_file.read()

    dm_declare_result = await Contract.declare(
        account=account, compiled_contract=dm_compiled_contract, max_fee=int(1e16)
    )
    # Wait for the transaction
    await dm_declare_result.wait_for_acceptance()

    dm_deploy_call = await dm_declare_result.deploy(constructor_args={"seed": 1}, max_fee=int(1e18));
    dm_contract = dm_deploy_call.deployed_contract

    dm_contract_address = str(dm_contract.address)

    print("Contract Deployed", dm_contract.address)
    #write address to file
    file1 = open('../frontend/abi/deploy_address.ts', 'w')
    print('export const contract_address=' + '"' + dm_contract_address + '"', file=file1);
    file1.close();

if __name__ == "__main__":
    asyncio.run(start())


