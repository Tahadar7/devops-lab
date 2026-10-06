SRC_DIR := src
OUT_DIR := out
SOURCES := $(wildcard $(SRC_DIR)/*.txt)
OUTPUTS := $(patsubst $(SRC_DIR)/%.txt,$(OUT_DIR)/%.txt,$(SOURCES))

.PHONY: all check build test clean ci

all: test

check:
	@if [ ! -d "$(SRC_DIR)" ]; then \
		echo "ERROR: source directory '$(SRC_DIR)' not found"; \
		exit 1; \
	fi
	@if [ -z "$(strip $(SOURCES))" ]; then \
		echo "ERROR: no .txt files found in $(SRC_DIR)"; \
		exit 2; \
	fi
	@echo "CHECK PASSED: $(words $(SOURCES)) source files found"

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(OUT_DIR)/%.txt: $(SRC_DIR)/%.txt | $(OUT_DIR)
	@echo "BUILD $< -> $@"
	@tr '[:lower:]' '[:upper:]' < $< > $@

build: $(OUTPUTS)

test: build
	@if grep -l '[a-z]' $(OUTPUTS) >/dev/null 2>&1; then \
		echo "TEST FAILED: lowercase characters remain"; \
		exit 2; \
	fi
	@echo "TEST PASSED"

clean:
	rm -rf $(OUT_DIR)

ci: clean check test
count: build ## report source files and built words
	@ls -1 $(SRC_DIR)/*.txt | wc -l
	@wc -w $(OUTPUTS) | tail -1
# count: see section 5 of the README
# OUTPUTS is set by the wildcard above
# run 'make help' for all targets
