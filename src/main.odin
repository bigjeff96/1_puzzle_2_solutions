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

NULL_PIECE: Puzzle_piece : {.left = NONE, .right = NONE, .top = NONE, .down = NONE}

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

SIDE_LENGTH :: #config(SIDE, 5)

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
    shuffled_puzzle: Puzzle
    shuffled_puzzle.pieces = make([]Puzzle_piece, dimensions.x * dimensions.y)
    copy(shuffled_puzzle.pieces, puzzle.pieces)
    shuffled_puzzle.dimensions = puzzle.dimensions
    rand.shuffle(shuffled_puzzle.pieces)
    info("Puzzle after shuffle:\n", puzzle)

    solved_puzzle := solve_puzzle(shuffled_puzzle)
    info("solution:\n", solved_puzzle)
    for i in 0 ..< dimensions.x * dimensions.y {
        assert(puzzle.pieces[i] == solved_puzzle.pieces[i])
    }
}

solve_puzzle :: proc(puzzle: Puzzle) -> (solution: Puzzle) {

    recursive_solve :: proc(
        solution_pieces: []Puzzle_piece,
        coord_last_added_piece: [2]int,
        rest_pieces_ids: ^[dynamic]int,
        puzzle: Puzzle,
    ) {
        total_pieces_left := len(rest_pieces_ids)
        if (total_pieces_left == 1) {
            id_last_solved_piece := coord_to_puzzle_id(coord_last_added_piece, puzzle.dimensions)
            last_added_piece := solution_pieces[id_last_solved_piece]
            last_piece_to_add := puzzle.pieces[rest_pieces_ids[0]]

            for &piece in solution_pieces {
                if piece == NULL_PIECE {
                    piece = last_piece_to_add
                    break
                }
            }
            return
        }
        id_last_solved_piece := coord_to_puzzle_id(coord_last_added_piece, puzzle.dimensions)
        last_added_piece := solution_pieces[id_last_solved_piece]

        new_piece_id: int
        id_to_remove: int
        side_that_connects: Puzzle_side

        for piece_id, id in rest_pieces_ids {
            piece := puzzle.pieces[piece_id]
            for side in Puzzle_side do if last_added_piece[side] != BORDER {
                if last_added_piece[side] == piece[opposite_side[side]] {
                    side_that_connects = side
                    new_piece_id = piece_id
                    id_to_remove = id
                    break
                }
            }
            if new_piece_id != 0 do break
        }

        coord_of_new_piece := coord_last_added_piece + normals[side_that_connects]
        id := coord_to_puzzle_id(coord_of_new_piece, puzzle.dimensions)
        solution_pieces[id] = puzzle.pieces[new_piece_id]

        unordered_remove(rest_pieces_ids, id_to_remove)

        recursive_solve(solution_pieces, coord_of_new_piece, rest_pieces_ids, puzzle)
    }
    solution.dimensions = puzzle.dimensions
    solution_pieces := make([]Puzzle_piece, puzzle.dimensions.x * puzzle.dimensions.y)
    rest_pieces_ids := make([dynamic]int, puzzle.dimensions.x * puzzle.dimensions.y)

    for &piece_id, id in rest_pieces_ids do piece_id = id

    // get bottom left corner piece, which has BORDER at left and top
    id_bottom_left := 0
    for piece, id in puzzle.pieces {
        if piece[.left] == BORDER && piece[.down] == BORDER {
            id_bottom_left = id
            break
        }
    }

    solution_pieces[0] = puzzle.pieces[id_bottom_left]
    unordered_remove(&rest_pieces_ids, id_bottom_left)

    recursive_solve(solution_pieces, {0, 0}, &rest_pieces_ids, puzzle)

    solution.pieces = solution_pieces
    return
}
