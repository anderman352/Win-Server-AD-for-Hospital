# Hospital Active Directory Lab (CMD-First)

This project demonstrates the build of a **hospital-style Active Directory environment** using Windows Server 2022 and Windows 11 Enterprise.
The lab focuses on **core IT administration fundamentals**: directory design, users and groups, Group Policy Objects (GPOs), and verification using **command-line tools (CMD)**.

PowerShell is intentionally minimized to reflect a CMD-first administrative workflow. Where no reasonable CMD equivalent exists (notably GPO import/export), minimal PowerShell is used and clearly marked.

---

## Lab Objectives

* Build a functional Active Directory domain from scratch
* Design a realistic OU structure for a hospital environment
* Create users and security groups aligned to departments and roles
* Apply and test Group Policy Objects
* Verify configuration using native Windows command-line tools

---

## Environment

### Virtualization

* Hypervisor: **VirtualBox**
* All virtual machines are built **fresh** for this project

### Virtual Machines

**Domain Controller**

* OS: Windows Server 2022 (Desktop Experience)
* Hostname: DC01
* Static IP: 192.168.1.10
* DNS: 192.168.1.10
* Roles: Active Directory Domain Services, DNS
* Domain: lab.local

**Client Workstation**

* OS: Windows 11 Enterprise
* Hostname: WIN11-CLIENT
* Static IP: 192.168.1.20
* DNS: 192.168.1.10
* Joined to: lab.local

**Linux Client**

* OS: Ubuntu
* Purpose: domain awareness and cross-platform testing

---

## Active Directory Design

### Organizational Unit Structure

**Finance_Hospital**

* Accountants
* Analysts
* Portfolio_Administrators
* Billing
* Revenue_Cycle
* Admins
* Workstations

**Hospital_Departments**

* Neurology
* Cardiology
* ENT
* Pediatrics
* Maternity

Each department contains the following child OUs:

* Doctors
* Nurses
* Physician_Assistants
* Admins
* Schedulers
* Workstations

---

## Users and Groups

* Users are created for each role within each department
* Security groups align to departmental roles
* Group membership reflects least-privilege principles
* Users and groups are imported using **CSVDE / LDIFDE** for repeatability

---

## Group Policy Objects

GPOs are used to enforce:

* Security baseline settings
* Workstation restrictions
* User environment controls

### GPO Management Approach

* GPOs are created using the Group Policy Management Console (GPMC)
* GPOs are exported and stored in the repository
* GPO application is verified using CMD-based tools

---

## Validation and Verification

Configuration is validated using built-in Windows command-line tools:

* `ipconfig`, `nslookup`
* `dsquery`, `net user`, `net group`
* `gpupdate /force`
* `gpresult /r` and `gpresult /h`

Screenshots of verification results are included in the repository.

---

## Repository Structure

```
Hospital-AD-Lab/
  README.md
  diagrams/
  build/
  imports/
  scripts/
  gpo-backups/
  screenshots/
```

---

## Why This Lab

This project reflects real-world IT administration tasks commonly performed by desktop support and junior system administrators. It emphasizes:

* Accuracy over automation
* Verification over assumptions
* Reproducibility over one-off configuration

---

## Next Steps

This lab is intentionally foundational. It may later be extended with:

* Advanced GPO hardening
* Centralized logging
* Security auditing and monitoring
