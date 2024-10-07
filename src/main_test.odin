package puzzle_solver

import "core:fmt"
import "core:testing"

@(test)
id_to_coord :: proc(t: ^testing.T) {
    dimensions := [2]int{2, 2}
    for id in 0 ..< 4 {
        coord := puzzle_id_to_coord(id, dimensions)
        possible_id := coord_to_puzzle_id(coord, dimensions)
        testing.expectf(t, id == possible_id, "{}, {}", id, possible_id)
    }
}

validate_puzzle_connections :: proc(t: ^testing.T, using puzzle: Puzzle) {
    for piece, id in pieces {
        coord := puzzle_id_to_coord(id, dimensions)
        for side in Puzzle_side {
            if piece[side] != BORDER {
                neighbor_piece, _ := get_neighbor_piece(puzzle, coord, side)
                testing.expect(
                    t,
                    piece[side] == neighbor_piece[opposite_side[side]],
                    "Pieces do not connect",
                )
            }
        }
    }
}

@(test)
valid_puzzle_2_dim :: proc(t: ^testing.T) {
    Dimensions :: 2
    dimensions := [2]int{Dimensions, Dimensions}

    puzzle := make_puzzle(dimensions)
    defer delete(puzzle.pieces)

    validate_puzzle_connections(t, puzzle)
}

@(test)
valid_puzzle_3_dim :: proc(t: ^testing.T) {
    Dimensions :: 3
    dimensions := [2]int{Dimensions, Dimensions}

    puzzle := make_puzzle(dimensions)
    defer delete(puzzle.pieces)

    validate_puzzle_connections(t, puzzle)
}

@(test)
valid_puzzle_4_dim :: proc(t: ^testing.T) {
    Dimensions :: 4
    dimensions := [2]int{Dimensions, Dimensions}

    puzzle := make_puzzle(dimensions)
    defer delete(puzzle.pieces)

    validate_puzzle_connections(t, puzzle)
}

@(test)
valid_puzzle_5_dim :: proc(t: ^testing.T) {
    Dimensions :: 5
    dimensions := [2]int{Dimensions, Dimensions}

    puzzle := make_puzzle(dimensions)
    defer delete(puzzle.pieces)

    validate_puzzle_connections(t, puzzle)
}
