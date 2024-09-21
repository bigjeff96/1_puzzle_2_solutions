debug_flags := "-use-separate-modules -debug -dynamic-map-calls"
out := "-out:build/puzzle_solver.bin"
config := "-define:SIDE=2"

run:
    ../Odin/odin run src/ {{debug_flags}} {{out}} {{config}} -show-timings
build:
    ../Odin/odin build src/ {{debug_flags}} {{out}} {{config}} -show-timings
test:
	../Odin/odin test src/
