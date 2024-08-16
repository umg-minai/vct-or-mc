# Multicenter, observational study of vapour capture technology in the OR (VCT-OR-MC)

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

## Directory structure

### Data

- `raw-data`: case report forms of all centers.

### Manuscript

- `manuscript/manuscript.Rmd`: main file (contains manuscript and author information) loading all subsections.
- `manuscript/sections/*.Rmd`: a file per subsection containing the manuscript content.
- `manuscript/bibliography/`: references in bibtex format.
- `manuscript/pandoc/`: `pandoc` related files for word counts etc.

### Miscellaneous files

- `guix/`: [guix](https://guix.gnu.org) releated files to ensure a reproducible `R` and `pandoc` environment.


## Bootstrap

### Guix on debian

```bash
sudo apt install make git guix
```

### Fetch sources

```bash
git clone git@github.com:umg-minai/vct-or-mc.git
```

## Build manuscript

Running `make` the first time will take some time because
`guix` hast to download the given state and build the image.

```bash
make
```

### Modify the manuscript

All the work has to be done in the `manuscript/sections/*.Rmd` files.

### Make targets

- `make` or `make manuscript` produces an `.html` file in `manuscript/output/`.
- `make dist` produces a `.docx` in `distribute/` which could be send to the
  co-authors.
- `make validate` for data validation.
- `make clean` removes all generated files.

## Predecessor singlecenter study

https://github.com/umg-minai/vct-or

## Contact/Contribution

You are welcome to:

- submit suggestions and bug-reports at: <https://github.com/umg-minai/vct-or-mc/issues>
- send a pull request on: <https://github.com/umg-minai/vct-or-mc/>
- compose an e-mail to: <mail@sebastiangibb.de>

We try to follow:

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Line Breaks](https://sembr.org/)
