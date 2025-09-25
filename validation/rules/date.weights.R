is.character(date.weight1)

field_length(date.weight1, 10)

ifelse(
    is.na(date.weight1),
    NA,
    field_format(
        date.weight1,
        "2025-0[6-8]-[0-3][0-9]",
        type = "regex"
    )
) == TRUE ## needed to show validate that `ifelse` returns a logical vector

is.character(date.weight2)

field_length(date.weight2, 10)

ifelse(
    is.na(date.weight2),
    NA,
    field_format(
        date.weight2,
        "2025-0[6-8]-[0-3][0-9]",
        type = "regex"
    )
) == TRUE ## needed to show validate that `ifelse` returns a logical vector

lubridate::ymd_hms(date.weight1) < lubridate::ymd_hms(date.weight2)
