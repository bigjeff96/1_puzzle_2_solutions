debug_flags := "-use-separate-modules -debug -dynamic-map-calls"
exe :=  if os() == "linux" {"build/puzzle_solver.exe"} else {"build/puzzle_solver.exe"}
FIND := if os() == "windows" {"C:/cygwin64/bin/find"} else {"find"}

build: fmt
    odin build src {{ debug_flags }} -out:{{ exe }}

run: build
    ./{{ exe }}

test: fmt
    odin test src/

fmt:
   #!/bin/sh
   set -ep
   for i in $({{FIND}} . -name "*.odin" -type f); do
       odinfmt -w "$i"
   done
