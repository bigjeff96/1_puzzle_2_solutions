package puzzle_solver

import "core:testing"
import "core:fmt"

@(test)
id_to_coord :: proc(t: ^testing.T) {
    dimensions := [2]int{2,2}
    for id in 0..<4 {
	coord := puzzle_id_to_coord(id, dimensions)
	possible_id, _ := coord_to_puzzle_id(coord, dimensions)
	testing.expectf(t, id == possible_id, "{}, {}", id , possible_id)
    }
}
