# AGENTS.md — OpenCode Ansible Infrastructure

## Project Overview

Agentic Ansible — infrastructure as code managed through OpenCode AI agents.
This repo is designed for AI-first operations: agents read this file to understand
the project structure, conventions, and operational patterns before making changes.

## Quick Start

```bash
# Bootstrap a new Ubuntu host
ansible-playbook playbooks/bootstrap.yml -i inventory/hosts.yml -l myhost

# Lint all playbooks
make lint

# Dry-run against localhost (for development)
make try

# Deploy everything
ansible-playbook playbooks/site.yml -i inventory/hosts.yml
```

## Operating Principles

1. **Declarative over imperative** — Describe the target state, not the steps.
2. **Idempotent operations** — Every role must be safe to re-run.
3. **Agent-friendly YAML** — Use clear `name:` fields; avoid complex Jinja.
4. **Test via dry-run** — Use `--check --diff` before making changes.
5. **Variables over hardcoding** — All configurable values in `defaults/main.yml`.

## Repository Structure

```
opencode-ansible/
├── .opencode/agents/       # Agent definitions (read by OpenCode)
├── inventory/              # Host inventories + group_vars
│   ├── hosts.yml           # Production inventory
│   ├── staging.yml         # Staging/dev inventory
│   └── group_vars/         # Variable hierarchy
├── roles/                  # Reusable Ansible roles
│   ├── sysctl/             # Kernel memory tuning
│   ├── docker/             # Docker install + config
│   ├── monitoring/         # Prometheus/node_exporter
│   └── ...                 # Add new roles here
├── playbooks/              # Composable playbooks
│   ├── site.yml            # Master playbook (imports all)
│   ├── bootstrap.yml       # Initial host setup
│   └── *.yml               # Targeted playbooks
├── role-skeletons/         # Scaffold templates for new roles
│   ├── config-deploy/      # Copy config files
│   ├── docker-compose/     # Docker Compose services
│   └── sysctl-tune/        # Kernel parameter tuning
├── scripts/                # Helper scripts for agentic workflow
│   ├── new-role            # Scaffold a new role
│   └── validate            # Lint + syntax check
├── AGENTS.md               # THIS FILE — agent context contract
├── SKILL.md                # OpenCode skill for Ansible operations
├── Makefile                # Common operations
└── ansible.cfg             # Ansible configuration
```

## Inventory Groups Convention

| Group Name       | Purpose                              | Variables In              |
|------------------|--------------------------------------|---------------------------|
| `all`            | Every host                           | `group_vars/all.yml`      |
| `linux`          | All Linux hosts                      | `group_vars/linux.yml`    |
| `workstations`   | Dev machines                         | `group_vars/workstations` |
| `servers`        | Production servers                   | `group_vars/servers`      |
| `containers`     | Hosts running Docker/Podman          | `group_vars/containers`   |
| `databases`      | Hosts with databases                 | `group_vars/databases`    |

## Role Structure Convention

Every role MUST follow this structure:

```
roles/<name>/
├── defaults/main.yml    # ALL configurable variables with defaults
├── tasks/main.yml       # Idempotent tasks (one aspect per task)
├── handlers/main.yml    # Handlers (restart services, reload configs)
├── templates/           # Jinja2 templates (if needed)
├── files/               # Static files (if needed)
└── vars/                # OS-specific variable overrides
```

## Task Naming Convention

```yaml
- name: "<verb> <noun> for <purpose> — <expected_effect>"
  # GOOD: "Install Prometheus node_exporter for hardware metrics — exposes :9100"
  # BAD:  "Setup monitoring"
  # BAD:  "Configure stuff"
```

## Making Changes — Agent Protocol

When an AI agent modifies this repository:

1. **Read this file first** — Understand the conventions.
2. **Read relevant role/playbook** — Match existing patterns.
3. **Use `make lint` before committing** — Syntax + best-practices check.
4. **Always add `name:`** — Every task needs a clear purpose statement.
5. **Prefer `--check --diff`** — Dry-run before applying changes.
6. **Commit with descriptive messages** — Include what and why.

## Role Development Workflow

```bash
# 1. Scaffold a new role
./scripts/new-role my-role-name

# 2. Edit defaults/main.yml — add ALL configurable variables
# 3. Edit tasks/main.yml — add idempotent tasks
# 4. Edit handlers/main.yml — add service restart handlers

# 5. Test with dry-run
make try TAGS=my-role-name

# 6. Test on real host (with limit)
ansible-playbook playbooks/site.yml --limit testhost --tags my-role-name --check --diff

# 7. Commit
git add roles/my-role-name && git commit -m "feat: add my-role-name role for <purpose>"
```

## Key Playbooks

| Playbook           | Purpose                          | Tags         |
|--------------------|----------------------------------|--------------|
| `site.yml`         | Master playbook (run everything) | —            |
| `bootstrap.yml`    | Initial host setup               | bootstrap    |
| `monitoring.yml`   | Prometheus + exporters           | monitoring   |
| `security.yml`     | SSH hardening, firewall          | security     |
| `docker.yml`       | Docker engine install             | docker       |

## MCP Servers (Infrastructure Tools)

See `.opencode/mcp.json` for configured infrastructure MCP servers.
Agents can use these for live infrastructure queries via MCP protocol.
