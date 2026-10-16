# FAIR Data Train specifications — built with Bikeshed.
#
# The sources are the .bs files; the .html beside each one is the built page and is committed too,
# because GitHub Pages serves this repository's root as it is (legacy build, branch main, path /).
# `make check` fails when a committed page is out of date with its source, and CI runs it.
#
# Bikeshed is pinned: its output is deterministic for one version and not across versions, and the
# check above compares bytes. Python 3.12 is pinned because Bikeshed 7.x does not run on 3.14.

BIKESHED ?= .venv/bin/bikeshed
BIKESHED_VERSION := 7.2.0
PYTHON_VERSION := 3.12

# The local .venv is created on demand. When BIKESHED names another executable (CI passes
# BIKESHED=bikeshed after pip-installing it), nothing here has to be built first — an order-only
# prerequisite on a bare command name would make make look for a file by that name and, not
# finding one, try to create the venv with uv on a runner that has no uv.
VENV_BIKESHED := .venv/bin/bikeshed
ifeq ($(BIKESHED),$(VENV_BIKESHED))
  BIKESHED_DEP := $(VENV_BIKESHED)
else
  BIKESHED_DEP :=
endif

SPECS := index.bs v0.1/index.bs visit-protocol/index.bs
HTML  := $(SPECS:.bs=.html)
BOILERPLATE := $(wildcard boilerplate/*.include)

.PHONY: all check clean venv update watch sync-fixtures help

all: $(HTML)  ## build every specification

# --allow-nonlocal-files: v0.1/ refers to the shared ../images/, which Bikeshed otherwise refuses
# to read from outside the source document's directory.
%.html: %.bs $(BOILERPLATE) | $(BIKESHED_DEP)
	$(BIKESHED) --die-on=link-error --allow-nonlocal-files spec $< $@

check: all  ## fail if any built page differs from what is committed
	@git diff --exit-code --stat -- '*.html' && echo "built pages are up to date"

venv: $(VENV_BIKESHED)  ## create the pinned build environment

$(VENV_BIKESHED):
	uv venv --python $(PYTHON_VERSION) .venv
	uv pip install --python .venv/bin/python 'bikeshed==$(BIKESHED_VERSION)'
	.venv/bin/bikeshed update

update: | $(BIKESHED_DEP)  ## refresh Bikeshed's reference data (needs network)
	$(BIKESHED) update

watch: | $(BIKESHED_DEP)  ## rebuild the protocol spec on every save
	$(BIKESHED) watch visit-protocol/index.bs visit-protocol/index.html

# The examples in visit-protocol/examples/ are the published fixtures of fdt-commons, copied
# verbatim so the specification shows documents that its own validators have checked, never
# ones typed into prose. FDT-COMMONS-COMMIT records which commit they came from.
FDT_COMMONS ?= ../FAIRDataTrain/ReferenceImplementation/fdt-commons
FIXTURES := visit-descriptor-gd-m1 visit-descriptor-ttg-hop3 visit-events-gd-m1 visit-events-gd-m1-poll \
            visit-events-gd-m1-refused visit-events-gd-m1-failed visit-result-gd-m1 visit-result-gd-m1-refused \
            poll-countersign-ask-gd-m1 poll-countersign-answer-gd-m1
sync-fixtures:  ## copy the protocol fixtures from a local fdt-commons checkout and record its commit
	@for f in $(FIXTURES); do cp "$(FDT_COMMONS)/examples/protocol/$$f.json" visit-protocol/examples/; done
	@git -C "$(FDT_COMMONS)" rev-parse HEAD > visit-protocol/examples/FDT-COMMONS-COMMIT
	@echo "fixtures synced from fdt-commons $$(cat visit-protocol/examples/FDT-COMMONS-COMMIT | cut -c1-12)"

clean:  ## remove the build environment (the built pages stay: they are what is served)
	rm -rf .venv

help:  ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  %-16s %s\n", $$1, $$2}'
