RMD=$(wildcard *.Rmd)
OUTPUTDIR:=output
ODT=$(OUTPUTDIR)/$(RMD:%.odt=%.Rmd)

.DELETE_ON_ERROR:

.PHONEY: \
	clean

all: $(ODT)

$(OUTPUTDIR):
	@mkdir -p $(OUTPUTDIR)

$(ODT): $(RMD) | $(OUTPUTDIR)
	PATH=/usr/bin:$$PATH Rscript -e "rmarkdown::render('$<', output_dir = '$(OUTPUTDIR)')"

clean:
	@rm -rf $(ODT)
