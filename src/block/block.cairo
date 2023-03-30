//////////////////////////////////////////////////////////////
//                        BLOCK
//////////////////////////////////////////////////////////////

%lang starknet

from starkware.starknet.common.syscalls import (
    get_block_number,
    get_block_timestamp,
    get_caller_address,
)
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.math_cmp import is_le, is_in_range 
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.dict import dict_write, dict_read

from src.game.events import boardSummary 
from src.block.gameboard import SingleBlock 
from src.block.gameboard import init_board
from src.utils.xoroshiro128_starstar import next, generate_seed, State
from src.game.constants import (
  BOARD_SIZE, 
  BOARD_DIMENSION,
  BLOCK_TIME,
  TARGET_SCORE
)

struct BlockData {
    number: felt,
    seed: State, 
    status: felt, // 0=complete, 1=active, 2=pending
    reward: felt,
    difficulty: felt,
    timestamp: felt,
    prover: felt,
    score: felt,
  }

@event
func blockComplete(completed_block: BlockData){

  }

@event
func blockInitialized(new_block: BlockData){

  }

@storage_var
func Block_Storage(block_number: felt) -> (block: BlockData){

  }

@storage_var
func Current_Block() -> (current_block: felt){

  }

namespace Block {
    func init{
      syscall_ptr: felt*, 
      bitwise_ptr: BitwiseBuiltin*, 
      pedersen_ptr: HashBuiltin*, 
      range_check_ptr}(block_number: felt, score: felt) -> (){
        alloc_locals;

        let (block_timestamp) = get_block_timestamp();
        let (block_seed) = generate_seed(block_timestamp);
        let status = 1;

        let block_reward = 65; // percentage of reward squares out of 100
        let block_difficulty = 5; // percentage of enemey squares out of 100

        tempvar new_block: BlockData = BlockData(
            block_number, 
            block_seed,
            status, 
            block_reward, 
            block_difficulty, 
            block_timestamp,
            0,
            0);
          
        Block_Storage.write(block_number, new_block);
        Current_Block.write(block_number);

        get_current_board();
        blockInitialized.emit(new_block);

    return();
    }
  
    @external
    func update_block{
      syscall_ptr: felt*, 
      pedersen_ptr: HashBuiltin*, 
      bitwise_ptr: BitwiseBuiltin*, 
      range_check_ptr}(score: felt, player_address: felt) -> (){
      alloc_locals;
      let (block_number) = Current_Block.read();
      let (block) = Block_Storage.read(block_number);
      
      let (time_now) = get_block_timestamp();
      let diff = time_now - block.timestamp; 
      
      // Returns 1 if a <= b (or more precisely 0 <= b - a < RANGE_CHECK_BOUND).
      let is_new_high_score = is_le(score, block.score);
      let full_time_elapsed = is_le(diff, BLOCK_TIME);

      if(is_new_high_score == 0 and full_time_elapsed == 0 ){
        tempvar updated_block = BlockData(
          block.number, 
          block.seed, 
          0, 
          block.reward, 
          block.difficulty, 
          block.timestamp, 
          player_address, 
          score);   

          Block_Storage.write(block_number, updated_block);
          init(block_number + 1, score);
          blockComplete.emit(updated_block);
        return();
      }

      if(is_new_high_score == 0 and full_time_elapsed == 1 ){
       tempvar updated_block = BlockData(
          block.number, 
          block.seed, 
          block.status, 
          block.reward, 
          block.difficulty, 
          block.timestamp, 
          player_address, 
          score);   

          Block_Storage.write(block_number, updated_block);
          return();
      }
      
      if(is_new_high_score == 1 and full_time_elapsed == 0 ){
       tempvar updated_block = BlockData(
          block.number, 
          block.seed, 
          0, 
          block.reward, 
          block.difficulty, 
          block.timestamp, 
          block.prover, 
          block.score);   

          Block_Storage.write(block_number, updated_block);
          init(block_number + 1, score);
          blockComplete.emit(updated_block);
          return();
      }
    return();
    }
    
  func get_current_board{
      syscall_ptr: felt*, 
      pedersen_ptr: HashBuiltin*, 
      bitwise_ptr: BitwiseBuiltin*, 
      range_check_ptr}(){ 
    alloc_locals;
    let (block_arr: SingleBlock*) = alloc();
    let (current_block) = Current_Block.read(); 
    let (block) = Block_Storage.read(current_block);

    let (board_dict: DictAccess*) = default_dict_new(default_value=0);
    let (dict_new) = init_board(BOARD_DIMENSION, BOARD_SIZE, block.seed, board_dict);       
    
    let (block_len, block_state) = board_summary(225, block_arr, dict_new);
    boardSummary.emit(block_len, block_state);
    return();
    }
 }

func board_summary{syscall_ptr: felt*, range_check_ptr}(board_size: felt, 
      board_arr: SingleBlock*, 
      board_dict: DictAccess*) -> (board_size: felt, board: SingleBlock*){
      alloc_locals;
    
      if(board_size == 0){
          default_dict_finalize(dict_accesses_start=board_dict, dict_accesses_end=board_dict, default_value=0);
          return(board_size, board_arr);
        }
      
      let (ptr) = dict_read{dict_ptr=board_dict}(key=board_size);
      tempvar board = cast(ptr, SingleBlock*);
      assert board_arr[board_size - 1] = SingleBlock(board.id, board.type, board.status, board.index, board.raw_index);

      board_summary(board_size - 1, board_arr, board_dict);
    return(board_size, board_arr);
    }


