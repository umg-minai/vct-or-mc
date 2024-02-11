RMD=$(wildcard *.Rmd)
OUTPUTDIR:=output
ODT=$(OUTPUTDIR)/$(RMD:%.Rmd=%.odt)
DOCX=$(OUTPUTDIR)/$(RMD:%.Rmd=%.docx)
SUBMISSIONDIR:=submission

.DELETE_ON_ERROR:

.PHONEY: \
	clean \
	dist

all: $(ODT) output/anschreiben.pdf

$(OUTPUTDIR):
	@mkdir -p $(OUTPUTDIR)

$(SUBMISSIONDIR):
	@mkdir -p $(SUBMISSIONDIR)

output/%.odt: %.Rmd | $(OUTPUTDIR)
	PATH=/usr/bin:$$PATH Rscript -e "rmarkdown::render('$<', output_dir = '$(OUTPUTDIR)')"

output/%.docx: $(ODT) | $(OUTPUTDIR)
	PATH=/usr/bin:$$PATH libreoffice --headless --convert-to docx $< --outdir $(OUTPUTDIR)

output/anschreiben.pdf: anschreiben.md
	PATH=/usr/bin:$$PATH pandoc $< --template=pandoc/templates/letter.tex --output $@

dist: $(DOCX) output/anschreiben.pdf | $(SUBMISSIONDIR)
	cp output/anschreiben.pdf $(SUBMISSIONDIR)/
	cp $< $(SUBMISSIONDIR)/

clean:
	@rm -rf $(DOCX) $(ODT) output/anschreiben.pdf
