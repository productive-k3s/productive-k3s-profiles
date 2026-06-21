SHELL := /bin/bash

.PHONY: docs-build docs-serve test-matrix test-live-matrix

docs-build:
	$(MAKE) -C ./docs docs-build

docs-serve:
	$(MAKE) -C ./docs docs-serve

test-matrix:
	$(MAKE) -C ./tests test-matrix

test-live-matrix:
	$(MAKE) -C ./tests test-live-matrix
