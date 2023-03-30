//////////////////////////////////////////////////////////////
//                      UTILS
//////////////////////////////////////////////////////////////

%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.math import assert_le, assert_nn_le, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le, is_nn
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin, HashBuiltin
from starkware.cairo.common.cairo_keccak.keccak import keccak_felts, finalize_keccak

@view
func index_to_cords{range_check_ptr}(index: felt) -> (loc_x: felt, loc_y: felt){
  alloc_locals;

  tempvar zero_based_index = index;
  let (loc_x, _) = unsigned_div_rem(zero_based_index, 15); 
  let (_, loc_y) = unsigned_div_rem(zero_based_index, 15); 

  return(loc_x, loc_y);
  }

@view
func cords_to_index{range_check_ptr}(loc_x: felt, loc_y: felt) -> (index: felt){
  alloc_locals;

  tempvar zero_based_x = loc_x;
  tempvar zero_based_y = loc_y;
  let index = zero_based_x * 15 + zero_based_y;

  return(index=index);
  }


