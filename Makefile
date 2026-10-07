# Partial excerpt image only. Holes are padding, not reconstructed ROM data.
.DEFAULT_GOAL := all
RGBDS ?=
RGBASM ?= $(RGBDS)rgbasm
RGBLINK ?= $(RGBDS)rgblink
PYTHON ?= python3
SOURCES := $(shell rg --files home engine data -g '*.asm' | LC_ALL=C sort)
OBJECTS := $(SOURCES:%.asm=build/%.o)
INCLUDES := includes.asm $(wildcard constants/*.asm ram/*.asm)

.PHONY: all compare
all: build/excerpts.gb

build/%.o: %.asm $(INCLUDES)
	@mkdir -p $(dir $@)
	$(RGBASM) -I . -P includes.asm -o $@ $<

build/excerpts.gb: $(OBJECTS)
	$(RGBLINK) -p 0 -o $@ -m build/excerpts.map -n build/excerpts.sym $(OBJECTS)

# Explicit reference path required; the original remains outside the repository.
compare:
	@test -n "$(REFERENCE_ROM)" || (echo 'Set REFERENCE_ROM to the external original'; exit 1)
	$(PYTHON) tools/check_excerpts.py "$(REFERENCE_ROM)"
