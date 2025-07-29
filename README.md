# Ansible Role: Fluent Bit

An Ansible role for installing and configuring Fluent Bit, a fast and flexible
log processor and forwarder.

## Description

This role installs Fluent Bit from the official repository and configures it to
use YAML configuration files instead of the default configuration format. It
sets up a systemd service override to use the YAML configuration file and
provides configurable service parameters.

The role does not configure any inputs, parsers, outputs, ... it only sets up the
service and allows you to manage the Fluent Bit service using Ansible.

You need to provide your own configuration files in the
`/etc/fluent-bit/conf.d/`. The suggested layout is described in the
[Suggested Layout](#suggested-layout) section below.

## Requirements

- Ansible >= 2.1
- Supported platforms:
  - Ubuntu (all versions)
  - Debian (all versions)
- systemd-based systems
- Internet connectivity for package installation

## Role Variables

### Main Configuration

| Variable            | Type    | Default | Description                                     |
| ------------------- | ------- | ------- | ----------------------------------------------- |
| `fluentbit_enabled` | boolean | `true`  | Enable or disable the Fluent Bit role execution |

### Service Configuration

All service configuration variables correspond to Fluent Bit's
[service section parameters](https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/yaml/service-section).

| Variable                            | Type    | Default       | Description                                                                                  |
| ----------------------------------- | ------- | ------------- | -------------------------------------------------------------------------------------------- |
| `fluentbit_service_flush`           | integer | `1`           | Set the flush time in seconds. Collector always tries to flush the records every time period |
| `fluentbit_service_daemon`          | string  | `"Off"`       | Run Fluent Bit as a daemon. Allowed values: On, Off                                          |
| `fluentbit_service_log_level`       | string  | `"info"`      | Set the logging verbosity level. Allowed values: off, error, warn, info, debug, trace        |
| `fluentbit_service_http_server`     | string  | `"off"`       | Enable HTTP server for monitoring and metrics. Allowed values: on, off                       |
| `fluentbit_service_http_listen`     | string  | `"127.0.0.1"` | Set listening interface for HTTP server when enabled                                         |
| `fluentbit_service_http_port`       | integer | `2020`        | Set TCP port for the HTTP server when enabled                                                |
| `fluentbit_service_storage_metrics` | string  | `"on"`        | Enable storage layer metrics. Allowed values: on, off                                        |

## Dependencies

None.

## Example Playbook

### Basic usage with default settings

```yaml
- hosts: servers
  become: yes
  roles:
    - devopsworks.fluentbit
```

### Custom configuration

```yaml
- hosts: servers
  become: yes
  vars:
    fluentbit_service_log_level: "debug"
    fluentbit_service_http_server: "on"
    fluentbit_service_http_listen: "0.0.0.0"
    fluentbit_service_flush: 5
  roles:
    - devopsworks.fluentbit
```

## Configuration Files

The role creates the following files:

- `/etc/fluent-bit/fluent-bit.yaml` - Main YAML configuration file
- `/etc/fluent-bit/conf.d/` - Directory for additional configuration files
- `/etc/systemd/system/fluent-bit.service.d/override.conf` - systemd override to use YAML config

## Suggested Layout

You can organize your Fluent Bit configuration files in the
`/etc/fluent-bit/conf.d/` directory as follows:

- parsers are prefixed with `2x-<name>`
- inputs are prefixed with `3x-<tag>-<input_name>`; note that they must be
  inside a `pipeline` block
- filters are prefixed with `4x-<tag>-<filter_name>`; since multiple filters
  are used in sequence for a purpose, use the main (or most used) filter name,
  the goal is to be descriptive; note that they must be inside a `pipeline`
  block
- outputs are prefixed with `5x_<tag>-<output_name>`; note that they must be
  inside a `pipeline` block
- full pipelines are prefixed with `90_`

Note that:

- fluent-bit does not support multiple pipelines in a single configuration
  file, so each pipeline should be in its own file.
- fluent-bit merges all pipelines into one

So the layout looks like:

```/etc/fluent-bit/conf.d/
├── 2x-parsers.yaml
├── 3x-inputs.yaml
├── 4x-filters.yaml
├── 5x-outputs.yaml
├── 90_pipeline.yaml
└── 90_pipeline2.yaml
```

## Service Management

The role:

1. Installs Fluent Bit from the official repository
2. Creates systemd service override to use YAML configuration
3. Enables and starts the fluent-bit service
4. Provides a restart handler when configuration changes

## Development and Testing

### Linting

Run linting checks:

```bash
make lint
```

This runs:

- `ansible-lint` for Ansible best practices
- `yamllint` for YAML formatting
- `markdownlint` for Markdown files

### Testing

Run the full test suite with Molecule:

```bash
make test
```

This tests the role against:

- Ubuntu 24.04
- Debian 11
- Debian 12

### Cleanup

Clean up test artifacts:

```bash
make clean
```

## Platform Support

| Platform     | Status   |
| ------------ | -------- |
| Ubuntu 20.04 | ✅ Tested |
| Ubuntu 22.04 | ✅ Tested |
| Ubuntu 24.04 | ✅ Tested |
| Debian 11    | ✅ Tested |
| Debian 12    | ✅ Tested |

## Tags

The role supports the following tags:

- `fluentbit` - Run all Fluent Bit tasks
- `fluentbit:configure` - Run only configuration tasks

Example usage:

```bash
ansible-playbook playbook.yml --tags "fluentbit:configure"
```

## License

MIT

## Author Information

This role was created by devops.works.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `make test`
5. Run linting: `make lint`
6. Submit a pull request

## Changelog

### 0.0.4

- Add empty dummy configuration file to ensure Fluent Bit starts properly
- Add CLAUDE.md file for enhanced Claude Code development experience

### 0.0.3

- Fix: Refactor include_tasks syntax for clarity and consistency in fluentbit tasks

### 0.0.2

- Add ignore_errors conditionals for systemd tasks when running under Molecule/containers
- Configure ansible-lint to skip ignore-errors rule for containerized testing environments
- Improve reliability of role execution in Docker/Podman containers

### 0.0.1

- Initial release
- Support for Ubuntu and Debian
- YAML configuration support
- systemd service override
- Molecule testing framework
- Fix: Update molecule configuration for improved platform setup
- Fix: Update Fluent Bit handlers and tasks for improved service management and configuration
- Fix: Remove ignore_errors from Fluent Bit service enable task for improved error handling
- Fix: Remove ignore_errors from Fluent Bit handlers and tasks for improved error handling
- Switch molecule from Docker to Podman driver
- Fix Podman molecule tmpfs configuration syntax
- Improve CI Docker setup and configuration
