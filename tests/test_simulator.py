from re import M
import pytest
from starkware.starknet.testing.starknet import Starknet
import asyncio
import json
import dataclasses
import hashlib
import typing
import logging
from utils import import_json

LOGGER = logging.getLogger(__name__)


@pytest.fixture(scope="module")
def event_loop():
    return asyncio.new_event_loop()


@pytest.fixture(scope="module")
async def starknet():
    starknet = await Starknet.empty()
    return starknet

@pytest.mark.asyncio
async def test(starknet):
    
    #    with open('./build/death_machine_abi.json', 'r') as f:
    #    contract_abi = json.load(f)
 
    contract = await starknet.deploy(source="./src/simulation.cairo", constructor_calldata=[1])
    LOGGER.info(f"> Deployed simulation.cairo.")
    print(f"> Deployed simulation.cairo.")
    
    await contract.submit_simulation(
        [7, 7, 7],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [(0, 0, 1, (3, 3), 0), (1, 0, 1, (3, 4), 0), (2, 0, 1, (5, 5), 0)],
    ).call()
    
