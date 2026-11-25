<#
.SYNOPSIS
  Prepara el host Windows para el homelab: instala VirtualBox y Vagrant y define dónde se guardan las VMs.
.DESCRIPTION
  - Instala VirtualBox y Vagrant con winget (si faltan).
  - Guarda las VMs de VirtualBox y las boxes de Vagrant (VAGRANT_HOME) en $LabRoot.
    Si no se indica, usa <disco local con más espacio libre>\VMs.
  - Avisa si el hipervisor de Windows (WSL2/Docker) está activo, porque hace más lento VirtualBox.
  No modifica bcdedit ni desactiva nada: ver docs/decisiones.md.
.EXAMPLE
  .\scripts\Setup-Host.ps1                   # elige el disco automáticamente
.EXAMPLE
  .\scripts\Setup-Host.ps1 -LabRoot E:\Lab   # ubicación explícita
#>
param(
  [string]$LabRoot
)

$MinFreeGB = 60   # Espacio recomendado con las VMs Windows incluidas

function Install-IfMissing([string]$Command, [string]$WingetId) {
  if (Get-Command $Command -ErrorAction SilentlyContinue) {
    Write-Host "[ok] $Command ya está instalado"
  } else {
    Write-Host "[..] Instalando $WingetId"
    winget install --id $WingetId -e --accept-package-agreements --accept-source-agreements
  }
}

# 1. Recursos
$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
Write-Host "RAM del host: $ramGB GB (perfil base ~3 GB, blue/red ~10 GB)"

# 2. Ubicación del lab
if (-not $LabRoot) {
  $disk = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' |
          Sort-Object FreeSpace -Descending | Select-Object -First 1
  $LabRoot = Join-Path "$($disk.DeviceID)\" 'VMs'
  $freeGB = [math]::Round($disk.FreeSpace / 1GB)
  Write-Host "[..] Sin -LabRoot: uso el disco local con más espacio libre ($($disk.DeviceID), $freeGB GB libres)"
  if ($freeGB -lt $MinFreeGB) {
    Write-Warning "Quedan menos de $MinFreeGB GB libres: alcanza para el perfil base, pero no para las VMs Windows."
  }
}
Write-Host "[..] Ubicación del lab: $LabRoot"

# 3. Software
Install-IfMissing 'VBoxManage' 'Oracle.VirtualBox'
Install-IfMissing 'vagrant'    'Hashicorp.Vagrant'

# Recién instalado, VBoxManage todavía no está en el PATH de esta sesión: se busca por su ruta.
$vboxDir = if ($env:VBOX_MSI_INSTALL_PATH) { $env:VBOX_MSI_INSTALL_PATH } else { Join-Path $env:ProgramFiles 'Oracle\VirtualBox' }
$vbox = Join-Path $vboxDir 'VBoxManage.exe'

# 4. Almacenamiento
New-Item -ItemType Directory -Force -Path "$LabRoot\VirtualBox", "$LabRoot\vagrant.d" | Out-Null
if (Test-Path $vbox) {
  & $vbox setproperty machinefolder "$LabRoot\VirtualBox"
  Write-Host "[ok] Carpeta de VMs de VirtualBox -> $LabRoot\VirtualBox"
} else {
  Write-Warning "No encontré VBoxManage.exe en $vboxDir. Volvé a correr el script en una terminal nueva."
}
[Environment]::SetEnvironmentVariable('VAGRANT_HOME', "$LabRoot\vagrant.d", 'User')
Write-Host "[ok] VAGRANT_HOME -> $LabRoot\vagrant.d (abrí una terminal nueva para que tome efecto)"

# 5. Hipervisor de Windows
# HypervisorPresent no requiere permisos de administrador (bcdedit sí).
if ((Get-CimInstance Win32_ComputerSystem).HypervisorPresent) {
  Write-Warning ("El hipervisor de Windows está activo (WSL2/Docker). VirtualBox va a funcionar, pero más lento; " +
                 "sobre todo las VMs Windows del proyecto 0.2. Ver docs/decisiones.md, D-03.")
}
