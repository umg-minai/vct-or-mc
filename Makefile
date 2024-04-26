GUIX:=/usr/local/bin/guix
GUIXTM:=${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm
RAWDATA:=raw-data

CRF=$(wildcard $(RAWDATA)/crf.csv)

DATE=$(shell date +'%Y%m%d')
GITHEAD=$(shell git rev-parse --short HEAD)
GITHEADL=$(shell git rev-parse HEAD)

.DELETE_ON_ERROR:


progress: docs/progress.html

docs/progress.html: docs/progress.Rmd $(CRF)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('docs/progress.Rmd', output_dir = 'docs')"

.PHONEY: validate
validate: validate-crf

validate-crf: $(CRF)
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm -- \
		Rscript validation/validate.R

## pinning guix channels to latest commits
.PHONEY: guix-pin-channels
guix-pin-channels: guix/channels.pinned.scm

guix/channels.pinned.scm: guix/channels.scm FORCE
	${GUIX} time-machine --channels=guix/channels.scm -- \
		describe -f channels > guix/channels.pinned.scm

FORCE:
