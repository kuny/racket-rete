#--------------------------------------------------
# Project:
# Purpose:
#--------------------------------------------------

.PHONY: all build run test

all: build

build:
	@raco exe main.rkt

run:
	@racket main.rkt

test:
	@raco test main.rkt
