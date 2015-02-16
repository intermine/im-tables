# Makefile for intermine-tables
#
# Version 2.0
# Alex Kalderimis
# Mon Feb 16 15:06:08 GMT 2015

dist: $(shell find src -type f) $(shell find templates -type f)
	npm run grunt -- build:dist

run-tests:
	npm test

.PHONY: run-tests
