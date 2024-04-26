library("validate")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

shorten <- function(x, maxn = 80) {
    if (is.null(x)) return(NULL)
    ifelse(nchar(x) > maxn, paste(substring(x, 1, maxn - 3), "..."), x)
}

validate <- function(csv, yml) {
    cat("\n===\n", basename(csv), sep = "")

    dat  <- read.csv(csv, comment.char = "#", tryLogical = FALSE)

    vld <- validator(.file = yml)
    cfr <- confront(dat, vld)
    smr <- summary(cfr)

    dat$Comment <- shorten(dat$Comment, 53)
    smr$expression <- shorten(smr$expression, 33)

    failing <- which(smr$fails > 0)

    if (length(failing)) {
        cat("\n")

        print(smr)

        cat("---\n")

        print(vld[failing])

        cat("\n")

        print(violating(dat, vld[failing]))
    } else {
        cat(", ", nrow(dat), " rows: OK\n", sep = "")
    }

    invisible(cfr)
}

validate(
    csv = frf("raw-data", "setting.csv"),
    yml = frf("validation", "setting.yml")
)

validate(
    csv = frf("raw-data", "crf.csv"),
    yml = frf("validation", "crf.yml")
)
