is.character(start)

!is.na(start) | field_length(start, 19)

!is.na(start) | field_format(
    start,
    "202[45]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]",
    type = "regex"
)

is.character(end)

!is.na(end) | field_length(end, 19)

!is.na(end) | field_format(
    end,
    "202[45]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9]",
    type = "regex"
)

lubridate::ymd_hms(start) < lubridate::ymd_hms(end)

(!is.na(start) & !is.na(end)) & lubridate::ymd_hms(start[-1]) >= lubridate::ymd_hms(end[-length(end)])

lubridate::ymd_hms(start) > ymd_hms("2024-06-03 03:00:00")
