SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules


first: help


build: npm-build  ## Build site

# ------------------------------------------------------------------------------
# Python

image:
	docker build --platform linux/amd64 -t danielfrg/demucs .


run:
	docker run -it --platform linux/amd64 -v $(PWD)/data:/data -v $(PWD)/models:/models danielfrg/demucs


env:
	poetry install


download-model:
	python download.py


# ------------------------------------------------------------------------------
# Build (JS)

npm-build:  ## Build website
	cd $(CURDIR)/js; npm run build
	cd $(CURDIR)/js; npm run export


npm-i: npm-install
npm-install:  ## Install JS dependencies
	cd $(CURDIR)/js; npm install


npm-dev:  ## Run dev server
	cd $(CURDIR)/js; npm run dev


cleanjs:  ## Clean JS files
	rm -rf $(CURDIR)js/out
	rm -rf $(CURDIR)js/.next


cleanalljs: cleanjs  ## Clean JS files
	rm -rf $(CURDIR)js/node_modules
	rm -rf $(CURDIR)js/package-lock.json


# ------------------------------------------------------------------------------
# Other

clean: cleanjs  ## Clean build files


cleanall: cleanalljs  ## Clean everything

.PHONY: models
models:
	mkdir -p models/checkpoints
	# python download.py  # This is not working on Mac M1 - we do it manually
	curl https://dl.fbaipublicfiles.com/demucs/v3.0/demucs_quantized-07afea75.th -o ./models/checkpoints/demucs_quantized-07afea75.th


help:  ## Show this help menu
	@grep -E '^[0-9a-zA-Z_-]+:.*?##.*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?##"; OFS="\t\t"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, ($$2==""?"":$$2)}'
