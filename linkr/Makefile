.PHONY: venv
venv:
	python3	-m venv .venv

.PHONY: dev
dev: .venv
	.venv/bin/pip install -e '.[dev]'

dist: $(SRC_DIR)/**/* pyproject.toml
	.venv/bin/python -m build

.PHONY: build
build: clean dev dist

.PHONY: test
test:
	.venv/bin/pytest

.PHONY: test-cov
test-cov:
	.venv/bin/pytest --cov=hqd tests/

.PHONY: lint
lint:
	.venv/bin/ruff check .

.PHONY: lint-fix
lint-fix:
	.venv/bin/ruff check --fix . 

.PHONY: format
format:
	.venv/bin/ruff format .

.PHONY: clean
clean:
	@rm -rf dist
	@rm -rf hq.egg-info

.PHONY: ci
ci: build lint test-cov
