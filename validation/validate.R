library("validate")

options(warn = 1)

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

shorten <- function(x, maxn = 80) {
    if (is.null(x)) return(NULL)
    ifelse(nchar(x) > maxn, paste(substring(x, 1, maxn - 3), "..."), x)
}

rename_rules <- function(x) {
    rls <- x$rules
    org <- basename(tools::file_path_sans_ext(sapply(rls, origin)))
    org[order(org)] <- unlist(
        tapply(org, org, \(x)sprintf("%s:%02i", x, seq_along(x)))
    )
    for (i in seq_along(x$rules))
        names(x$rules[[i]]) <- org[i]
    x
}

validate <- function(csv, yml, verbose = TRUE) {
    if (verbose)
        cat("\n===\n", basename(csv), sep = "")

    dat  <- read.csv(csv, comment.char = "#", tryLogical = FALSE)

    vld <- rename_rules(validator(.file = yml))
    cfr <- confront(dat, vld)
    smr <- summary(cfr)

    dat$Comment <- shorten(dat$Comment, 53)
    smr$expression <- shorten(smr$expression, 33)

    failing <- which(smr$fails > 0)

    if (verbose) {
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
    }

    invisible(cfr)
}

validate_all <- function(plot = FALSE, verbose = TRUE) {
    cfr <- validate(
        csv = frf("raw-data", "setting.csv"),
        yml = frf("validation", "setting.yml"),
        verbose = verbose
    )

    if (plot) {
        cat("\n\n## settings\n\n")
        plot(cfr)
    }

    csvs <- list.files(
        frf("raw-data", "crfs"),
        pattern = "*\\.csv",
        full.names = TRUE
    )
    yml <- frf("validation", "crf.yml")

    for (csv in csvs) {
        cfr <- validate(csv = csv, yml = yml, verbose = verbose)
        if (plot) {
            cat("\n\n## ", basename(tools::file_path_sans_ext(csv)),"\n\n")
            plot(cfr)
        }
    }
}

