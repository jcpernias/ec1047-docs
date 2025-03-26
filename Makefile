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

-include local.mk

## Variables
## ================================================================================
EMACS := $(emacsbin) -Q -nw --batch
org-to-pdf := --eval "(org-latex-export-to-pdf)"
org-to-latex := --eval "(org-latex-export-to-latex)"

LATEX_MESSAGES := no
TEXI2DVI_FLAGS := --batch --pdf --build=tidy

ifneq ($(LATEX_MESSAGES), yes)
TEXI2DVI_FLAGS += -q
endif

TEXI2DVI := $(envbin) TEXINPUT=. TEXI2DVI_USE_RECORDER=yes \
	$(texi2dvibin) $(TEXI2DVI_FLAGS)


tex-files := $(patsubst %.org,%.tex,$(org-files))
pdf-files := $(patsubst %.org,%.pdf,$(org-files))

build-dirs := $(join $(dir $(org-files)),\
	$(foreach dir,$(src-dirs),$(dir)!$(call bare-name,$(dir))-instr.t2d))


build-dirs := $(join $(dir $(org-files)),\
	$(foreach file,$(patsubst %.org,%.t2d,$(org-files)),$(subst /,!,$(file))))

VPATH := $(src-dirs)


all: $(pdf-files)

.PRECIOUS: %.tex
%.tex: %.org setup.org setup-emacs.el
	$(EMACS) --load=./setup-emacs.el --visit=$< $(org-to-latex)

.PRECIOUS: %.pdf
%.pdf: %.tex
	$(TEXI2DVI) --build-dir=$(@D) --output=$@ $<



## Cleaning rules
## --------------------------------------------------------------------------------
.PHONY: clean
clean:
	-@rm $(pdf-files)
	-@rm $(tex-files)

.PHONY: veryclean
veryclean: clean
	-@rm -r $(build-dirs)
