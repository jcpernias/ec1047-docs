SHELL := /bin/sh

## Source files
## ================================================================================

src-files := \
	ineq.org \
	ineq-sol.org \
	pov.org \
	pov-sol.org

## Directories
## --------------------------------------------------------------------------------

root-dir := .
org-dir := $(root-dir)/org
build-dir := $(root-dir)/build
data-dir := $(root-dir)/data
pdf-dir := $(root-dir)/pdf
R-dir := $(root-dir)/R
tex-dir := $(root-dir)/tex
fig-dir := $(root-dir)/figures

## Programs
## ================================================================================

emacsbin := /usr/bin/emacs
texi2dvibin := /usr/bin/texi2dvi
envbin  := /usr/bin/env
pythonbin := /usr/bin/python3
Rscriptbin := /usr/local/bin/Rscript
latexmkbin := /Library/TeX/texbin/latexmk

-include local.mk

## Variables
## ================================================================================

## Print info ----------------------------------------
LATEX_MESSAGES := no
PRINT_INFO := no
USE_LUALATEX := no

## emacs ---------------------------------------------
EMACS := $(emacsbin) -Q -nw --batch


## latexmk -----------------------------------------
LATEX_ENGINE := -pdf
ifeq ($(USE_LUALATEX), yes)
LATEX_ENGINE := -lualatex
endif

LATEXMK_FLAGS := $(LATEX_ENGINE) -cd -nobibfudge

ifneq ($(LATEX_MESSAGES), yes)
LATEXMK_FLAGS += -quiet
endif

LATEXMK := $(envbin) TEXINPUTS=$(build-dir)/:$(data-dir)/: \
	$(latexmkbin) $(LATEXMK_FLAGS)

## Rscript -----------------------------------------

RSCRIPT := $(Rscriptbin)

## Targets -----------------------------------------

org-files := $(addprefix $(org-dir)/,$(src-files))
tex-files := $(addprefix $(build-dir)/,$(patsubst %.org,%.tex,$(src-files)))
pdf-files := $(addprefix $(pdf-dir)/,$(patsubst %.org,%.pdf,$(src-files)))

tex-deps := $(root-dir)/setup.org $(root-dir)/setup-emacs.el

pdf-deps := $(build-dir)/preamble.tex

VPATH := $(buid-dir)

dir-path = $(dir $(abspath $(1)))


ifeq ($(PRINT_INFO), yes)
$(info src-files: $(src-files))
$(info org-files: $(org-files))
$(info tex-files: $(tex-files))
$(info pdf-files: $(pdf-files))
endif

all: $(pdf-files)

.PRECIOUS: $(build-dir)/%.tex
$(build-dir)/%.tex: $(org-dir)/%.org $(tex-deps) | $(build-dir)
	$(EMACS) --load=./setup-emacs.el --visit=$< \
		--eval '(org-to-latex "$(call dir-path,$@)")'

$(build-dir)/%.pdf: $(build-dir)/%.tex $(pdf-deps) | $(build-dir)
	$(LATEXMK) $<

.PRECIOUS: $(pdf-dir)/%.pdf
$(pdf-dir)/%.pdf: $(build-dir)/%.pdf | $(pdf-dir)
	$(MV) $< $@

$(build-dir)/preamble.tex: $(root-dir)/preamble.tex | $(build-dir)
	$(CP) $< $@


.PRECIOUS:  $(build-dir)/%.csv
$(build-dir)/%.csv: $(data-dir)/%.org | $(build-dir)
	$(EMACS) --load=./setup-emacs.el --visit=$< \
		--eval '(eval-org-buffer "$(call dir-path,$@)")'

## ineq.org dependencies ------------------------------------------------
ineq-fig-files := $(addprefix $(tex-dir)/ineq-fig-,\
	$(addsuffix .tex,lorenz lorenz-comp1 lorenz-comp2 gini))
$(build-dir)/ineq.tex: $(ineq-fig-files)
$(build-dir)/ineq.tex: $(org-dir)/lorenz-table.org
$(build-dir)/lorenz-data.csv: $(org-dir)/lorenz-table.org
$(pdf-dir)/ineq.pdf: $(build-dir)/lorenz-data.csv

## pov.org dependencies -------------------------------------------------
pov-fig-files := $(addprefix $(tex-dir)/pov-fig-,$(addsuffix .tex,pen h z pg))
$(build-dir)/ineq.tex: $(pov-fig-files)

pov-csv-files := $(addprefix $(build-dir)/,pen.csv povline.csv)
$(pov-csv-files): pov-csv.intermediate
	@:

.INTERMEDIATE: pov-csv.intermediate
pov-csv.intermediate: $(R-dir)/pov.R $(data-dir)/rentas.xlsx
	$(RSCRIPT) $< $(build-dir)

$(pdf-dir)/pov.pdf: $(pov-csv-files)


## ineq-sol.org dependencies -------------------------------------------------
ineq-fig-files := $(addprefix $(fig-dir)/,$(addsuffix .pdf,Gini H S80S20 ypc))

$(ineq-fig-files): ineq-fig-files.intermediate
	@:

ineq-fig-files-deps := $(data-dir)/ineq-data.xlsx $(data-dir)/ccaa.csv
.INTERMEDIATE: ineq-fig-files.intermediate
ineq-fig-files.intermediate: $(R-dir)/ineq-es.R $(ineq-fig-files-dep) | $(fig-dir)
	$(RSCRIPT) $<

$(pdf-dir)/ineq-sol.pdf: $(ineq-fig-files)

## Create directories
## --------------------------------------------------------------------------------

$(build-dir) $(pdf-dir) $(fig-dir):
	mkdir $@


## Cleaning rules
## --------------------------------------------------------------------------------
.PHONY: clean
clean:
	-@rm -r $(pdf-dir)
	-@rm -r $(fig-dir)

.PHONY: veryclean
veryclean: clean
	-@rm -r $(build-dir)


# Local Variables:
# mode: makefile-gmake
# eval: (flyspell-mode -1)
# End:
