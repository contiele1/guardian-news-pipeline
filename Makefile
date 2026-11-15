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
PROFILE = default
PIP:=pip

## Create python interpreter environment.
create-environment:
	@echo ">>> About to create environment: $(PROJECT_NAME)..."
	@echo ">>> check python3 version"
	( \
		$(PYTHON_INTERPRETER) --version; \
	)
	@echo ">>> Setting up VirtualEnv."
	( \
	    python -m venv venv \
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
	$(call execute_in_env, $(PIP) install -r ./requirements.txt -t dependencies/python)

################################################################################################################

# Tests

## Run the security test (bandit)
security-test:
	$(call execute_in_env, bandit -lll */*.py)
	
## Run the black code check
run-black:
	$(call execute_in_env, black  ./src/*.py ./tests/*.py)

## Run the unit tests
unit-test:
	$(call execute_in_env, PYTHONPATH=${PYTHONPATH} pytest -vv)

## Run the coverage check
check-coverage:
	$(call execute_in_env, PYTHONPATH=${PYTHONPATH} pytest --cov=src tests/)

## Run all checks
run-tests: security-test run-black unit-test check-coverage

all: requirements run-tests
