<#
.SYNOPSIS
  Verifica que la política de red del homelab se cumple (proyecto 0.1).
.DESCRIPTION
  Ejecuta `lab-check` dentro de cada VM vía `vagrant ssh` y compara con el resultado esperado.
  Requiere el perfil base levantado:  vagrant up
.EXAMPLE
  .\tests\Test-Network.ps1
#>
Set-Location (Split-Path $PSScriptRoot -Parent)

$tests = @(
  @{ From = 'dmz-web';  Check = 'route';                       Expect = '10.10.30.1'; Desc = 'La DMZ sale a Internet por el router' }
  @{ From = 'dmz-web';  Check = 'dns deb.debian.org';          Expect = 'OK';         Desc = 'DNS resuelve vía router (dnsmasq)' }
  @{ From = 'dmz-web';  Check = 'http https://deb.debian.org'; Expect = 'OK';         Desc = 'NAT de salida funciona' }
  @{ From = 'dmz-web';  Check = 'tcp 10.10.20.10 22';          Expect = 'FILTERED';   Desc = 'DMZ NO puede administrar el SOC' }
  @{ From = 'dmz-web';  Check = 'tcp 10.10.20.10 1514';        Expect = 'CLOSED';     Desc = 'DMZ llega al puerto de agentes del SIEM (sin servicio aún)' }
  @{ From = 'dmz-web';  Check = 'tcp 10.10.30.1 22';           Expect = 'FILTERED';   Desc = 'DMZ NO puede administrar el router' }
  @{ From = 'soc-siem'; Check = 'route';                       Expect = '10.10.20.1'; Desc = 'El SOC sale a Internet por el router' }
  @{ From = 'soc-siem'; Check = 'tcp 10.10.30.10 22';          Expect = 'OPEN';       Desc = 'El SOC administra la DMZ' }
  @{ From = 'soc-siem'; Check = 'tcp 10.10.20.1 22';           Expect = 'OPEN';       Desc = 'El SOC administra el router' }
)

$failed = 0
foreach ($t in $tests) {
  $raw = vagrant ssh $t.From -c "lab-check $($t.Check)" 2>$null
  $got = ($raw | Where-Object { $_ -match '\S' } | Select-Object -Last 1)
  if ($null -ne $got) { $got = $got.Trim() }
  $ok = $got -eq $t.Expect
  if (-not $ok) { $failed++ }
  $mark = if ($ok) { '[PASS]' } else { '[FAIL]' }
  $color = if ($ok) { 'Green' } else { 'Red' }
  Write-Host ("{0} {1,-9} {2,-32} esperado={3,-10} obtenido={4,-10} {5}" -f $mark, $t.From, $t.Check, $t.Expect, $got, $t.Desc) -ForegroundColor $color
}

Write-Host ""
if ($failed -eq 0) {
  Write-Host "Todos los tests pasaron ($($tests.Count))." -ForegroundColor Green
  exit 0
}
Write-Host "$failed de $($tests.Count) tests fallaron." -ForegroundColor Red
exit 1
