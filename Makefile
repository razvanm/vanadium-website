SHELL := /bin/bash -euo pipefail
PATH := node_modules/.bin:$(PATH)
MDRIP ?= mdrip

.DELETE_ON_ERROR:
.DEFAULT_GOAL := all

#############################################################################
# A note about debugging this Makefile
#
# Due to the way testing is managed there is a somewhat complex set of tasks
# and dependencies which can be hard to get a sense of by looking at the
# definitions in this Makefile. Additionally, targets for creating and testing
# shell scripts from tutorial content can take a while to run. Some tips are
# below to help anyone who might need to make edits or additions.
#
# Run a task with make's debug output. This will show information about the
# target being run as well as it's prerequisites and whether make will rebuild
# the target.
#
#     make <target> --debug
#
# Force the target and all prerequisites to build regardless of mtimes:
#
#     make <target> --always-make
#
# Do a dry run, this will spit out what will happen without actually building
# the targets. This is probably helpful for creating new targets with
# complex and/or slow prerequisites.
#
#     make <target> --dry-run
#

#############################################################################
# Tooling and infrastructure

# Find nodejs and add it to PATH.
NODE_BIN ?= /usr/local/bin
export PATH := $(NODE_BIN):$(PATH)

# Note, we run npm using 'node npm' to avoid relying
# on the shebang line in the npm script, which can exceed the Linux shebang
# length limit on Jenkins.
npm := node $(NODE_BIN)/npm

#############################################################################
# Variables, functions, and helpers
TMPDIR := $(shell mktemp -d "$${TMPDIR:-/tmp}/XXXXXX")
HEAD := $(shell git rev-parse HEAD)

