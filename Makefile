#
# Build instructions
#


# Make sure that any failure in a pipe fails the build
SHELL = /bin/bash -o pipefail


# A list of all test names
TESTS ?= $(notdir $(basename $(wildcard test/*_test.nim)))

# Run all targets
.PHONY: all
all: build/readme_* bin test

# Run all tests
.PHONY: test
test: $(TESTS)

# Build all binaries
.PHONY: bin
bin: $(addprefix build/,$(notdir $(basename $(wildcard bin/*.nim))))


# Compiles a nim file
define COMPILE
nimble c $(FLAGS) \
		--path:. --nimcache:./build/nimcache \
		--out:../build/$(notdir $(basename $1)) \
		--verbosity:0 \
		$1
endef


# A template for defining targets for a test
define DEFINE_TEST

.PHONY: build/$1
build/$1: test/$1.nim $(shell find -name $(patsubst %_test,%,$1).nim)

	$(call COMPILE,test/$1.nim)
	build/$1

.PHONY: $1
$1: build/$1

endef

# Define a target for each test
$(foreach test,$(TESTS),$(eval $(call DEFINE_TEST,$(test))))


# Compile anything in the bin folder
build/%: bin/%.nim
	$(call COMPILE,$<)


# Pulls code snippets out of the readme file and puts them in their own files
define EXTRACT_README_CODE
import ropes, strutils
var blob = rope("")
var within = false
var count = 0
for line in lines("README.md"):
    if line.startsWith("```"):
        if within:
            writeFile("build/readme_" & $$count & ".nim", $$blob)
            inc(count)
            blob = rope("")
        within = not within
    elif within:
        blob.add(line)
        blob.add("\n")
endef
export EXTRACT_README_CODE


# Compiles the code in the readme to make sure it works
build/readme_%: README.md
	@mkdir -p build
	@echo "$$EXTRACT_README_CODE" > build/extract_readme_code.nim
	$(call COMPILE,build/extract_readme_code.nim)
	@build/extract_readme_code
	ls build/readme_*.nim | xargs -n1 nim check --verbosity:0 --path:.


# Watches for changes and reruns
.PHONY: watch
watch:
	$(eval MAKEFLAGS += " -s ")
	@while true; do \
		make $(WATCH) TESTS="$(TESTS)"; \
		inotifywait -qre close_write `find . -name "*.nim"` > /dev/null; \
		echo "Change detected, re-running..."; \
	done


# Executes the compiler with profiling enabled
.PHONY: profile
profile:
	make FLAGS="--profiler:on --stackTrace:on"


# Remove all build artifacts
.PHONY: clean
clean:
	rm -rf build

