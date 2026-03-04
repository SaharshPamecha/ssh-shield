# SSH Hardening with ssh-shield: Automating CIS Compliance — Day 3 of 100 Days of DevOps

**Direct root SSH login is a security anti-pattern.** Every CIS Benchmark, every NIST guideline, and every breach post-mortem tells you to disable it. Yet I still see it enabled in production environments.

Day 3 of my 100-day open-source DevOps journey addresses this head-on. I built `ssh-shield` after manually editing `sshd_config` on three servers and thinking: *there has to be a better way that doesn't involve praying I don't typo a config line and lock myself out.*

---

## The Real Problem

SSH hardening seems trivial until you're responsible for a fleet:

- **Manual edits** = config drift. Server 1 has `PermitRootLogin no`, Server 47 still has `yes`, and nobody remembers why.
- **Compliance audits** want evidence. Screenshots of `cat /etc/ssh/sshd_config` don't impress auditors.
- **Rollback is scary.** If you break SSH on a production box, you're driving to the data center at 2 AM.

Existing tools like Lynis are comprehensive but heavy. They're auditors, not fixers. I wanted something that *just handles SSH hardening* with production safety built-in.

---

## Introducing ssh-shield

A zero-dependency Bash tool that does three things:

### 1. Audit with Context

```bash
$ ssh-shield audit
```

Checks `PermitRootLogin`, `PasswordAuthentication`, `Protocol`, `MaxAuthTries`, and more. Outputs a 1-6 security score with CIS Benchmark references (5.2.8, 5.2.12, etc.).

**Why this matters**: You can't fix what you can't measure. The score gamifies compliance — "We're at 4/6, let's get to 6/6 before the audit."

### 2. Harden with Safety

```bash
$ sudo ssh-shield harden
```

Applies CIS-compliant settings with multiple safety mechanisms:

- **Automatic backup** with timestamp: `sshd_config.backup.20260305_091530`
- **Config validation** via `sshd -t` before restart
- **Automatic rollback** if validation fails
- **Interactive confirmation** for `PasswordAuthentication` (so you don't lock yourself out)

**Why this matters**: I've seen Ansible playbooks blast broken SSH configs to 200 servers. This tool validates before applying — because one broken server ruins your weekend.

### 3. Report for Auditors

```bash
$ ssh-shield report
```

Generates HTML compliance reports with:
- Server metadata and timestamps
- Security score visualizations  
- CIS Benchmark mappings
- Pass/fail status per control

**Why this matters**: SOC2 and ISO27001 auditors want evidence. A CLI output screenshot looks unprofessional. A generated HTML report shows you take compliance seriously.

---

## Design Decisions

### Zero Dependencies

Pure Bash. Uses standard utilities: `grep`, `sed`, `awk`, `systemctl`. Works on Alpine, Ubuntu, RHEL, Debian — anything with OpenSSH.

**Trade-off**: Less feature-rich than Python alternatives, but you don't need to install Python or pip on a minimal server just to harden SSH.

### Safety-First Hardening

The tool refuses to restart SSH if `sshd -t` reports errors. It keeps the backup file even on success (cleanup is manual, which is intentional).

**Trade-off**: Slower than blind `sed + systemctl restart`. But I've been locked out of servers before. This is slower but safer.

### Human + Machine Readable

Color-coded terminal output for humans. JSON-compatible structure for automation. HTML reports for auditors. Everyone gets what they need.

---

## Real-World Usage Patterns

### Single Server (Interactive)

```bash
ssh admin@server
ssh-shield audit           # See current state
sudo ssh-shield harden     # Fix it
ssh-shield report          # Generate evidence
```

### Fleet-Wide (Ansible Integration)

```yaml
- name: Ensure SSH compliance
  hosts: all
  tasks:
    - name: Audit SSH hardening
      command: ssh-shield audit
      register: audit_result
      changed_when: false
      
    - name: Harden if needed
      command: ssh-shield harden
      when: "'Needs Hardening' in audit_result.stdout"
      
    - name: Generate report
      command: ssh-shield report
```

### Daily Compliance Monitoring

```bash
# Cron job for continuous compliance
0 6 * * * /usr/local/bin/ssh-shield report && \
  scp /tmp/ssh-shield-reports/*.html compliance@central:/evidence/
```

---

## Interactive Demo

I've deployed a web simulator at **https://ssh-shield.vercel.app** where you can run all commands against a simulated environment.

**Visual identity note**: Day 1 (userctl) uses cyan. Day 2 (expiry-guard) uses amber. Day 3 (ssh-shield) uses deep teal/emerald — a "secure vault" aesthetic. Small design choices compound.

---

## Installation

```bash
curl -sL https://raw.githubusercontent.com/SaharshPamecha/ssh-shield/main/install.sh | sudo bash
```

Or manual:

```bash
sudo curl -fsSL https://raw.githubusercontent.com/SaharshPamecha/ssh-shield/main/cli/ssh-shield \
  -o /usr/local/bin/ssh-shield
sudo chmod +x /usr/local/bin/ssh-shield
```

---

## The Bigger Picture

This is Day 3 of 100. The pattern emerging:

- **Day 1 (userctl)**: Service account lifecycle
- **Day 2 (expiry-guard)**: Temporary user expiry
- **Day 3 (ssh-shield)**: SSH hardening

Each tool is independent but composes into a "Linux Security Toolkit." A sysadmin could install all three and have audit coverage for accounts, temporal access, and SSH posture — with zero language dependencies.

---

## What's Next

Three tools down. The journey continues daily. Follow along for open-source DevOps tools that solve real infrastructure problems.

If SSH hardening is a pain point you recognize, try the tool. File issues. This is production-grade open source — it gets better with real-world usage.

---

**Source Code**: https://github.com/SaharshPamecha/ssh-shield

**Interactive Demo**: https://ssh-shield.vercel.app

**License**: MIT

---

**About the Author**

Saharsh Pamecha is a Staff Engineer exploring the intersection of infrastructure automation and security. This post is part of a 100-day open-source DevOps journey. Follow on [X @SaharshPamecha1](https://x.com/SaharshPamecha1) and [LinkedIn](https://www.linkedin.com/in/saharsh-pamecha-6219961b7/) for daily updates.
