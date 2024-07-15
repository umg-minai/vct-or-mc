is.character(agc.id)

field_format(agc.id, '^C[HN][0-9]{10,}', type = 'regex')

field_length(agc.id, n = 12)
