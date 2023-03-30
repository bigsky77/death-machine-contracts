//////////////////////////////////////////////////////////////
//                      GAME BOARD
//////////////////////////////////////////////////////////////

%lang starknet

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_block_timestamp, get_contract_address, get_caller_address
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le, is_in_range 
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.dict import dict_write, dict_read

from src.utils.xoroshiro128_starstar import next, State
from src.block.grid import Grid 
from src.game.constants import ns_board, ns_dict, BOARD_SIZE, BOARD_DIMENSION   
from src.utils.utils import index_to_cords, cords_to_index

//////////////////////////////////////////////////////////////
//                        BOARD
//////////////////////////////////////////////////////////////

struct SingleBlock {
    id: felt,
    type: felt,
    status: felt,
    index: Grid,
    raw_index: Grid,
}

func init_board{syscall_ptr: felt*, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    dimension: felt,
    board_size: felt, 
    block_seed: State,
    dict: DictAccess*, 
) -> (dict_new: DictAccess*) {
     
    if (board_size == 0) {
        return (dict_new=dict);
    }
    
    let (block_type) = generate_type(board_size, block_seed);
    let (x, y) = index_to_cords(board_size);
   
    tempvar new_block: SingleBlock* = new SingleBlock(board_size, block_type, 1, Grid(x=x,y=y), Grid(x=x,y=y));
    dict_write{dict_ptr=dict}(key=new_block.id, new_value=cast(new_block, felt));

    return init_board(dimension, board_size - 1, block_seed, dict);
}

func iterate_board{syscall_ptr: felt*, bitwise_ptr: BitwiseBuiltin*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
  board_dimension: felt, 
  board_size: felt, 
  block_seed: State,
  board_dict: DictAccess*) -> (board_new: DictAccess*){
    alloc_locals;
  
    if(board_size == 0){
        return(board_new=board_dict);
      }

    let (ptr) = dict_read{dict_ptr=board_dict}(key=board_size);
    tempvar grid = cast(ptr, SingleBlock*);
  
    if(grid.type != 1){
        return iterate_board(board_dimension, board_size - 1, block_seed, board_dict);
      }
    
    let (r) = next(board_size, block_seed);
    let (_, res) = unsigned_div_rem(r, 4);
    
    let can_move_right = is_le(grid.index.x, board_dimension - 2);
    if(res == 0 and can_move_right == 1){
        let (board_new) = update_enemy_moved(grid, board_dict, 1, 0);
        return iterate_board(
          board_dimension, 
          board_size - 1,
          block_seed,
          board_new,
        );
      }
    
    let can_move_left = is_le(1, grid.index.x);
    if(res == 1 and can_move_left == 1){
        let (board_new) = update_enemy_moved(grid, board_dict, -1, 0);
        return iterate_board(
          board_dimension, 
          board_size - 1,
          block_seed,
          board_new,
        );
      }
    
    let can_move_down = is_le(grid.index.y, board_dimension - 2);
    if(res == 2 and can_move_down == 1){
        let (board_new) = update_enemy_moved(grid, board_dict, 0, -1);
        return iterate_board(
          board_dimension, 
          board_size - 1,
          block_seed,
          board_new,
        );
      }

    let can_move_up = is_le(1, grid.index.y);
    if(res == 3 and can_move_up == 1){
        let (board_new) = update_enemy_moved(grid, board_dict, 0, 1);
        return iterate_board(
          board_dimension, 
          board_size - 1,
          block_seed,
          board_new,
        );
      }

    return (board_new=board_dict);
  }


//////////////////////////////////////////////////////////////
//                    TYPE AND MOVE GENERATOR 
//////////////////////////////////////////////////////////////

func generate_type{
    syscall_ptr: felt*, 
    bitwise_ptr: BitwiseBuiltin*, 
    pedersen_ptr: HashBuiltin*, 
    range_check_ptr}(board_size: felt, block_seed: State) -> (block_type: felt){
    
    let (r) = next(board_size, block_seed);
    let (_, res) = unsigned_div_rem(r, 100); 
    
    // randomly assing grid type in range
    let x = is_le(res, 30);
    if(x == 1){
      return(block_type=0);
      }

    let y = is_le(res, 85);
    if(y == 1){  
      return(block_type=2);
      }
    
    let z = is_le(res, 95);
    if(z == 1){  
      return(block_type=3);
      }
    
    let b = is_le(res, 100);
    if(b == 1){  
      return(block_type=1);
      }

    return(block_type=0);
  }

func update_enemy_moved{range_check_ptr}(
    enemy: SingleBlock*, board_dict: DictAccess*, x_inc: felt, y_inc: felt
) -> (board_new: DictAccess*) {
    tempvar enemy_new: SingleBlock* = new SingleBlock(enemy.id, enemy.type, enemy.status, Grid(enemy.index.x + x_inc, enemy.index.y + y_inc), enemy.raw_index);
    dict_write{dict_ptr=board_dict}(key=enemy.id, new_value=cast(enemy_new, felt));
    return (board_new=board_dict);
}
