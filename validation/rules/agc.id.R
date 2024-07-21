is.character(agc.id)

field_format(agc.id, '^C[HN][0-9]{10,}', type = 'regex')

field_length(agc.id, n = 12)

# the "old" agcs have an ID over 20000 and the new ones below 10000
(
    substr(agc.id, 2, 2) == "H" &
    as.numeric(substr(agc.id, 7, 12)) > 20000
) |
(
    substr(agc.id, 2, 2) == "N" &
    as.numeric(substr(agc.id, 7, 12)) < 10000
)
