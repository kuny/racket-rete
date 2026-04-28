#--------------------------------------------------
# Project:
# Purpose:
#--------------------------------------------------

.PHONY: all run test build

all: build

build:
	@raco exe main.rkt

run:
	@racket main.rkt

test:
	@raco test main.rkt
