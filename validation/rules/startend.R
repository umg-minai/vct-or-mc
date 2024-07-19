is.character(start)

field_length(start, 19)

ifelse(
    is.na(start),
    NA,
    field_format(
        start,
        "202[45]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]",
        type = "regex"
    )
) == TRUE ## needed to show validate that `ifelse` returns a logical vector

is.character(end)

field_length(end, 19)

ifelse(
    is.na(end),
    NA,
    field_format(
        end,
        "202[45]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]",
        type = "regex"
    )
) == TRUE ## needed to show validate that `ifelse` returns a logical vector

lubridate::ymd_hms(start) < lubridate::ymd_hms(end)

c(TRUE,
  lubridate::ymd_hms(start[-1]) >= lubridate::ymd_hms(end[-length(end)])
) == TRUE ## needed to show validate that it returns a logical vector

c(TRUE,
  lubridate::ymd_hms(start) > ymd_hms("2024-06-03 03:00:00")
) == TRUE ## needed to show validate that it returns a logical vector
