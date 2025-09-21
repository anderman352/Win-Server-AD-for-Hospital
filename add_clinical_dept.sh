Import-Module ActiveDirectory

$domainDN = "DC=lab,DC=local"
$baseOU   = "OU=hospital_departments,$domainDN"

# Clinical departments to provision
$departments = "Neurology","Cardiology","ENT","Pediatrics","Maternity"

# Standard role OUs for clinical departments
$roles = "Doctors","Nurses","Physician_Assistants","Admins","Schedulers","Workstations"

foreach ($dept in $departments) {
    $deptDN = "OU=$dept,$baseOU"
    foreach ($role in $roles) {
        $exists = Get-ADOrganizationalUnit -LDAPFilter "(ou=$role)" -SearchBase $deptDN -SearchScope OneLevel -ErrorAction SilentlyContinue
        if (-not $exists) {
            New-ADOrganizationalUnit -Name $role -Path $deptDN -ProtectedFromAccidentalDeletion $true | Out-Null
            Write-Host "Created: OU=$role under $dept"
        } else {
            Write-Host "Exists:  OU=$role under $dept"
        }
    }
}
