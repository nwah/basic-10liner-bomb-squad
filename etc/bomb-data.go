package main

import (
	"fmt"
	"math/rand/v2"
	"sort"
	"strings"
)

// blue
// blue-stripe
// red
// red-stripe
// green
// green-stripe

// var wires = []string{"a", "a_", "b", "b_", "c", "c_"}
var wires = []string{"a", "b", "c", "d", "e", "f"}

// var wire2byte = map[string]byte{"a": 0x00, "a_": 0x04, "b": 0x01, "b_": 0x05, "c": 0x02, "c_": 0x06}

func main() {
	groups := make([][][]byte, 0)

	for size := 3; size < 7; size++ {
		bombs := make(map[string][]int)
		for len(bombs) < 25 {
			for range size {
				bomb := make([]string, 6)
				indexes := rand.Perm(6)
				for i, index := range indexes {
					bomb[i] = wires[index]
				}
				bombstr := strings.Join(bomb[:size], " ")
				if bombs[bombstr] == nil {
					bombs[bombstr] = rand.Perm(size)
				}
			}
		}

		sorted := make([]string, len(bombs))
		i := 0
		for k := range bombs {
			sorted[i] = k
			i++
		}
		sort.Strings(sorted)

		sorted = sorted[:12] // 20, 20, 20, 20
		// if size == 6 {
		// 	sorted = sorted[:10]
		// }
		// sorted = sorted[:40-size*5] // 25, 20, 15, 10
		// sorted = sorted[:35-size*5] // 20, 15, 10, 5
		// sorted = sorted[:30-size*5] // 15, 10, 5, 0
		// sorted = sorted[:20-(size-3)*3] // 20, 17, 14, 11

		group := make([][]byte, 0)
		for _, bombstr := range sorted {
			bombbytes := make([]byte, 0)
			solution := bombs[bombstr]

			for w, wire := range strings.Split(bombstr, " ") {
				wirebyte := wire[0]
				if len(wire) > 1 {
					wirebyte -= 32
					// 	wirebyte += 4
				}
				orderbyte := byte('0' + solution[w])

				bombbytes = append(bombbytes, wirebyte)
				bombbytes = append(bombbytes, orderbyte)
			}
			group = append(group, bombbytes)
		}

		for _, bomb := range group {
			for _, wire := range bomb {
				// fmt.Printf("$%02X", wire)
				fmt.Print(string(wire))
			}
			// fmt.Println()
		}
		fmt.Println()
		groups = append(groups, group)
	}

	fmt.Println()

	for _, g := range groups {
		fmt.Println(len(g))
	}

	// 15 * 3 * 3 + 10 * 4 * 3 + 10 * 5 * 3 + 5 * 6 * 3 = 495 (40)
	// 12 * 3 * 3 + 5 * 4 * 3 + 5 * 5 * 3 + 0 * 6 * 3 = 243 (22)
	// fmt.Println(bombs)
}
