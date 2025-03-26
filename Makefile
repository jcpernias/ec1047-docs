SHELL := /bin/sh

## Source files
## ================================================================================

org-files := \
	ineq/ineq.org

# note: sort function remove duplicates
src-dirs := $(sort $(dir $(org-files)))

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
org-to-pdf := --eval "(org-latex-export-to-pdf)"
org-to-latex := --eval "(org-latex-export-to-latex)"


LATEXMK_FLAGS := -lualatex -recorder -emulate-aux-dir

LATEX_MESSAGES := no
ifneq ($(LATEX_MESSAGES), yes)
LATEXMK_FLAGS += -quiet
endif

LATEXMK := $(latexmkbin) $(LATEXMK_FLAGS)

tex-files := $(patsubst %.org,%.tex,$(org-files))
pdf-files := $(patsubst %.org,%.pdf,$(org-files))

build-dirs := $(join $(dir $(org-files)),build)

VPATH := $(src-dirs)


all: $(pdf-files)

.PRECIOUS: %.tex
%.tex: %.org setup.org setup-emacs.el
	$(EMACS) --load=./setup-emacs.el --visit=$< $(org-to-latex)

.PRECIOUS: %.pdf
%.pdf: %.tex preamble.tex
	$(LATEXMK) -aux-directory=$(dir $<)/build -output-directory=$(dir $<) $<



## Cleaning rules
## --------------------------------------------------------------------------------
.PHONY: clean
clean:
	-@rm $(pdf-files)
	-@rm $(tex-files)

.PHONY: veryclean
veryclean: clean
	-@rm -r $(build-dirs)
