%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

from src.death_machine import simulation 
from src.game.spaceships import ShipState, InputShipState 
from src.game.types import Grid 

const instructions_len = 21; 
const ships_len = 3; 

@contract_interface
namespace IDeathMachine {
  func simulation(
  instructions_sets_len: felt,
  instructions_sets: felt*,
  instructions_len: felt, 
  instructions: felt*, 
  ships_len: felt, 
  ships: InputShipState*) {
    }  
}

@external
func __setup__{syscall_ptr : felt*}(){
  alloc_locals;
 
  tempvar death_machine;
  tempvar xoroshiro;
  %{
    ids.xoroshiro = deploy_contract(
    "./src/utils/xoroshiro128_starstar.cairo", [1]).contract_address
    context.xoroshiro = ids.xoroshiro
    
    ids.death_machine = deploy_contract(
    "./src/death_machine.cairo", [ids.xoroshiro]).contract_address
    context.death_machine = ids.death_machine
  %}

  return(); 
}

@external
func test_simulation{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
  alloc_locals;

  let (death_machine) = death_machine_instance.deployed();
  
  let (ships: InputShipState*) = alloc();
  let (instructions: felt*) = alloc();
  let (instructions_sets: felt*) = alloc();
  
  assert instructions[0] = 1;
  assert instructions[1] = 1;
  assert instructions[2] = 1;
  assert instructions[3] = 1;
  assert instructions[4] = 1;
  assert instructions[5] = 1;
  assert instructions[6] = 1;
  assert instructions[7] = 1;
  assert instructions[8] = 1;
  assert instructions[9] = 1;
  assert instructions[10] = 1;
  assert instructions[11] = 1;
  assert instructions[12] = 1;
  assert instructions[13] = 1;
  assert instructions[14] = 1;
  assert instructions[15] = 1;
  assert instructions[16] = 1;
  assert instructions[17] = 1;
  assert instructions[18] = 1;
  assert instructions[19] = 1;
  assert instructions[20] = 1;
  assert instructions[21] = 1;
  
  assert instructions_sets[0] = 7;
  assert instructions_sets[1] = 7;
  assert instructions_sets[2] = 7;

  assert ships[0] = InputShipState(id=0,type=1, status=1, Grid(x=3, y=3), description=0);
  assert ships[1] = InputShipState(id=1,type=1, status=1, Grid(x=4, y=4), description=0);
  assert ships[2] = InputShipState(id=2,type=1, status=1, Grid(x=5, y=5), description=0);
  
  IDeathMachine.simulation(death_machine, 3, instructions_sets, instructions_len, instructions, ships_len, ships);
  return();
}

// ======= contract-instances ======= 

namespace death_machine_instance {
    func deployed() -> (death_machine_instance : felt){
        tempvar death_machine;
        %{
            ids.death_machine = context.death_machine
        %}
        return(death_machine_instance=death_machine);
    }
}
