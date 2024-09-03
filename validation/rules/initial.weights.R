is.numeric(initial.weight)

(
    substr(agc.id, 2, 2) == "H" &
    in_range(initial.weight, min = 1020L, max = 1066L)
) |
(
    substr(agc.id, 2, 2) == "N" &
    in_range(initial.weight, min = 1051L, max = 1062L)
)
