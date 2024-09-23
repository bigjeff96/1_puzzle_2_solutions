debug_flags := "-use-separate-modules -debug -dynamic-map-calls"
exe := "build/puzzle_solver.bin"

build: fmt
    ../Odin/odin build src/ {{ debug_flags }} -out:{{ exe }} -show-timings

run: build
    ./{{ exe }}

test: fmt
    ../Odin/odin test src/ 

fmt:
    #!/bin/env bash
    set -ep
    for i in $(find . -name "*.odin" -type f); do
        ~/Projects/ols/odinfmt -w "$i"
    done
