const N_TURNS = 49;
const PC = 7;
const BOARD_SIZE = 225;
const BOARD_DIMENSION = 15;
const BLOCK_TIME = 3600; // 0 for testing 
const TARGET_SCORE = 20; // 0 for testing 

namespace ns_instructions {
    const W = 0;  // up
    const A = 1;  // left
    const S = 2;  // down
    const D = 3;  // right
    const SKIP = 50;  // skip
}

namespace ns_ships {
    const INPUT_SHIP_SIZE = 6;
    const SHIP_SIZE = 6;
}

namespace ns_board {
    const GRID_SIZE = 7;
    const MAX_MOVE = 2;
}

namespace ns_dict {
    const MULTIPLIER = 10 ** 7;
    const SHIP_MULTIPLIER = 10 ** 6;
}
