GUIX:=/usr/local/bin/guix
GUIXTM:=${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm
RAWDATA:=raw-data

CRF=$(wildcard $(RAWDATA)/crfs/*.csv)
SETTING=$(RAWDATA)/setting.csv

DATE=$(shell date +'%Y%m%d')
GITHEAD=$(shell git rev-parse --short HEAD)
GITHEADL=$(shell git rev-parse HEAD)

.DELETE_ON_ERROR:


progress: docs/progress.html docs/validate.html

docs/progress.html: docs/progress.Rmd $(CRF) $(SETTING)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('docs/progress.Rmd', output_dir = 'docs')"

docs/validate.html: docs/validate.Rmd $(CRF) $(SETTING)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('docs/validate.Rmd', output_dir = 'docs')"

.PHONEY: validate
validate: validate-crf

validate-crf: $(CRF)
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm -- \
		Rscript -e "source('validation/validate.R'); validate_all()"

.PHONEY:
shell:
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm

## pinning guix channels to latest commits
.PHONEY: guix-pin-channels
guix-pin-channels: guix/channels.pinned.scm

guix/channels.pinned.scm: guix/channels.scm FORCE
	${GUIX} time-machine --channels=guix/channels.scm -- \
		describe -f channels > guix/channels.pinned.scm

FORCE:
