package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

//     N = P * 10^k + P
//       = P * (10^k + 1)
//
// Example:
//     123123 = 123 * 10^3 + 123
//            = 123 * (1000 + 1)
//            = 123 * 1001

ID :: struct {
	first: int,
	last:  int,
}

main :: proc() {
	file, err := os.read_entire_file("input.txt", context.allocator)
	if err != nil {
		fmt.printfln("Error: reading input file: %v", err)
		return
	}
	defer delete(file)

	ids, ok := parse_file(file, context.allocator)
	if !ok {
		fmt.println("Error: unable to parse file")
		return
	}
	defer delete(ids)

	part_1, part_2 := 0, 0

	for id in ids {
		p1, p2 := sum_mirrors(id)
		part_1 += p1
		part_2 += p2
	}
	fmt.printfln("part 1: %d, part 2: %d", part_1, part_2)
}

parse_file :: proc(
	content: []byte,
	allocator := context.allocator,
) -> (
	ids: [dynamic]ID,
	ok: bool,
) {
	context.allocator = allocator

	ids = make([dynamic]ID)

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

sum_mirrors :: proc(id: ID) -> (part_1: int, part_2: int) {
	start_digits := digits(id.first)
	end_digits := digits(id.last)

	seen_part_1 := make(map[int]struct{}, context.allocator)
	seen_part_2 := make(map[int]struct{}, context.allocator)
	defer delete(seen_part_1)
	defer delete(seen_part_2)

	for total_digits := start_digits; total_digits <= end_digits; total_digits += 1 {
		for pattern_digits := 1; pattern_digits <= total_digits / 2; pattern_digits += 1 {
			if total_digits % pattern_digits != 0 {
				continue
			}

			repetitions := total_digits / pattern_digits
			base := pow10(pattern_digits)

			multiplier := 0
			power := 1

			for i := 0; i < repetitions; i += 1 {
				multiplier += power
				power *= base
			}

			first_pattern := ceil_div(id.first, multiplier)
			last_pattern := id.last / multiplier

			min_pattern := pow10(pattern_digits - 1)
			max_pattern := pow10(pattern_digits) - 1

			if first_pattern < min_pattern {
				first_pattern = min_pattern
			}

			if last_pattern > max_pattern {
				last_pattern = max_pattern
			}

			if first_pattern > last_pattern {
				continue
			}

			for pattern := first_pattern; pattern <= last_pattern; pattern += 1 {
				invalid := pattern * multiplier

				seen_part_2[invalid] = {}

				if repetitions == 2 {
					seen_part_1[invalid] = {}
				}
			}
		}
	}

	for value in seen_part_1 {
		part_1 += value
	}

	for value in seen_part_2 {
		part_2 += value
	}

	return part_1, part_2
}

ceil_div :: proc(a, b: int) -> int {
	return (a + b - 1) / b
}

digits :: proc(n: int) -> int {
	if n == 0 {
		return 1
	}

	value := n
	count := 0

	for value > 0 {
		value /= 10
		count += 1
	}

	return count
}

pow10 :: proc(n: int) -> int {
	result := 1

	for i := 0; i < n; i += 1 {
		result *= 10
	}

	return result
}
