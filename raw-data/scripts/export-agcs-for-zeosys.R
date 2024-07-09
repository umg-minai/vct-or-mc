frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

agcs <- do.call(
    rbind,
    lapply(
        list.files(
            frf("raw-data", "crfs"),
            pattern = "*\\.csv",
            full.names = TRUE
            ),
        function(x)
            read.csv(x, tryLogical = FALSE)[
                c("center.id", "agc.id")
            ]
    )
)

agcs <- unique(agcs)

## contacts.csv is not part of the git repository due to privacy reasons
centers <- unique(read.csv(frf("contacts", "contacts.csv"))[c("ID", "Zentrum")])

d <- merge(agcs, centers, by.x = "center.id", by.y = "ID")
d$center.id <- NULL
names(d) <- c("Chargennummer", "Zentrum")

writexl::write_xlsx(
    d,
    path = frf(
        "export",
        paste0(format(Sys.Date(), "%Y%m%d"), "_vct-or-mc_agcs-per-center.xlsx")
    )
)
