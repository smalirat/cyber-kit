# Registro de decisiones

Formato corto tipo ADR: contexto → decisión → consecuencias.

## D-01 · VirtualBox + Vagrant como plataforma

- **Contexto:** el lab tiene que correr en una PC hogareña con Windows, sin un servidor dedicado. Las ediciones Home de Windows no traen el Administrador de Hyper-V, y Proxmox necesitaría una máquina aparte.
- **Decisión:** VirtualBox como hipervisor y Vagrant para declarar las VMs en código. La configuración vive en `lab.yml`.
- **Consecuencias:** gratis, reproducible y documentado como código. Más adelante se puede migrar a Proxmox con Terraform (proyecto 0.5) sin cambiar el diseño de red.

## D-02 · Router Linux con nftables en lugar de OPNsense o pfSense

- **Contexto:** OPNsense y pfSense no tienen boxes de Vagrant confiables y se configuran por interfaz web, lo que es difícil de versionar.
- **Decisión:** un Ubuntu con nftables, NAT y dnsmasq, configurado 100 % por script.
- **Consecuencias:** cero clicks y política legible en un archivo. A cambio, no hay interfaz web ni IDS integrado: Suricata se puede sumar al router en 0.3.

## D-03 · Convivencia con WSL2 y Docker Desktop

- **Contexto:** Docker Desktop activa el hipervisor de Windows. Con eso activo, VirtualBox 7 funciona sobre la API de Hyper-V, pero más lento (se nota sobre todo en VMs Windows).
- **Decisión:** por ahora se convive. Si las VMs Windows de 0.2 resultan muy lentas, hay dos opciones:
  - `bcdedit /set hypervisorlaunchtype off` y reiniciar. Esto deshabilita WSL2 y Docker.
  - `bcdedit /set hypervisorlaunchtype auto` y reiniciar, para volver a la configuración original.
- **Consecuencias:** hay que elegir entre "modo lab" y "modo Docker" por sesión de trabajo.

## D-04 · Presupuesto de RAM y perfiles

| Máquina | RAM | Proyecto |
|---|---|---|
| router | 0.75 GB | 0.1 |
| soc-siem | 1 GB → 4 GB con Wazuh | 0.1 / 0.3 |
| dmz-web | 1 GB | 0.1 |
| corp-dc | 2 GB | 0.2 |
| corp-ws01 | 3 GB | 0.2 |
| attacker-kali | 2.5 GB | 0.4 |

- **Decisión:** hay perfiles en `lab.yml` (`base`, `blue`, `red`) que se eligen con `LAB_PROFILE`. Nunca se levanta todo junto: el host necesita reservar ~4 GB para Windows.
- **Consecuencias:** cada ejercicio declara qué perfil usa.

## D-05 · VMs y boxes fuera de C:

- **Contexto:** el disco del sistema suele tener poco espacio libre, y las boxes de Windows pesan entre 6 y 10 GB cada una.
- **Decisión:** `scripts/Setup-Host.ps1` mueve la carpeta de VMs de VirtualBox y `VAGRANT_HOME` al disco local con más espacio libre, o a la ruta que se indique con `-LabRoot`. Además se usan *linked clones* para no duplicar discos.

## D-06 · Adaptador NAT de Vagrant como red de gestión

- **Contexto:** Vagrant necesita el adaptador 1 en NAT para hacer SSH o WinRM.
- **Decisión:** se mantiene, pero sin ruta por defecto ni DNS (con drop-ins de systemd-networkd). Todo el tráfico de las VMs pasa por el router.
- **Limitación conocida:** alguien con root en una VM podría salir por el adaptador NAT y saltear el router. Es aceptable en un lab y queda documentado como "red de gestión fuera de banda".
