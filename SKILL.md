# OpenCode Ansible Skill

Use this skill when managing infrastructure with Ansible via OpenCode.
Loaded automatically when working in a repository containing this file.

## Capabilities

- **Ansible playbook management**: Create, edit, validate, run
- **Role development**: Scaffold and implement roles
- **Inventory management**: Host groups, variables, dynamic inventory
- **Infrastructure operations**: Deploy, configure, monitor Linux servers

## Conventions

- Read `AGENTS.md` for project-specific conventions before making changes
- Always run `make lint` before committing
- Use `--check --diff` for dry-runs before applying
- All configurable values go in `defaults/main.yml`

## Quick Commands

```bash
# Validate all playbooks
ansible-lint
ansible-playbook --syntax-check playbooks/site.yml

# Dry-run on localhost
ansible-playbook playbooks/site.yml -i inventory/hosts.yml \
  --connection=local --check --diff --tags mytag

# Run on specific host
ansible-playbook playbooks/site.yml -i inventory/hosts.yml \
  --limit target-host --tags mytag
```

## Available Scripts

- `./scripts/new-role <name>` — Scaffold a new Ansible role with defaults, tasks, handlers
- `./scripts/validate` — Run ansible-lint + syntax check on all playbooks
