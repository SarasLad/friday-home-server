# friday – Minimal Linux Home Server on Old Hardware

## Overview

**friday** is a personal home server project built on an old Pentium E5200 machine with 2 GB RAM, running Debian 12. It behaves like a small production box: always on, remotely accessible, and capable of monitoring its own health and notifying the admin by email.

Goals:

- Reuse old hardware instead of letting it sit idle.  
- Practice Linux system administration, networking, and security on real hardware.  
- Build lightweight, scriptable monitoring and alerting without heavy external tooling.

---

## Features

- 24/7 Debian 12 server with SSH access for remote administration.  
- Gmail SMTP integration via `msmtp` + `mailutils` for authenticated email alerts.  
- Boot-time health report service that emails:
  - Hostname, uptime, load averages  
  - Memory usage and root filesystem usage  
  - IP addresses  
  - Temperature data from `lm-sensors`  
- Hourly resource watchdog:
  - Checks CPU, RAM, disk usage, and CPU temperature  
  - Sends alerts only when thresholds are exceeded (no noise when healthy)  
- Also acts as:
  - Personal storage / backup target accessible from anywhere (via secure remote access)  
  - Playground for homelab, security, and web‑hosting experiments

---

## Tech Stack

- **OS:** Debian GNU/Linux 12 (bookworm), i686  
- **Core tools:** `systemd`, `bash`, `msmtp`, `mailutils`, `lm-sensors`  
- **Hardware:** Pentium E5200 dual‑core CPU, 2 GB RAM, legacy Intel iGPU

---

## Mail / SMTP Setup (msmtp)

friday uses a dedicated Gmail account for alerts:
- 2‑Step Verification enabled  
- App Password generated for SMTP  
- `/etc/msmtprc` configured to use `smtp.gmail.com:587` with TLS

## Boot Health Mail

- Service: `systemd/friday-boot-mail.service`
- Script: `scripts/friday-boot-mail.sh`
- Runs once on every boot (after network is online) and sends a detailed health snapshot
  including uptime, load, memory, disk `/`, IP addresses, and sensor data.

## Resource Watchdog

- Service: `systemd/friday-watchdog.service`
- Timer: `systemd/friday-watchdog.timer`
- Script: `scripts/friday-watchdog.sh`
- Runs hourly (first run a few minutes after boot) and checks CPU, RAM, disk, and
  temperature thresholds; sends an email only if any metric is above its limit.

