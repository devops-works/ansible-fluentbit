.PHONY: lint test clean help

# Default target
help:
	@echo "Available targets:"
	@echo "  lint     - Run all linting checks (ansible-lint, yamllint, markdownlint)"
	@echo "  test     - Run molecule test suite"
	@echo "  clean    - Clean up molecule artifacts"
	@echo "  help     - Show this help message"

# Linting targets
lint: lint-ansible lint-yaml lint-markdown

lint-ansible:
	@echo "Running ansible-lint..."
	ansible-lint .

lint-yaml:
	@echo "Running yamllint..."
	yamllint .

lint-markdown:
	@echo "Running markdownlint..."
	@if command -v markdownlint >/dev/null 2>&1; then \
		markdownlint *.md; \
	else \
		echo "markdownlint not found. Install with: npm install -g markdownlint-cli"; \
		exit 1; \
	fi

# Testing target
test:
	@echo "Running molecule test..."
	molecule test

# Cleanup target
clean:
	@echo "Cleaning up molecule artifacts..."
	molecule destroy || true
	rm -rf .molecule/ || true