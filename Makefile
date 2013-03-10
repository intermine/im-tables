# Makefile for intermine-tables
#
# Version 1.0
# Alex Kalderimis
# Fri Feb 15 13:21:32 GMT 2013

export PATH := $(PATH):$(shell find node_modules -name 'bin' -printf %p:)node_modules/.bin

deps:
	npm install

deploy: deps
	chernobyl deploy labs.intermine.org .

test:
	@echo No Tests!

.PHONY: test
