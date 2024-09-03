library("minair")
library("validate")

options(warn = 1)

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

    set <- read.csv(find_git_root_file("raw-data", "setting.csv"))
    dat  <- read.csv(
        csv, comment.char = "#", na.strings = c("NA", ""), tryLogical = FALSE
    )

    vld <- rename_rules(validator(.file = yml))
    crf <- confront(dat, vld, ref = list(ref_settings = set))
    smr <- summary(crf)

    dat$Comment <- shorten(dat$Comment, 53)
    smr$expression <- shorten(smr$expression, 33)

    failing <- which(smr$fails > 0)

    if (verbose) {
        if (length(failing)) {
            cat("\n")

            print(vld[failing])

            cat("\n")

            print(violating(dat, crf[failing]))
        } else {
            cat(", ", nrow(dat), " rows: OK\n", sep = "")
        }
    }

    invisible(crf)
}

validate_all <- function(plot = FALSE, verbose = TRUE) {
    ## settings
    settings <- validate(
        csv = find_git_root_file("raw-data", "setting.csv"),
        yml = find_git_root_file("validation", "setting.yml"),
        verbose = verbose
    )

    if (plot) {
        cat("\n\n## settings\n\n")
        plot(settings)
    }

    ## CRFs
    csvs <- list.files(
        find_git_root_file("raw-data", "crfs"),
        pattern = "*\\.csv",
        full.names = TRUE
    )
    yml <- find_git_root_file("validation", "crf.yml")

    for (csv in csvs) {
        crf <- validate(csv = csv, yml = yml, verbose = verbose)
        if (plot) {
            cat("\n\n## ", basename(tools::file_path_sans_ext(csv)),"\n\n")
            plot(crf)
        }
    }

    ## weights
    csvs <- list.files(
        find_git_root_file("raw-data", "weights"),
        pattern = "*\\.csv",
        full.names = TRUE
    )
    yml <- find_git_root_file("validation", "weights.yml")

    for (csv in csvs) {
        weights <- validate(csv = csv, yml = yml, verbose = verbose)
        if (plot) {
            cat("\n\n## ", basename(tools::file_path_sans_ext(csv)),"\n\n")
            plot(weights)
        }
    }
}
