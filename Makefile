SHELL := /bin/sh

## Source files
## ================================================================================

src-files := \
	ineq.org \
	pov.org

## Directories
## --------------------------------------------------------------------------------

root-dir := .
org-dir := $(root-dir)/org
build-dir := $(root-dir)/build
data-dir := $(root-dir)/data
pdf-dir := $(root-dir)/pdf



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
EMACS := $(emacsbin) -Q -nw --batch
org-to-latex := --eval "(tolatex (file-name-as-directory \"$(builddir)\"))"
org-eval := --eval "(eval-org-buffer (file-name-as-directory \"$(builddir)\"))"

LATEXMK_FLAGS := -lualatex -recorder -emulate-aux-dir

LATEX_MESSAGES := no
ifneq ($(LATEX_MESSAGES), yes)
LATEXMK_FLAGS += -quiet
endif

LATEXMK := $(envbin) TEXINPUTS=$(build-dir)/:$(data-dir)/: \
	$(latexmkbin) $(LATEXMK_FLAGS)

org-files := $(addprefix $(org-dir)/,$(src-files))
tex-files := $(addprefix $(build-dir)/,$(patsubst %.org,%.tex,$(src-files)))
pdf-files := $(addprefix $(pdf-dir)/,$(patsubst %.org,%.pdf,$(src-files)))

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
$(build-dir)/%.tex: $(org-dir)/%.org setup.org ./setup-emacs.el | $(build-dir)
	$(EMACS) --load=./setup-emacs.el --visit=$< \
		--eval '(org-to-latex "$(call dir-path,$@)")'

.PRECIOUS: $(pdf-dir)/%.pdf
$(pdf-dir)/%.pdf: $(build-dir)/%.tex preamble.tex | $(pdf-dir)
	$(LATEXMK) -aux-directory=$(build-dir) \
		-output-directory=$(pdf-dir) $<

.PRECIOUS:  $(build-dir)/%.csv
$(build-dir)/%.csv: $(data-dir)/%.org | $(build-dir)
	$(EMACS) --load=./setup-emacs.el --visit=$< \
		--eval '(eval-org-buffer "$(call dir-path,$@)")'


$(build-dir)/ineq.tex: $(org-dir)/lorenz-table.org
$(build-dir)/lorenz-data.csv: $(org-dir)/lorenz-table.org
$(pdf-dir)/ineq.pdf: $(build-dir)/lorenz-data.csv



## Crate directories
## --------------------------------------------------------------------------------

$(build-dir) $(pdf-dir):
	mkdir $@


## Cleaning rules
## --------------------------------------------------------------------------------
.PHONY: clean
clean:
	-@rm -r $(pdf-dir)

.PHONY: veryclean
veryclean: clean
	-@rm -r $(build-dir)


# Local Variables:
# mode: makefile-gmake
# eval: (flyspell-mode -1)
# End:
