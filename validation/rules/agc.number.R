is.integer(agc.number)

agc.number > 0L

# Are ID and number changing in the same row?
c(TRUE,
  (agc.id[-1L] == agc.id[-length(agc.id)]) ==
      (agc.number[-1L] == agc.number[-length(agc.number)])
) == TRUE
