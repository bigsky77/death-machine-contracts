//////////////////////////////////////////////////////////////
//                          EVENTS
//////////////////////////////////////////////////////////////

%lang starknet

from starkware.cairo.common.dict_access import DictAccess
from src.game.ships import InputShipState, ShipState
from src.block.gameboard import SingleBlock 

@event
func simulationSubmit(
  instructions_len: felt, 
  instructions: felt*, 
  spaceships_len: felt, 
  spaceships: InputShipState*, 
  player_address: felt){

  }

@event
func gameComplete(ships_len: felt, ships: ShipState*, score: felt, player_address: felt){

  }

@event
func boardSet(board_len: felt, board: SingleBlock*){

  }

@event
func boardSummary(board_len: felt, board: SingleBlock*){

  }


