library("data.table")
library("dltr")
library("lubridate")

frf <- function(...)
    rprojroot::find_root_file(..., criterion = ".editorconfig", path = ".")

create_crf <- function(id) {
    root <- frf("raw-data", "04-umg")

    id_chr <- sprintf("%02d", id)

    logbook_files <- list.files(
        frf(root, "logbooks", id_chr), pattern = ".*\\.txt", full.names = TRUE
    )

    logbooks <- do.call(rbind, lapply(
        logbook_files, function(f) {
            l <- read_logbook(f)
            l[, Device := gsub("^.*(ASD[BD]-00[0-9][0-9]).*$", "\\1", f)]
            filter_short_cases(l)
        })
    )

    ## drop CaseId because it starts at 1 in each logbook file
    logbooks[, CaseId := NULL]

    ## logbook files contain overlapping/duplicated data
    logbooks <- unique(logbooks)

    ## sometimes devices/OR were changed
    devices <- fread(frf(root, "logbooks", id_chr, "devices.csv"))
    devices[, `:=` (devices.start = start, devices.end = end)]

    logbooks[, `:=` (logbook.start = DateTime, logbook.end = DateTime)]

    logbooks <- logbooks[
        devices,
        .(DateTime, Label, Current, Unit),
        on = .(Device = device,
               logbook.start >= devices.start, logbook.end <= devices.end)
    ]

    ## VCT-OR-MC start was 2024-06-03 03:00:00
    ## (should already be fulfilled by devices.csv)
    logbooks <- logbooks[DateTime > ymd_hms("2024-06-03 03:00:00"),]

    ## reintroduce CaseId
    logbooks <- add_anaesthesia_case_id(logbooks)

    durations <- logbooks[, case_duration(.SD), by = CaseId]
    setnames(durations, "V1", "Duration")

    flow1.15 <- value_at(logbooks, "FGF", 15, "vaporizer-opening")
    flow2.15 <- value_at(logbooks, "FGF", 15, "mechanical-ventilation")
    flow3.15 <- value_at(logbooks, "FGF", 15, "start")

    # Use 5 min for short cases
    flow1.5 <- value_at(logbooks, "FGF", 5, "vaporizer-opening")
    flow2.5 <- value_at(logbooks, "FGF", 5, "mechanical-ventilation")
    flow3.5 <- value_at(logbooks, "FGF", 5, "start")

    flow1 <- merge(flow1.15, flow1.5)
    flow2 <- merge(flow2.15, flow2.5)
    flow3 <- merge(flow3.15, flow3.5)
    setnames(flow1, c("V1.x", "V1.y"), c("Flow15", "Flow5"))
    setnames(flow2, c("V1.x", "V1.y"), c("Flow15", "Flow5"))
    setnames(flow3, c("V1.x", "V1.y"), c("Flow15", "Flow5"))

    flow1 <- merge(flow1, durations)
    flow2 <- merge(flow2, durations)
    flow3 <- merge(flow3, durations)

    flow1 <- flow1[, Flow := fifelse(Duration < 30, Flow5, Flow15)]
    flow2 <- flow2[, Flow := fifelse(Duration < 30, Flow5, Flow15)]
    flow3 <- flow3[, Flow := fifelse(Duration < 30, Flow5, Flow15)]

    f <- merge(
        merge(
            flow1[, .(CaseId, Flow)], flow2[, .(CaseId, Flow)],
            by = "CaseId", all = TRUE
        ),
        flow3[, .(CaseId, Flow)],
        by = "CaseId", all = TRUE
    )
    setnames(f, c("Flow.x", "Flow.y", "Flow"), c("flow1", "flow2", "flow3"))
    f[, flow :=
        fifelse(!is.na(flow1), flow1, fifelse(!is.na(flow2), flow2, flow3))
    ]
    peep <- value_at(logbooks, "PEEP", 15, "mechanical-ventilation")

    ## we often use a PEEP of 3 for LMA, has to be checked
    peep[, airway := fifelse(V1 <= 3, "L", "T")]

    f <- merge(f, peep[, .(CaseId, airway)], all = TRUE)

    crf <- data.table(
        or.id = id,
        start = case_start(logbooks),
        end = case_end(logbooks),
        balanced.anaesthesia = as.integer(is_volatile_anesthesia(logbooks)),
        flow = f[, flow],
        airway = f[, airway]
    )

    filters <- fread(frf(root, "contrafluran-filters", paste0(id_chr, ".csv")))
    filters[, `:=` (agc.start = start, agc.end = end)]

    crf[, `:=` (crf.start = start, crf.end = end)]

    crf <- crf[
        filters,
        .(or.id, agc.id, agc.number,
          start, end, balanced.anaesthesia, flow, airway),
        on = .(or.id, crf.start >= agc.start, crf.end <= agc.end)
    ]

    bottles <- fread(frf(root, "sevoflurane-bottles", paste0(id_chr, ".csv")))
    bottles[, `:=` (bottles.start = start, bottles.end = end)]

    crf[, `:=` (crf.start = start, crf.end = end)]

    crf <- crf[
        bottles,
        .(or.id, agc.id, agc.number, bottle.number,
          start, end, balanced.anaesthesia, flow, airway),
        on = .(or.id, crf.start >= bottles.start, crf.end <= bottles.end)
    ]

    crf[, `:=` (
        ## 04-umg
        center.id = 4,
        ## has to be added by another source
        laparoscopic = 0L,
        comments = character()
    )]
    setcolorder(crf, "center.id", before = "or.id")

    corrections  <- fread(frf(root, "corrections", paste0(id_chr, ".csv")))

    if (nrow(corrections))
        crf[match(corrections$start, crf$start),] <- corrections

    fwrite(
        crf,
        file = frf("raw-data", "crfs", paste0("04-", id_chr, ".csv")),
        dateTimeAs = "write.csv"
    )
}

iORs <- as.numeric(dir(frf("raw-data", "04-umg", "logbooks")))

for (i in iORs)
    create_crf(i)
