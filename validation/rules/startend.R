is.character(start)

field_length(start, 8)

field_format(start, "[0-2][0-9]:[0-5][0-9]:00", type = "regex")

is.character(end)

field_length(end, 8)

field_format(end, "[0-2][0-9]:[0-5][0-9]:00", type = "regex")

as.POSIXct(paste(date, start)) < as.POSIXct(paste(date, end))
