debug_flags := "-use-separate-modules -debug -dynamic-map-calls"
out := "-out:build/puzzle_solver.bin"
run:
    ../Odin/odin run . {{debug_flags}} {{out}} -show-timings
build:
    ../Odin/odin build . {{debug_flags}} {{out}} -show-timings
