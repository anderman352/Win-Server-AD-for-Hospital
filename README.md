# Hospital Active Directory Lab (Windows Server 2022 + Windows 11)

This project builds a hospital-style Active Directory lab using Windows Server 2022 (Domain Controller) and Windows 11 Enterprise (client).  
The lab simulates departments, finance, and role-based OUs, and demonstrates PowerShell automation and GPO testing.

---

## Lab Setup

Domain Controller (Windows Server 2022)
- Static IP: 192.168.1.10
- DNS: points to itself
- Promoted to Domain Controller: lab.local
- Roles: AD DS, DNS

Windows 11 Client
- Static IP: 192.168.1.20
- DNS: points to 192.168.1.10
- Joined to lab.local

---

## OU Design

Finance_Hospital (top-level hospital finance)
- Accountants
- Analysts
- Portfolio_Administrators
- Billing
- Revenue_Cycle
- Admins
- Workstations

hospital_departments (all medical and operational departments)
- Neurology
  - Doctors
  - Nurses
  - Physician_Assistants
  - Admins
  - Schedulers
  - Workstations
- Cardiology (same role OUs as Neurology)
- ENT (same role OUs)
- Pediatrics (same role OUs)
- Maternity (same role OUs)
- Finance (same role OUs as Finance_Hospital)

---

## Scripts

Create-HospitalOUs.ps1  
- Creates the OU tree for hospital_departments and Finance_Hospital.  
- Parameters allow specifying domain DN, department names, and roles.

Verify-DeptOUs.ps1  
- Verifies that all expected role OUs exist under each department.  
- Flags missing OUs in red.  
- Supports single-department or all-department verification.

---

## PowerShell Command Reference

This section documents all commands used in the lab, with explanations.

### Importing AD Module and Checking Domain

```powershell
Import-Module ActiveDirectory
(Get-ADDomain).DistinguishedName
Description: Loads Active Directory module and displays the domain DN (e.g., DC=lab,DC=local).

Creating OUs
powershell

New-ADOrganizationalUnit -Name "Finance" -Path "DC=lab,DC=local"
Description: Creates a new OU at the domain root.

powershell

"Doctors","Nurses" | ForEach-Object {
    New-ADOrganizationalUnit -Name $_ -Path "OU=Neurology,OU=hospital_departments,DC=lab,DC=local"
}
Description: Creates multiple role OUs under the Neurology department.

Renaming OUs
powershell

Rename-ADObject -Identity "OU=Finance,DC=lab,DC=local" -NewName "Finance_Hospital"
Rename-ADObject -Identity "OU=Hospital,DC=lab,DC=local" -NewName "hospital_departments"
Description: Renames existing OUs for clarity.

Moving Users
powershell

$targetOU = "OU=Finance,OU=hospital_departments,DC=lab,DC=local"
Move-ADObject -Identity (Get-ADUser -Identity testuser).DistinguishedName -TargetPath $targetOU
Description: Moves user accounts into the correct OU.

Listing Users and OUs
powershell

Get-ADUser -Identity testuser | Select Name,DistinguishedName
Description: Shows the DistinguishedName of a user.

powershell

Get-ADOrganizationalUnit -SearchBase "OU=Neurology,OU=hospital_departments,DC=lab,DC=local" -SearchScope OneLevel -Filter * | Select Name
Description: Lists all sub-OUs under Neurology.

Deleting OUs Safely
Step 1 – Disable protection:

powershell

Set-ADOrganizationalUnit -Identity "OU=Doctors,OU=Finance,DC=lab,DC=local" -ProtectedFromAccidentalDeletion $false
Step 2 – Remove the OU:

powershell

Remove-ADOrganizationalUnit -Identity "OU=Doctors,OU=Finance,DC=lab,DC=local" -Recursive -Confirm:$false
Description: Unprotects and deletes an unwanted OU.

Protecting and Unprotecting OUs
powershell

Set-ADOrganizationalUnit -Identity "OU=Finance,DC=lab,DC=local" -ProtectedFromAccidentalDeletion $false
Set-ADOrganizationalUnit -Identity "OU=Finance,DC=lab,DC=local" -ProtectedFromAccidentalDeletion $true
Description: Toggles the accidental deletion protection flag on OUs.

Adding Users to Groups
powershell

Add-ADGroupMember -Identity "Domain Admins" -Members "admin"
Description: Adds the user "admin" to the Domain Admins group.

Domain Controller Verification
cmd

echo %logonserver%
nltest /dsgetdc:lab.local
Description: Confirms which Domain Controller the user is logged into and verifies the DC for the domain.

Windows 11 Client Commands
powershell

Add-Computer -DomainName lab.local -Credential LAB\Administrator -Restart
Description: Joins the Windows 11 machine to the lab.local domain.

cmd

gpupdate /force
gpresult /r
Description: Forces Group Policy to update and checks applied GPOs.

