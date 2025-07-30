# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible Galaxy role (`devopsworks.fluentbit`) that installs and configures Fluent Bit with YAML configuration support. The role follows a minimal approach - it only sets up the service and basic configuration framework, expecting users to provide their own pipeline configurations in `/etc/fluent-bit/conf.d/`.

## Development Commands

### Linting and Quality Checks

- `make lint` - Run all linting checks (ansible-lint, yamllint, markdownlint)
- `make lint-ansible` - Run ansible-lint only
- `make lint-yaml` - Run yamllint only  
- `make lint-markdown` - Run markdownlint only

### Testing

- `make test` - Run full molecule test suite against Ubuntu 24.04, Debian 11, Debian 12
- `molecule test` - Same as above, direct molecule command
- `molecule converge` - Run role without full test cycle (useful for development)
- `molecule verify` - Run verification tests only
- `molecule destroy` - Clean up test instances

### Cleanup

- `make clean` - Clean up molecule artifacts and test instances

## Architecture and Key Patterns

### Role Structure

- **Entry Point**: `tasks/main.yml` uses `include_tasks` pattern with `fluentbit_enabled` conditional
- **Modular Tasks**: Separated into `tasks/install.yml` and `tasks/configure.yml`
- **Configuration**: Uses Jinja2 templates for YAML config and systemd override
- **Service Management**: Handlers in `handlers/main.yml` for service restarts

### Containerized Testing Adaptations

The role includes special handling for container environments using this pattern:

```yaml
ignore_errors: "{{ ansible_virtualization_type == 'podman' or ansible_virtualization_type == 'docker' }}"
```

This appears in systemd-related tasks to handle container limitations where systemd operations may fail.

### Configuration Architecture

- Creates `/etc/fluent-bit/conf.d/` directory for modular pipeline configurations
- Main config `/etc/fluent-bit/fluent-bit.yaml` includes all files from conf.d/
- SystemD service override forces use of YAML config instead of default format

### Suggested Configuration File Naming Convention

- `2x-<name>` - parsers
- `3x-<tag>-<input_name>` - inputs (must be in pipeline blocks)
- `4x-<tag>-<filter_name>` - filters (must be in pipeline blocks)
- `5x_<tag>-<output_name>` - outputs (must be in pipeline blocks)
- `90_` - full pipeline configurations

### Testing Framework

- **Molecule** with **Podman** driver (switched from Docker)
- Tests multiple distributions using Geerling Guy's container images
- Comprehensive verification checks package installation, config files, systemd setup, and file contents
- CI/CD runs matrix testing with Python 3.9, 3.10, 3.11

### Quality Assurance Configuration

- **ansible-lint**: Uses production profile, skips line-length and no-handler rules, allows ignore_errors for containers
- **yamllint**: Extends default with disabled line-length checks
- **markdownlint**: For documentation quality

## Important Variables

### Service Configuration Variables

All variables correspond to Fluent Bit's service section parameters:

- `fluentbit_service_flush` (default: 1)
- `fluentbit_service_daemon` (default: "Off")
- `fluentbit_service_log_level` (default: "info")
- `fluentbit_service_http_server` (default: "off")
- `fluentbit_service_http_listen` (default: "127.0.0.1")
- `fluentbit_service_http_port` (default: 2020)
- `fluentbit_service_storage_metrics` (default: "on")

### Control Variables

- `fluentbit_enabled` (default: true) - Controls whether role executes

## Platform Support

- Ubuntu (all versions)
- Debian (all versions)
- Requires systemd-based systems

## Tags

- `fluentbit` - Run all tasks
- `fluentbit:configure` - Run only configuration tasks
