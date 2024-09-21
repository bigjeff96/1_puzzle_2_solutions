package puzzle_solver

import "core:fmt"
import "core:math/rand"
import "core:math"
import "core:math/bits"
import ba "core:container/bit_array"
import "core:mem"
import "core:log"

Connection_type :: distinct int

BORDER : Connection_type : -1
NONE : Connection_type : 0

Puzzle_piece :: [Puzzle_side]Connection_type

Puzzle_side :: enum {
    left,
    top,
    right,
    down,
}

Normals_from_side :: [Puzzle_side][2]int

normals : Normals_from_side = { .left = {-1, 0},
				.top = {0, 1},
				.right = {1, 0},
				.down = {0, -1},
			      }
opposite_side : [Puzzle_side]Puzzle_side = { .left = .right,
					     .top = .down,
					     .right = .left,
					     .down = .top,
					   }

puzzle_id_to_coord :: proc(piece_id: int, dimensions: [2]int) -> [2]int {
    coord : [2]int
    coord.y, coord.x = math.floor_divmod(piece_id, dimensions.y)
    return coord
}

coord_to_puzzle_id :: proc(coord: [2]int, dimensions: [2]int) -> (id: int) {
    id = coord.x + dimensions.x * coord.y
    return id
}

TOTAL_PIECES_PER_SIDE :: #config(SIDE, 5)

make_puzzle :: proc(dimensions: [2]int) -> (puzzle: []Puzzle_piece) {
    log.log(.Info, "Puzzle with dimensions", dimensions)
    puzzle = make([]Puzzle_piece, dimensions.x * dimensions.y)

    total_connection_types := (dimensions.x - 1) * dimensions.y + (dimensions.y - 1) * dimensions.x
    log.log(.Info, "total connections:", total_connection_types)

    // Borders
    for &piece, id in puzzle {
	coord := puzzle_id_to_coord(id, dimensions)
	
	if coord.x == 0 do piece[.left] = BORDER
	if coord.x == dimensions.x - 1 do piece[.right] = BORDER
	if coord.y == 0 do piece[.down] = BORDER
	if coord.y == dimensions.y - 1 do piece[.top] = BORDER
    }

    //Actual connections
    for &piece, id in puzzle {
	coord := puzzle_id_to_coord(id, dimensions)
	for side in Puzzle_side do if piece[side] == NONE {
	    normal := normals[side]
	    neighbor_piece_coord := coord + normal
	    neighbor_piece_id := coord_to_puzzle_id(neighbor_piece_coord, dimensions)
	    neighbor_piece := &puzzle[neighbor_piece_id]
	    piece[side] = Connection_type(total_connection_types)
	    neighbor_piece[opposite_side[side]] = Connection_type(total_connection_types)
		
	    assert(total_connection_types > 0)
	    total_connection_types -= 1
	}
    }
    return
}

main :: proc() {
    context.logger = log.create_console_logger(.Info)
    rand.reset(0)
    dimensions := [2]int{TOTAL_PIECES_PER_SIDE, TOTAL_PIECES_PER_SIDE}

    puzzle := make_puzzle(dimensions)
    log.log(.Info, "Final Puzzle:\n", puzzle)

    rand.shuffle(puzzle)
    log.log(.Info, "Puzzle after shuffle:\n", puzzle)

}
