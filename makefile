#!/usr/bin/make

# M3TIOR 2017
#
#

# NOTE: make sure I can use for loops...
#	for (( l=0; l <= [number]; l++ )); do
#		...
#	done;
#
SHELL := /bin/bash

# NOTE:
#	Because some essential variables exist, I need a facility to make
#	them more prominent than standard variables. so (very complex much wow)
#	I'm just making all of them UPPERCASE horray right! so easy to read!
#	also it's less likely you'll accidentally name a variable like it since
#	most people don't like to type with caps-lock on.
#

# NOTE: PATH AND FILE REFFERENCES
override FILE_RELATIVE := $(lastword $(MAKEFILE_LIST))
override FILE_ABSOLUTE := $(abspath $(FILE_RELATIVE))
override FILE := $(lastword $(subst /,$(SPACE),$(FILE_RELATIVE)))
override PATH_RELATIVE := $(subst $(FILE),,$(FILE_RELATIVE))
override PATH_ABSOLUTE := $(FILE_ABSOLUTE:/$(FILE)=$(EMPTY))

# XXX: META-characters
override COMMA := ,
override EMPTY :=
override SPACE := $(EMPTY) $(EMPTY)
override define NEWLINE :=


endef
#
# XXX: this must have two lines to function properly!!!
#

# NOTE: just in case we want the option to install things
prefix 			?= /usr/local
exec_prefix 	?= $(prefix)
bindir 			?= $(exec_prefix)/bin
sbindir			?= $(exec_prefix)/sbin
libexecdir		?= $(exec_prefix)/libexec
datarootdir		?= $(prefix)/share
datadir			?= $(datarootdir)
sysconfdir		?= $(prefix)/etc
sharedstatedir	?= $(prefix)/com
localstatedir	?= $(prefix)/var
runstatedir		?= $(localstatedir)/run
includedir		?= $(prefix)/include
oldincludedir	?= /usr/include
docdir			?= $(datarootdir)/doc/$(1)
infodir			?= $(datarootdir)/info
htmldir			?= $(docdir)
dvidir			?= $(docdir)
pdfdir			?= $(docdir)
psdir			?= $(docdir)
libdir 			?= $(exec_prefix)/lib
lispdir			?= $(datarootdir)/emacs/site-lisp
localedir 		?= $(datarootdir)/locale
mandir			?= $(datarootdir)/man
srcdir			?= $(PATH_ABSOLUTE)
uninstallerdir	?= $(sysconfdir)/m3tior/uninstall

# as the default, make only builds the projects
# XXX: borked, seriously this syntax is killer...
#		for some reason this won't work if you add whitespace before
#		a comment. I'm assuming what's happening is the variable is being
#		saved with the trailing whitespace... It should trim... ugh...
export mode ?= build

rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))
files := $(call rwildcard, $(PATH_ABSOLUTE)/*, /*.rs)
targets := $(foreach file,$(files),$(basename $(lastword $(subst /, ,$(file)))))
len = $(shell N=0; for each in $(1); do N=$$((N+1)); done; echo $$N;)
arrval = $(shell set -- $(1); eval echo `printf "%s%s" $$ $(2)`;)
index = $(shell for (( l=1; l <= $(call len,$(1)); l++ )); do printf "$$l "; done;)
post = $()

$(shell cat $(PATH_ABSOLUTE)/res/baseconfig.toml > $(PATH_ABSOLUTE)/Cargo.toml)

# Phony targets don't output files
.PHONY: $(targets) post all clean list help
#----------------------------------------------------------------------
config = echo "$(1)" >> $(PATH_ABSOLUTE)/Cargo.toml;
sconfig = echo \"$(1)\" >> $(PATH_ABSOLUTE)/Cargo.toml;

$(foreach l, $(call index,$(files)),$(eval $(call arrval,$(targets),$(l)): ;\
	$(call config,[[bin]])\
	$(call config,name=\"$(call arrval,$(targets),$(l))\")\
	$(call config,path=\"$(call arrval,$(files),$(l))\")\
	cargo build;\
	rm $(PATH_ABSOLUTE)/Cargo.toml;\
))

help: list ;
	@ echo "To build individual packages:"
	@ echo "\t'make <package> <package2> ...'"
	@ echo "or, to build everything:"
	@ echo "\tmake all"


list: ;
	@ echo "The current packages available for install in this repository are..."
	@ for package in $(preload_packages); do\
		P=$${package%.mk}; echo "\t$${P##*/}";\
	done;

all: $(targets) post; @ # Build Everything

clean:
	@ rm -vrf $(PATH_ABSOLUTE)/target
	@ rm -vrf $(PATH_ABSOLUTE)/Cargo.toml
	@ rm -vrf $(PATH_ABSOLUTE)/Cargo.lock
	@ echo "Clean!"
