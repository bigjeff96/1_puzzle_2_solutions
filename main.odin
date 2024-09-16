package puzzle_solver

import "core:fmt"

Connection_type :: distinct int

Border : Connection_type : 0

Puzzle_piece :: struct {
    sides: [4]Connection_type
}

main :: proc() {
    fmt.println("hihi")
}
