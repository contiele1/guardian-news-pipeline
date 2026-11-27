#################################################################################
#
# Makefile to build the project
#
#################################################################################

PROJECT_NAME = guardian-news-pipeline
PYTHON_INTERPRETER = python
WD=$(shell pwd)
PYTHONPATH=${WD}
SHELL := /bin/bash
PIP:=pip

.PHONY: create-environment requirements security-test run-black unit-test check-coverage run-tests all bootstrap backend-config tf-init

## Create python interpreter environment.
create-environment:
	@echo ">>> About to create environment: $(PROJECT_NAME)..."
	@echo ">>> check python3 version"
	( \
		$(PYTHON_INTERPRETER) --version; \
	)
	@echo ">>> Setting up VirtualEnv."
	( \
		$(PYTHON_INTERPRETER) -m venv venv \
	)

# Define utility variable to help calling Python from the virtual environment
ACTIVATE_ENV := source venv/bin/activate

# Execute python related functionalities from within the project's environment
define execute_in_env
	$(ACTIVATE_ENV) && $1
endef

## Build the environment requirements
requirements: create-environment
	$(call execute_in_env, $(PIP) install -r ./requirements-dev.txt)
	rm -rf dependencies/python
	$(call execute_in_env, $(PIP) install -r ./requirements.txt -t dependencies/python --platform manylinux2014_x86_64 --implementation cp --python-version 3.12 --only-binary=:all:)

################################################################################
# Tests

## Run the security test (bandit)
security-test:
	$(call execute_in_env, bandit -lll -r src)

## Format the code with black
run-black:
	$(call execute_in_env, black src tests)

## Run the unit tests only (no coverage)
unit-test:
	$(call execute_in_env, PYTHONPATH=${PYTHONPATH} pytest -vv)

## Run the unit tests with a coverage report
check-coverage:
	$(call execute_in_env, PYTHONPATH=${PYTHONPATH} pytest -vv --cov=src tests/)

## Run all checks (tests run once, with coverage)
run-tests: security-test run-black check-coverage

## Build the environment and run all local checks (no AWS needed)
all: requirements run-tests

################################################################################
# Infrastructure (needs AWS credentials)

## One-off: create the Terraform state bucket
bootstrap:
	terraform -chdir=terraform/bootstrap init
	terraform -chdir=terraform/bootstrap apply

## Write terraform/backend.hcl from the bootstrap output
backend-config:
	@BUCKET=$$(terraform -chdir=terraform/bootstrap output -raw state_bucket_name) && \
	echo "bucket = \"$$BUCKET\"" > terraform/backend.hcl && \
	echo "Wrote terraform/backend.hcl (bucket = $$BUCKET)"

## Initialise the main Terraform config against the state bucket
tf-init: backend-config
	terraform -chdir=terraform init -backend-config=backend.hcl

