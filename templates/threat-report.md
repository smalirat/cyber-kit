---
titulo: Threat Report — <Actor / Campaña / Familia de malware>
tipo: Campaña | Actor | Malware | Vulnerabilidad
TLP: CLEAR
fecha: AAAA-MM-DD
autor: <Nombre>
confianza: Alta | Media | Baja
---

# Threat Report: <Nombre>

## Puntos clave (BLUF)

*Bottom Line Up Front: de 3 a 5 viñetas que se entiendan sin leer el resto.*

- **Quién:** <actor o grupo, atribución y nivel de confianza>
- **Qué:** <campaña o malware>
- **A quién afecta:** <sectores, regiones>
- **Impacto:** <robo de credenciales, ransomware, espionaje...>
- **Acción recomendada:** <lo más urgente>

## 1. Contexto

- Período observado:
- Fuentes: <OSINT, sandbox, feeds, telemetría del lab>
- Escala de confianza: Alta (múltiples fuentes independientes) / Media / Baja (una sola fuente)

## 2. Análisis técnico

### 2.1 Cadena de ataque

```text
Acceso inicial → Ejecución → Persistencia → Evasión → C2 → Objetivo
```

### 2.2 TTPs (MITRE ATT&CK)

| Táctica | Técnica | ID | Observación |
|---|---|---|---|
| Initial Access | Phishing: Spearphishing Attachment | T1566.001 | |
| Execution | | | |
| Persistence | | | |
| Command and Control | | | |

Capa de ATT&CK Navigator: [`layer.json`](layer.json)

### 2.3 Análisis del malware *(si aplica)*

| Campo | Valor |
|---|---|
| SHA-256 | |
| Tipo de archivo | |
| Familia | |
| Empaquetador / ofuscación | |
| Capacidades | |

Hallazgos estáticos, dinámicos y de configuración extraída.

## 3. Indicadores de compromiso (IOCs)

> Defangeados. También disponibles en [`iocs.stix.json`](iocs.stix.json) y [`iocs.csv`](iocs.csv).

| Tipo | Valor | Contexto | Primera vez visto |
|---|---|---|---|
| SHA-256 | | Dropper | |
| Dominio | `evil[.]example` | C2 | |
| IP | `203.0.113[.]10` | C2 | |
| URL | `hxxps://...` | Descarga | |

## 4. Detección

### Sigma

```yaml
title: <Nombre de la regla>
id: <uuid>
status: experimental
logsource:
  product: windows
  category: process_creation
detection:
  selection:
    Image|endswith: '\example.exe'
  condition: selection
level: high
tags:
  - attack.execution
  - attack.t1059
```

### YARA

```yara
rule Familia_Variante {
  meta:
    author = "<Nombre>"
    date = "AAAA-MM-DD"
    hash = "<sha256>"
  strings:
    $s1 = "..." ascii wide
  condition:
    uint16(0) == 0x5A4D and $s1
}
```

### Consultas de hunting

```kql
// KQL / SPL / EQL
```

## 5. Mitigaciones recomendadas

| Prioridad | Acción | Control relacionado (CIS v8 / ATT&CK Mitigation) |
|---|---|---|
| 1 | | |

## 6. Brechas de inteligencia

Qué no se sabe todavía y qué permitiría confirmarlo.

## Referencias

1.
