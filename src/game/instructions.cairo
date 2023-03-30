%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.dict import dict_read

from src.game.ships import ShipState

struct InstructionSet {
    instructions_len: felt,
    instructions: felt*,
}

func get_frame_instruction_set{range_check_ptr}(
    cycle: felt,
    i: felt,
    ships_dict: DictAccess*,
    instructions_sets_len: felt,
    instructions_sets: felt*,
    instructions: felt*,
    frame_instructions_len: felt,
    frame_instructions: felt*,
    offset: felt,
) -> (ships_new: DictAccess*) {
    if (instructions_sets_len == 0) {
        return (ships_new=ships_dict);
    }

    tempvar l = [instructions_sets];
    let (ptr) = dict_read{dict_ptr=ships_dict}(key=i);
    tempvar ship = cast(ptr, ShipState*);
    let (_, r) = unsigned_div_rem(cycle + ship.pc, l);

    assert [frame_instructions + frame_instructions_len] = [instructions + r + offset];

    return get_frame_instruction_set(
        cycle,
        i + 1,
        ships_dict,
        instructions_sets_len - 1,
        instructions_sets + 1,
        instructions,
        frame_instructions_len + 1,
        frame_instructions,
        offset + l,
    );
}
