library("lubridate")
library("minair")

crfs <- do.call(
    rbind,
    lapply(
        list.files(
            find_git_root_file("raw-data", "crfs"),
            pattern = "*\\.csv",
            full.names = TRUE
            ),
        function(x)
            read.csv(x, tryLogical = FALSE)[
                c("center.id", "agc.id", "start", "end")
            ]
    )
)

crfs$start <- ymd_hms(crfs$start)
crfs$end <- ymd_hms(crfs$end)

agcs <- do.call(rbind.data.frame, tapply(crfs, crfs$agc.id, function(x) {
    list(
        center.id = x$center.id[1L],
        agc.id = x$agc.id[1L],
        start = min(x$start, na.rm = TRUE),
        end = max(x$end, na.rm = TRUE)
    )
}))

## contacts.csv is not part of the git repository due to privacy reasons
centers <- unique(
    read.csv(
        find_git_root_file("contacts", "contacts.csv")
    )[c("ID", "Zentrum")]
)

d <- merge(agcs, centers, by.x = "center.id", by.y = "ID")
d$center.id <- NULL
names(d) <- c("Chargennummer", "Start", "Ende", "Zentrum")
d <- d[c("Chargennummer", "Zentrum", "Start", "Ende")]

d$Start <- as.POSIXct(d$Start)
d$Ende <- as.POSIXct(d$Ende)

writexl::write_xlsx(
    d,
    path = find_git_root_file(
        "export",
        paste0(format(Sys.Date(), "%Y%m%d"), "_vct-or-mc_agcs-per-center.xlsx")
    )
)
