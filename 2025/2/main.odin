package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

ID :: struct {
	first: int,
	last:  int,
}

main :: proc() {
	file, err := os.read_entire_file("input.txt", context.allocator)
	if err != nil {
		fmt.printfln("Error: reading input file: ", err)
		return
	}
	defer delete(file)

	ids, ok := parse_file(file)
	if !ok {
		fmt.printfln("Error: unable to parse file")
		return
	}

	for id, i in ids {
		fmt.printfln("id %i: first %i, last: %i", i, id.first, id.last)
	}
}

parse_file :: proc(
	content: []byte,
	allocator := context.allocator,
) -> (
	ids: [dynamic]ID,
	ok: bool,
) {
	ids = make([dynamic]ID, allocator)

	for line in strings.split_lines(string(content)) {
		if len(line) == 0 {
			continue
		}

		ranges := strings.split(line, ",")

		for range in ranges {
			id, ok := parse_id(range)
			if !ok {
				return ids, false
			}

			append(&ids, id)
		}
	}

	return ids, true
}

parse_id :: proc(s: string) -> (id: ID, ok: bool) {
	parts := strings.split(s, "-")

	if len(parts) != 2 {
		return {}, false
	}

	first, first_ok := strconv.parse_int(parts[0])
	last, last_ok := strconv.parse_int(parts[1])

	if !first_ok || !last_ok {
		return {}, false
	}

	return ID{first, last}, true
}
