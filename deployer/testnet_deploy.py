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
from starkware.starknet.public.abi import get_selector_from_name
from starknet_py.net.client_models import Call
import os

local_network_client = GatewayClient("http://localhost:5050")

testnet_key = 0xf7c1bd874da5e709d4713d60c8a70639
address = 0x3cad9a072d3cf29729ab2fad2e08972b8cfde01d4979083fb6d15e8e66f8ab1

death_machine_compiled = './build/death_machine.json'
xoroshiro_compiled = './build/xoroshiro.json'

async def start():
    from random import randint

    key_pair = KeyPair.from_private_key(testnet_key)
    signer = StarkCurveSigner(address, key_pair, StarknetChainId.TESTNET)
    account = Account(client=local_network_client, address=address, signer=signer)
    
    with open(xoroshiro_compiled) as xr_contract_file:
        xr_compiled_contract = xr_contract_file.read()
        xr_declare_result = await Contract.declare(
        account=account, compiled_contract=xr_compiled_contract, max_fee=int(1e16)
    )

    await xr_declare_result.wait_for_acceptance()
    
    xr_deploy_call = await xr_declare_result.deploy(constructor_args={"seed": 1}, max_fee=int(1e16));
    
    await xr_deploy_call.wait_for_acceptance()
    xr_contract = xr_deploy_call.deployed_contract
    xr_contract_address = str(xr_contract.address)

    with open(death_machine_compiled) as dm_contract_file:
        dm_compiled_contract = dm_contract_file.read()
        dm_declare_result = await Contract.declare(
        account=account, compiled_contract=dm_compiled_contract, max_fee=int(1e16)
    )

    await dm_declare_result.wait_for_acceptance()

    dm_deploy_call = await dm_declare_result.deploy(constructor_args={"address": xr_contract.address}, max_fee=int(1e16));
    
    await dm_deploy_call.wait_for_acceptance()

    dm_contract = dm_deploy_call.deployed_contract
    dm_contract_address = str(dm_contract.address)
    
    #write address to file
    print("Contract Deployed", dm_contract.address)
    
    file1 = open('../frontend/abi/deploy_address.ts', 'w')
    print('export const contract_address=' + '"' + dm_contract_address + '"', file=file1);
    file1.close();
    
if __name__ == "__main__":
    asyncio.run(start())
