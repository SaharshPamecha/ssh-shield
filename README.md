# ssh-shield

**One-command SSH hardening for CIS compliance**

[![Version](https://img.shields.io/badge/version-1.0.0-teal)](https://github.com/SaharshPamecha/ssh-shield)
[![License](https://img.shields.io/badge/license-MIT-teal)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-teal)](https://github.com/SaharshPamecha/ssh-shield)

A production-grade CLI tool for auditing, enforcing, and reporting SSH hardening configurations. Addresses CIS Benchmark requirements with zero dependencies.

**Live Demo**: https://ssh-shield.vercel.app

---

## The Problem

SSH misconfiguration is the #1 attack vector for Linux servers:
- Direct root login enables brute-force attacks
- Password authentication is vulnerable to credential stuffing
- Manual hardening across fleets = config drift and audit failures
- No simple way to verify compliance (SOC2, ISO27001, CIS)

**Existing tools** like Lynis are heavy and complex. Manual scripts are unreliable. You need something purpose-built.

---

## Features

- **`audit`** — Check current SSH hardening status with security scoring
- **`harden`** — Apply CIS-compliant settings safely (with automatic backup)
- **`report`** — Generate production-ready HTML compliance reports

### Security Checks

| Setting | CIS Reference | Risk if Misconfigured |
|---------|---------------|---------------------|
| `PermitRootLogin no` | 5.2.8 | Root brute-force attacks |
| `PasswordAuthentication no` | 5.2.12 | Credential stuffing |
| `Protocol 2` | 5.2.2 | Protocol downgrade attacks |
| `PermitEmptyPasswords no` | 5.2.7 | Unauthenticated access |
| `MaxAuthTries ≤ 4` | 5.2.5 | Brute-force amplification |

---

## Installation

```bash
curl -sL https://raw.githubusercontent.com/SaharshPamecha/ssh-shield/main/install.sh | sudo bash
```

Or manual install:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/SaharshPamecha/ssh-shield/main/cli/ssh-shield -o /usr/local/bin/ssh-shield
sudo chmod +x /usr/local/bin/ssh-shield
```

---

## Usage

### Check Current Status

```bash
ssh-shield audit
```

Output includes:
- Current setting values with color-coded status
- CIS Benchmark references
- Overall security score (A+ to D)

### Apply Hardening

```bash
sudo ssh-shield harden
```

Safety features:
- Automatic config backup with timestamp
- SSH config validation before restart
- Automatic rollback on validation failure
- Interactive confirmation for password auth disable

### Generate Report

```bash
ssh-shield report
```

Creates HTML compliance report at `/tmp/ssh-shield-reports/`

---

## Real-World Usage

### Single Server Hardening

```bash
# Audit first
ssh-shield audit

# Apply hardening
sudo ssh-shield harden

# Generate evidence for auditors
ssh-shield report
```

### Fleet-Wide Compliance (Ansible Integration)

```yaml
- name: Ensure SSH hardening compliance
  hosts: all
  tasks:
    - name: Copy ssh-shield
      copy:
        src: ssh-shield
        dest: /usr/local/bin/ssh-shield
        mode: '0755'
    
    - name: Run audit
      command: ssh-shield audit
      register: ssh_audit
      changed_when: false
    
    - name: Apply hardening if needed
      command: ssh-shield harden
      when: "'Needs Hardening' in ssh_audit.stdout"
```

### Daily Compliance Reports

```bash
# Add to crontab for daily reports
0 2 * * * /usr/local/bin/ssh-shield report && scp /tmp/ssh-shield-reports/*.html compliance@central-server:/reports/
```

---

## Design Philosophy

- **Zero dependencies**: Pure Bash, works on any Linux distro
- **Production-safe**: Always backup, always validate, never break SSH access
- **Compliance-ready**: HTML reports auditors actually want to see
- **Unix philosophy**: Does one thing well, integrates with existing tools

---

## Interactive Demo

Try the web simulator before installing:

**[Launch Interactive Demo: https://ssh-shield.vercel.app](https://ssh-shield.vercel.app)**

The web version demonstrates all `ssh-shield` commands against a simulated environment with deep teal/emerald theme (Day 3's visual identity).

---

## CIS Benchmark Mapping

| Control | ssh-shield Check | Implementation |
|---------|------------------|----------------|
| 5.2.2 Protocol 2 | ✅ | `Protocol 2` enforcement |
| 5.2.5 MaxAuthTries | ✅ | Default 3 attempts |
| 5.2.7 Empty Passwords | ✅ | `PermitEmptyPasswords no` |
| 5.2.8 Root Login | ✅ | `PermitRootLogin no` |
| 5.2.12 Password Auth | ⚠️ | Optional (with confirmation) |

---

## Security Warnings

⚠️ **Before running `harden`:**

1. Ensure you have alternative access (console, different user, or SSH keys)
2. Test in staging first
3. Have your SSH config backed up externally
4. The tool creates local backups automatically, but redundancy matters

⚠️ **Password Authentication**: Disabling this will lock you out if you don't have SSH keys set up. The tool asks for confirmation.

---

## Source Code

**Repository**: https://github.com/SaharshPamecha/ssh-shield

```
ssh-shield/
├── cli/
│   └── ssh-shield          # Main Bash CLI
├── web/                    # Next.js demo website
├── examples/
│   └── ansible-playbook.yml
├── install.sh              # One-line installer
├── LICENSE                 # MIT License
└── README.md
```

---

## Related Projects

- **Day 1 — userctl**: [github.com/SaharshPamecha/userctl](https://github.com/SaharshPamecha/userctl) — Service account auditor
- **Day 2 — expiry-guard**: [github.com/SaharshPamecha/expiry-guard](https://github.com/SaharshPamecha/expiry-guard) — Temporary user lifecycle

---

## License

MIT License — See [LICENSE](LICENSE) for details.

Built by [Saharsh Pamecha](https://x.com/SaharshPamecha1) as part of a 100-day open-source DevOps journey.
