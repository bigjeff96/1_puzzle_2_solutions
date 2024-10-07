package puzzle_solver

import ba "core:container/bit_array"
import "core:fmt"
import "core:log"
import "core:math"
import "core:math/bits"
import "core:math/rand"
import "core:mem"

Connection_type :: distinct int

BORDER: Connection_type : -1
NONE: Connection_type : 0

Puzzle :: struct {
    pieces:     []Puzzle_piece,
    dimensions: [2]int,
}

Puzzle_piece :: [Puzzle_side]Connection_type

Puzzle_side :: enum {
    left,
    top,
    right,
    down,
}

Normals_from_side :: [Puzzle_side][2]int

normals: Normals_from_side = {
    .left  = {-1, 0},
    .top   = {0, 1},
    .right = {1, 0},
    .down  = {0, -1},
}
opposite_side: [Puzzle_side]Puzzle_side = {
    .left  = .right,
    .top   = .down,
    .right = .left,
    .down  = .top,
}

puzzle_id_to_coord :: proc(piece_id: int, dimensions: [2]int) -> [2]int {
    coord: [2]int
    coord.y, coord.x = math.floor_divmod(piece_id, dimensions.y)
    return coord
}

coord_to_puzzle_id :: proc(coord: [2]int, dimensions: [2]int) -> (id: int) {
    id = coord.x + dimensions.x * coord.y
    return id
}

SIDE_LENGTH :: #config(SIDE, 3)

get_neighbor_piece :: proc(
    using puzzle: Puzzle,
    coord: [2]int,
    side: Puzzle_side,
) -> (
    ^Puzzle_piece,
    [2]int,
) {
    normal := normals[side]
    neighbor_piece_coord := coord + normal
    neighbor_piece_id := coord_to_puzzle_id(neighbor_piece_coord, dimensions)
    neighbor_piece := &pieces[neighbor_piece_id]
    return neighbor_piece, neighbor_piece_coord
}

make_puzzle :: proc(dimensions: [2]int) -> (puzzle: Puzzle) {
    puzzle.pieces = make([]Puzzle_piece, dimensions.x * dimensions.y)
    puzzle.dimensions = dimensions

    total_connection_types := (dimensions.x - 1) * dimensions.y + (dimensions.y - 1) * dimensions.x

    // Borders
    for &piece, id in puzzle.pieces {
        coord := puzzle_id_to_coord(id, dimensions)

        if coord.x == 0 do piece[.left] = BORDER
        if coord.x == dimensions.x - 1 do piece[.right] = BORDER
        if coord.y == 0 do piece[.down] = BORDER
        if coord.y == dimensions.y - 1 do piece[.top] = BORDER
    }

    //Actual connections
    for &piece, id in puzzle.pieces {
        coord := puzzle_id_to_coord(id, dimensions)
        for side in Puzzle_side do if piece[side] == NONE {
            neighbor_piece, _ := get_neighbor_piece(puzzle, coord, side)
            piece[side] = Connection_type(total_connection_types)
            neighbor_piece[opposite_side[side]] = Connection_type(total_connection_types)

            assert(total_connection_types > 0)
            total_connection_types -= 1
        }
    }
    return
}

info :: log.info
infof :: log.infof

main :: proc() {
    context.logger = log.create_console_logger(.Info, {.Level, .Line, .Procedure})
    rand.reset(0)
    dimensions := [2]int{SIDE_LENGTH, SIDE_LENGTH}

    puzzle: Puzzle = make_puzzle(dimensions)
    info("Final Puzzle:\n", puzzle)

    rand.shuffle(puzzle.pieces)
    info("Puzzle after shuffle:\n", puzzle)

    solved_puzzle := solve_puzzle(puzzle)
    // for i in 0 ..< dimensions.x * dimensions.y {
    //     assert(puzzle.pieces[i] == solved_puzzle.pieces[i])
    // }
}

solve_puzzle :: proc(puzzle: Puzzle) -> (solution: Puzzle) {
    solution.dimensions = puzzle.dimensions
    solution_pieces: [dynamic]Puzzle_piece

    // get bottom left corner piece, which has BORDER at left and top
    id_bottom_left := 0
    for piece, id in puzzle.pieces {
        if piece[.left] == BORDER && piece[.down] == BORDER {
            id_bottom_left = id
            break
        }
    }
    append(&solution_pieces, puzzle.pieces[id_bottom_left])
    infof("bottom left piece is {}", id_bottom_left)
    bottom_left := solution_pieces[0]
    for piece, id in puzzle.pieces do if id != id_bottom_left {
        for side in Puzzle_side {
            if (bottom_left[side] == piece[opposite_side[side]] && bottom_left[side] != BORDER) {
                infof("\nbottom left: {}\npiece: {}", bottom_left, piece)
            }
        }
    }

    solution.pieces = solution_pieces[:]
    return
}

test_proc :: proc() {
    fmt.println("hihi")
}
