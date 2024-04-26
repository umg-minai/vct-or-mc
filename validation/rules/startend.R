is.character(start)

field_length(start, 8)

field_format(start, "dd:dd:dd")

is.character(end)

field_length(end, 8)

field_format(end, "dd:dd:dd")

as.POSIXct(paste(date, start)) < as.POSIXct(paste(date, end))
