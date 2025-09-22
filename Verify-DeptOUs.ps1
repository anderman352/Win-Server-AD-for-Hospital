[CmdletBinding()]
param(
    [string]$Department,     # e.g. Neurology; if omitted, you'll be prompted unless -All is used
    [switch]$All             # Verify all departments under hospital_departments
)

Import-Module ActiveDirectory

# Discover domain DN automatically (e.g., DC=lab,DC=local)
$domainDN = (Get-ADDomain).DistinguishedName
$baseOU   = "OU=hospital_departments,$domainDN"

if (-not (Get-ADOrganizationalUnit -Identity $baseOU -ErrorAction SilentlyContinue)) {
    Write-Host "Base OU not found: $baseOU" -ForegroundColor Red
    exit 1
}

# Expected role sets
$clinicalRoles = @("Doctors","Nurses","Physician_Assistants","Admins","Schedulers","Workstations")
$financeRoles  = @("Accountants","Analysts","Portfolio_Administrators","Billing","Revenue_Cycle","Admins","Workstations")

function Get-ExpectedRolesForDept {
    param([Parameter(Mandatory)][string]$DeptName)
    if ($DeptName -ieq "Finance") { return $financeRoles }
    else { return $clinicalRoles }
}

function Test-DepartmentOUs {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$DeptName)

    $deptDN = "OU=$DeptName,$baseOU"
    if (-not (Get-ADOrganizationalUnit -Identity $deptDN -ErrorAction SilentlyContinue)) {
        Write-Host "[X] Department OU missing: $DeptName" -ForegroundColor Red
        return [pscustomobject]@{
            Department = $DeptName
            Present    = @()
            Missing    = @("<DEPARTMENT OU NOT FOUND>")
        }
    }

    $expected = Get-ExpectedRolesForDept -DeptName $DeptName
    $present  = @()
    $missing  = @()

    Write-Host "`n=== $DeptName ===" -ForegroundColor Cyan
    foreach ($role in $expected) {
        $roleExists = Get-ADOrganizationalUnit -LDAPFilter "(ou=$role)" -SearchBase $deptDN -SearchScope OneLevel -ErrorAction SilentlyContinue
        if ($roleExists) {
            Write-Host ("  [+] " + $role) -ForegroundColor Green
            $present += $role
        } else {
            Write-Host ("  [!] " + $role) -ForegroundColor Red
            $missing += $role
        }
    }

    if ($missing.Count -gt 0) {
        Write-Host ("  --> Missing: " + ($missing -join ", ")) -ForegroundColor Yellow
    } else {
        Write-Host "  --> All expected role OUs present." -ForegroundColor Green
    }

    return [pscustomobject]@{
        Department = $DeptName
        Present    = $present
        Missing    = $missing
    }
}

$results = @()

if ($All) {
    # Enumerate all departments under hospital_departments
    $depts = Get-ADOrganizationalUnit -SearchBase $baseOU -SearchScope OneLevel -Filter * | Select-Object -ExpandProperty Name
    if (-not $depts) { Write-Host "No department OUs found under $baseOU" -ForegroundColor Yellow; exit 0 }
    foreach ($d in $depts) { $results += Test-DepartmentOUs -DeptName $d }
}
else {
    if (-not $Department) {
        $available = Get-ADOrganizationalUnit -SearchBase $baseOU -SearchScope OneLevel -Filter * | Select-Object -ExpandProperty Name
        Write-Host "Available departments:" -ForegroundColor Cyan
        $available | ForEach-Object { Write-Host (" - " + $_) }
        $Department = Read-Host "Type a department to verify"
    }
    $results += Test-DepartmentOUs -DeptName $Department
}

# Overall summary
$missingAny = $results | Where-Object { $_.Missing.Count -gt 0 }
Write-Host "`n====== SUMMARY ======" -ForegroundColor White
foreach ($r in $results) {
    if ($r.Missing.Count -gt 0) {
        Write-Host ("{0}: Missing -> {1}" -f $r.Department, ($r.Missing -join ", ")) -ForegroundColor Yellow
    } else {
        Write-Host ("{0}: OK" -f $r.Department) -ForegroundColor Green
    }
}

if ($missingAny) { exit 2 } else { exit 0 }
