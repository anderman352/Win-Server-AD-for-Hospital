param(
    [string]$Department
)

Import-Module ActiveDirectory

$domainDN = "DC=lab,DC=local"
$baseOU   = "OU=hospital_departments,$domainDN"

if (-not $Department) {
    Write-Host "Available departments:" -ForegroundColor Cyan
    "Neurology","Cardiology","ENT","Pediatrics","Maternity","Finance" | ForEach-Object { Write-Host " - $_" }
    $Department = Read-Host "Type a department to verify"
}

$deptDN = "OU=$Department,$baseOU"

if (-not (Get-ADOrganizationalUnit -Identity $deptDN -ErrorAction SilentlyContinue)) {
    Write-Host "Department OU '$Department' not found under hospital_departments." -ForegroundColor Red
    exit
}

Write-Host "Role OUs under $Department:" -ForegroundColor Green
Get-ADOrganizationalUnit -SearchBase $deptDN -SearchScope OneLevel -Filter * |
  Select-Object -ExpandProperty Name
