GUIX:=/usr/local/bin/guix
GUIXTM:=${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm
RAWDATA:=raw-data

CRF=$(wildcard $(RAWDATA)/crfs/*.csv)
SETTING=$(RAWDATA)/setting.csv

MANUSCRIPT:=manuscript
SECTIONDIR:=manuscript/sections
RMD=$(wildcard $(SECTIONDIR)/*.Rmd)
DOCSRMD=$(wildcard docs/*.Rmd)
HTMLS=$(DOCSRMD:%.Rmd=%.html)
BIB=manuscript/bibliography/bibliography.bib
DISTDIR:=distribute
OUTPUTDIR:=manuscript/output

DATE=$(shell date +'%Y%m%d')
GITHEAD=$(shell git rev-parse --short HEAD)
GITHEADL=$(shell git rev-parse HEAD)

.DELETE_ON_ERROR:

all: manuscript

.PHONEY: manuscript
manuscript: $(OUTPUTDIR)/$(MANUSCRIPT).html

$(OUTPUTDIR):
	@mkdir -p $(OUTPUTDIR)

$(OUTPUTDIR)/$(MANUSCRIPT).html: manuscript/$(MANUSCRIPT).Rmd $(RMD) $(BIB) guix/manifest.scm | $(OUTPUTDIR)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('$<', output_dir = '$(OUTPUTDIR)')"

$(OUTPUTDIR)/$(MANUSCRIPT).docx: manuscript/$(MANUSCRIPT).Rmd $(RMD) $(BIB) guix/manifest.scm | $(OUTPUTDIR)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('$<', output_format = 'bookdown::word_document2', output_dir = '$(OUTPUTDIR)')"

$(DISTDIR):
	@mkdir -p $(DISTDIR)

dist: $(OUTPUTDIR)/$(MANUSCRIPT).docx | $(DISTDIR)
	@cp $< $(DISTDIR)/"$(DATE)_$(GITHEAD)_$(MANUSCRIPT).docx"

progress: docs/progress.html docs/validate.html

docs/%.html: docs/%.Rmd $(CRF) $(SETTING)
	${GUIXTM} -- \
		Rscript -e "rmarkdown::render('$<', output_dir = 'docs')"

docs: $(HTMLS) docs/manuscript.html

docs/manuscript.html: manuscript
	sed 's#</h4>#</h4> \
<div style="background-color: \#ffc107; padding: 10px; text-align: center;"> \
<strong>This study is work-in-progress!</strong><br /> \
Please find details at <a href="https://github.com/umg-minai/vct-or-mc">https://github.com/umg-minai/vct-or-mc</a>.<br /> \
Manuscript date: $(shell date +"%Y-%m-%d %H:%M"); Version: <a href="https://github.com/umg-minai/vct-or-mc/commit/$(GITHEADL)">$(GITHEAD)</a> \
</div>#' $(OUTPUTDIR)/$(MANUSCRIPT).html > docs/manuscript.html

.PHONEY: validate
validate: validate-crf

validate-crf: $(CRF)
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm -- \
		Rscript -e "source('validation/validate.R'); validate_all()"

.PHONEY: generate-umg-crfs
generate-umg-crfs:
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm -- \
		Rscript -e "source('raw-data/04-umg/create-umg-crfs.R')"

.PHONEY: export-agcs-for-zeosys
export-agcs-for-zeosys:
	${GUIX} time-machine --channels=guix/channels.pinned.scm -- \
		shell --manifest=guix/manifest.scm r-writexl -- \
		Rscript -e "source('raw-data/scripts/export-agcs-for-zeosys.R')"

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

.PHONEY: clean
clean: clean-dist clean-output

.PHONEY: clean-dist
clean-dist:
	@rm -rf $(DISTDIR)

.PHONEY: clean-output
clean-output:
	@rm -rf $(OUTPUTDIR)

FORCE:
