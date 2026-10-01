SHELL := /bin/bash

.PHONY: docs-build docs-serve docs-up docs-down docs-clean test-coverage test-matrix test-live-matrix test-logs-clean

docs-build:
	$(MAKE) -C ./docs docs-build

docs-serve:
	$(MAKE) -C ./docs docs-serve

docs-up:
	$(MAKE) -C ./docs docs-up

docs-down:
	$(MAKE) -C ./docs docs-down

docs-clean:
	$(MAKE) -C ./docs docs-clean

test-matrix:
	$(MAKE) -C ./tests test-matrix

test-coverage:
	$(MAKE) -C ./tests test-coverage

test-live-matrix:
	$(MAKE) -C ./tests test-live-matrix

test-logs-clean:
	$(MAKE) -C ./tests test-logs-clean
