# Complete matching build from explicit source. Uninterpreted regions remain marked.
.DEFAULT_GOAL := all
RGBDS ?=
RGBASM ?= $(RGBDS)rgbasm
RGBLINK ?= $(RGBDS)rgblink
PYTHON ?= python3
SOURCES := $(shell rg --files home engine data -g '*.asm' | LC_ALL=C sort)
OBJECTS := $(SOURCES:%.asm=build/%.o)
INCLUDES := includes.asm $(wildcard constants/*.asm ram/*.asm)

.PHONY: all compare sym-check test verify private-check storage-probe private-storage-check
ROM := build/net-de-get.gbc
all: $(ROM)

build/%.o: %.asm $(INCLUDES)
	@mkdir -p $(dir $@)
	$(RGBASM) -I . -P includes.asm -o $@ $<

build/excerpts.gb: $(OBJECTS)
	$(RGBLINK) -p 0 -o $@ -m build/excerpts.map -n build/excerpts.sym $(OBJECTS)

# The matching image is assembled without the original ROM, then hash-checked.
$(ROM): build/excerpts.gb config/excerpts.tsv roms.sha256 tools/check_full.py tools/full_checks.py tools/excerpt_checks.py
	$(PYTHON) tools/check_full.py --verify-build
	cp $< $@

# Explicit reference path required; the original remains outside the repository.
compare:
	@test -n "$(REFERENCE_ROM)" || (echo 'Set REFERENCE_ROM to the external original'; exit 1)
	$(PYTHON) tools/check_excerpts.py "$(REFERENCE_ROM)"

# Run these gates for each coherent source change before publishing.
sym-check: build/excerpts.gb
	$(PYTHON) tools/check_symbols.py build/excerpts.map build/excerpts.sym

test:
	$(PYTHON) -m unittest discover -s tools -p 'test_*.py' -v

verify: all sym-check test compare full-compare

private-check: all
	@test -n "$(REFERENCE_ROM)" || (echo 'Set REFERENCE_ROM to the external original'; exit 1)
	$(PYTHON) tools/check_private.py "$(REFERENCE_ROM)"

# Optional original-code CPU probes, explicitly SYNTHETIC and fixture-only.
storage-probe:
	@test -n "$(REFERENCE_ROM)" -a -n "$(MGBA_SOURCE)" -a -n "$(MGBA_BUILD)" || (echo 'Set REFERENCE_ROM, MGBA_SOURCE and MGBA_BUILD'; exit 1)
	$(PYTHON) fixtures/local-storage/run.py "$(REFERENCE_ROM)" "$(MGBA_SOURCE)" "$(MGBA_BUILD)"

private-storage-check: all
	@test -n "$(REFERENCE_ROM)" -a -n "$(MGBA_SOURCE)" -a -n "$(MGBA_BUILD)" || (echo 'Set REFERENCE_ROM, MGBA_SOURCE and MGBA_BUILD'; exit 1)
	$(PYTHON) tools/check_private.py "$(REFERENCE_ROM)" --mgba-source "$(MGBA_SOURCE)" --mgba-build "$(MGBA_BUILD)"

# Reject incomplete coverage even when linker padding happens to match.
.PHONY: coverage full-compare verify-full
coverage:
	$(PYTHON) tools/check_full.py

full-compare: all sym-check
	@test -n "$(REFERENCE_ROM)" || (echo 'Set REFERENCE_ROM to the external original'; exit 1)
	$(PYTHON) tools/check_full.py "$(REFERENCE_ROM)"

verify-full: verify full-compare

.PHONY: full-negative-check
full-negative-check:
	$(PYTHON) tools/check_full_negative.py