bundles := public/css public/js/bundle.js
haiku_inputs := $(shell find public/* content/* templates/*)

# A list of case-sensitive banned words.
BANNED_WORDS := Javascript node.js Oauth
.PHONY: banned_words
banned_words:
	@for WORD in $(BANNED_WORDS); do \
		if [ -n '`grep -rn "$$WORD" content templates`' ]; then \
		  echo '`grep -rn "$$WORD" content templates`'; \
		  echo "Found banned word (case-sensitive): $$WORD"; \
		  exit 1; \
		fi \
	done

define BROWSERIFY
	@mkdir -p $(dir $2)
	browserify $1 -d -o $2
endef

#############################################################################
# Variables, functions, and helpers
#
# It's important these are defined above any targets that may depend on them.

install_md = installation/step-by-step.md
install_sh = public/sh/vanadium-install.sh

tutSetup       = tutorials/setup
tutCheckup     = tutorials/checkup
tutCleanup     = tutorials/cleanup
tutWipeSlate   = tutorials/wipe-slate
tutHello       = tutorials/hello-world
tutBasics      = tutorials/basics
tutPrincipals  = tutorials/security/principals-and-blessings
tutPermsAuth   = tutorials/security/permissions-authorizer
tutCaveats1st  = tutorials/security/first-party-caveats
tutCaveats3rd  = tutorials/security/third-party-caveats
tutAgent       = tutorials/security/agent
tutCustomAuth  = tutorials/security/custom-authorizer
tutMountTable  = tutorials/naming/mount-table
tutNamespace   = tutorials/naming/namespace
tutSuffixPart1 = tutorials/naming/suffix-part1
tutSuffixPart2 = tutorials/naming/suffix-part2
tutGlobber     = tutorials/naming/globber
tutJavaAndroid = tutorials/java/android
tutJavaFortune = tutorials/java/fortune

# Scripts that 'complete' the named tutorials, creating all relevant files
# (code, credentials, etc.) but skipping ephemeral steps like starting servers,
# running clients, etc. Such scripts need exist only for tutorials that create
# such files.
completer = public/sh/tut-completer
completerScripts = \
	$(completer)-hello-world.sh \
	$(completer)-basics.sh \
	$(completer)-permissions-authorizer.sh \
	$(completer)-custom-authorizer.sh \
	$(completer)-suffix-part1.sh \
	$(completer)-suffix-part2.sh \
	$(completer)-globber.sh

# Opaquely named copies of particular completer scripts, used to set up
# conditions for later tutorials. See individual targets for more explanation.
scenario = public/sh/scenario
setupScripts = \
	$(install_sh) \
	$(scenario)-a-setup.sh \
	$(scenario)-b-setup.sh \
	$(scenario)-c-setup.sh \
	$(scenario)-d-setup.sh \
	$(scenario)-e-setup.sh \
	$(scenario)-f-setup.sh

depsCommon = \
	content/$(tutSetup).md \
	content/$(tutCheckup).md \
	content/$(tutWipeSlate).md

scripts := $(completerScripts) $(setupScripts)

#############################################################################
# Target definitions

# Silence error output "make: `build' is up to date." for tools like watch by
# adding @true.
.PHONY: all
all: build
	@true

node_modules: package.json
	$(npm) prune
	$(npm) install
	touch $@

# NOTE(sadovsky): Some files under public/{css,js} were copied over from the
# node_modules directory as follows:
# cp node_modules/highlight.js/styles/github.css public/css
# cp node_modules/material-design-lite/material*css* public/css
# cp node_modules/material-design-lite/material*js* public/js

# NOTE(sadovsky): Newer versions of postcss-cli and autoprefixer use JavaScript
# Promises, which doesn't work with Vanadium's old version of node, 0.10.24.

# Generates a compiled css file for every less file in the themes directory.
public/css: $(shell find stylesheets/*) node_modules
	@for FILE in $(shell find stylesheets/themes/* -type f -print0 | xargs -0 -n1 basename) ; do \
		lessc -sm=on stylesheets/themes/$$FILE | postcss -u autoprefixer > $@/bundle.$${FILE%.*}.css ; \
	done
	touch $@

public/js/bundle.js: browser/index.js $(shell find browser) node_modules
	$(call BROWSERIFY,$<,$@)

build: $(bundles) $(scripts) $(haiku_inputs) node_modules
	haiku build --helpers helpers.js --build-dir $@
	@touch $@

################################################################################
# Task definitions, targets without build artifacts.

.PHONY: serve
serve: build
	@static build -H '{"Cache-Control": "no-cache, must-revalidate"}'

# 'entr' can be installed on Debian/Ubuntu using 'apt-get install entr', and on
# OS X using 'brew install entr'.
.PHONY: watch
watch: browser/ content/ public/ stylesheets/ templates/
	@echo "Watching for changes in $^"
	@find $^ | entr $(MAKE) build

################################################################################
# Note: deploy target is automatically triggered by Jenkins by the
# 'vanadium-website-deploy' job after each successful build of the
# 'vanadium-website-site' job.
# If there are any changes, it commits and pushes to the vanadium.github.io
# repository, which is served by GitHub pages.
.PHONY: deploy
deploy: clean build
	git clone git@github.com:vanadium/vanadium.github.io.git $(TMPDIR)
	rm -rf $(TMPDIR)/*
	rsync -r build/* $(TMPDIR)
	cd $(TMPDIR) && \
	git add -A && \
	git diff-index --quiet HEAD || \
	git commit -m "pull $(HEAD)" && \
	git push

.PHONY: clean
clean:
	rm -rf build node_modules public/**/bundle.* public/sh public/tutorials

.PHONY: lint banned_words
lint: banned_words node_modules
	jshint .

################################################################################
# Tutorial script generation and tests

# Vanadium install script.
# This can be run as a prerequisite for tutorial setup.
$(install_sh): content/$(install_md)
	mkdir -p $(@D)
	$(MDRIP) --preambled 3 test $^ > $@

# Targets of the form $(scenario)-{x}-setup.sh create scripts that are meant to
# be run by a user as an argument to 'source', so that they modify the user's
# active environment. They are prerequisite to particular tutorials.
#
# Each script has two sections: a preamble that should run error-free, setting
# env vars and defining shell functions, and a general section that runs as a
# subshell, capable of exiting on error. Error exits from a subshell won't close
# the terminal that issued the 'source' command.
#
# The preamble section is generated from the contents of the first filename
# argument to "$(MDRIP) --preambled". The remaining arguments define the
# subshell code. Code to verify setup and exit if something went wrong should
# appear in the subshell, not in the preamble.
$(scenario)-a-setup.sh: \
	content/$(tutSetup).md \
	content/$(tutCheckup).md
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@

# Targets of the from test-{tutorial-name} are meant for interactive use to test
# an individual tutorial and/or extract the code associated with said tutorial.
# The code winds up in $V_TUT/src, where $V_TUT is defined in tutSetup.

depsHello = $(depsCommon) content/$(tutHello).md
.PHONY: test-hello-world
test-hello-world: $(depsHello)
	$(MDRIP) --subshell test $^
$(completer)-hello-world.sh: $(depsHello)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@

depsBasics = $(depsCommon) content/$(tutBasics).md
.PHONY: test-basics
test-basics: $(depsBasics)
	$(MDRIP) --subshell test $^
$(completer)-basics.sh: $(depsBasics)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@
$(scenario)-b-setup.sh: $(completer)-basics.sh
	cp $^ $@

depsPrincipals = $(depsBasics) content/$(tutPrincipals).md
.PHONY: test-principals
test-principals: $(depsPrincipals)
	$(MDRIP) --subshell test $^
$(scenario)-c-setup.sh: $(depsPrincipals)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@

depsPermsAuth = $(depsPrincipals) content/$(tutPermsAuth).md
.PHONY: test-permissions-authorizer
test-permissions-authorizer: $(depsPermsAuth)
	$(MDRIP) --subshell test $^
$(completer)-permissions-authorizer.sh: $(depsPermsAuth)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@
$(scenario)-d-setup.sh: $(completer)-permissions-authorizer.sh
	cp $^ $@

depsMultiDisp = $(depsPermsAuth) content/$(tutSuffixPart1).md
.PHONY: test-multiservice-dispatcher
test-multiservice-dispatcher: $(depsMultiDisp)
	$(MDRIP) --subshell test $^
$(completer)-multiservice-dispatcher.sh: $(depsMultiDisp)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@
$(scenario)-e-setup.sh: $(completer)-multiservice-dispatcher.sh
	cp $^ $@

depsCaveats1st = $(depsPermsAuth) content/$(tutCaveats1st).md
.PHONY: test-caveats-1st
test-caveats-1st: $(depsCaveats1st)
	$(MDRIP) --subshell test $^

depsCaveats3rd = $(depsPermsAuth) content/$(tutCaveats3rd).md
.PHONY: test-caveats-3rd
test-caveats-3rd: $(depsCaveats3rd)
	$(MDRIP) --subshell test $^

depsAgent = $(depsPermsAuth) content/$(tutAgent).md
.PHONY: test-agent
test-agent: $(depsAgent)
	$(MDRIP) --subshell test $^

depsCustomAuth = $(depsPermsAuth) content/$(tutCustomAuth).md
.PHONY: test-custom-auth
test-custom-auth: $(depsCustomAuth)
	$(MDRIP) --subshell test $^
$(completer)-custom-authorizer.sh: $(depsCustomAuth)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@

depsMountTable = $(depsBasics) content/$(tutMountTable).md
.PHONY: test-mount-table
test-mount-table: $(depsMountTable)
	$(MDRIP) --subshell test $^

depsNamespace = $(depsBasics) content/$(tutNamespace).md
.PHONY: test-namespace
test-namespace: $(depsNamespace)
	$(MDRIP) --subshell test $^

depsSuffixPart1 = $(depsBasics) content/$(tutSuffixPart1).md
.PHONY: test-suffix-part1
test-suffix-part1: $(depsSuffixPart1)
	$(MDRIP) --subshell test $^
$(completer)-suffix-part1.sh: $(depsSuffixPart1)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@

depsSuffixPart2 = $(depsMultiDisp) content/$(tutSuffixPart2).md
.PHONY: test-suffix-part2
test-suffix-part2: $(depsSuffixPart2)
	$(MDRIP) --subshell test $^
$(completer)-suffix-part2.sh: $(depsSuffixPart2)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@

depsGlobber = $(depsMultiDisp) content/$(tutGlobber).md
.PHONY: test-globber
test-globber: $(depsGlobber)
	$(MDRIP) --subshell test $^
$(completer)-globber.sh: $(depsGlobber)
	mkdir -p $(@D)
	$(MDRIP) --preambled 0 completer $^ > $@

# An ordering that lets us test all the tutorials faster than running the
# individual tests in sequence. This exploits the knowledge that, for example,
# tutCaveats3rd can be tested right after tutCaveats1st without reseting to a
# clean slate. WipeSlate and Basics are done where needed to reset state.
depsOneBigCoreTutorialTest = \
	content/$(tutSetup).md \
	content/$(tutCheckup).md \
	content/$(tutWipeSlate).md \
	content/$(tutHello).md \
	content/$(tutBasics).md \
	content/$(tutPrincipals).md \
	content/$(tutPermsAuth).md \
	content/$(tutCaveats1st).md \
	content/$(tutCaveats3rd).md \
	content/$(tutAgent).md \
	content/$(tutCustomAuth).md \
	content/$(tutWipeSlate).md \
	content/$(tutBasics).md \
	content/$(tutMountTable).md \
	content/$(tutNamespace).md \
	content/$(tutWipeSlate).md \
	content/$(tutBasics).md \
	content/$(tutPrincipals).md \
	content/$(tutPermsAuth).md \
	content/$(tutSuffixPart1).md \
	content/$(tutSuffixPart2).md \
	content/$(tutWipeSlate).md \
	content/$(tutBasics).md \


.PHONY: test
test: test-site

.PHONY: test-site
test-site: build node_modules
	tape test/test-*.js
