# <Nombre del proyecto>

<!-- Badges opcionales: CI, licencia, última release -->
![Rama](https://img.shields.io/badge/rama-Blue%20Team-blue) ![Tipo](https://img.shields.io/badge/tipo-DETECT-green) ![Origen](https://img.shields.io/badge/origen-Propio-lightgrey)

> **TL;DR:** una o dos oraciones. Qué hiciste, con qué, y cuál fue el resultado medible.
> *Ejemplo: 25 reglas Sigma mapeadas a 18 técnicas de ATT&CK, validadas contra Atomic Red Team en CI. Detectan el 84 % de los tests, con 0 falsos positivos en 7 días de tráfico de base.*

> ⚠️ **Uso autorizado:** <sólo para proyectos ofensivos> El contenido es educativo y se ejecutó exclusivamente en un laboratorio propio o en plataformas que lo autorizan.

## 1. Problema

- ¿Qué problema real resuelve? ¿A quién le importa (SOC, desarrolladores, auditoría)?
- Contexto o escenario: *"Una pyme con AD on-prem no tiene visibilidad de movimiento lateral..."*

## 2. Enfoque

- Decisiones clave y **por qué** (qué alternativas descartaste).
- Marco de referencia usado: MITRE ATT&CK, OWASP, NIST, CIS...
- Alcance: qué incluye y qué queda **fuera**.

## 3. Arquitectura

![Diagrama](docs/arquitectura.png)

| Componente | Rol | Tecnología |
|---|---|---|
| | | |

## 4. Cómo reproducirlo

**Requisitos:** <RAM, SO, herramientas y versiones>

```bash
git clone --recurse-submodules https://github.com/<usuario>/<repo>.git
cd <repo>/lab
vagrant up            # o: docker compose up -d / terraform apply
# pasos para ejecutar y verificar
```

**Resultado esperado:** <qué tenés que ver si funcionó>

## 5. Resultados

| Métrica | Valor |
|---|---|
| <p. ej. técnicas ATT&CK cubiertas> | |
| <p. ej. hallazgos críticos/altos> | |
| <p. ej. tiempo de detección> | |

Capturas, gráficos o link al informe completo: [`docs/informe.md`](docs/informe.md)

## 6. Lecciones aprendidas

- **Qué salió mal y cómo lo resolví:** <lo más valioso para un entrevistador>
- **Qué haría distinto:**
- **Próximos pasos:**

## 7. Código de terceros y créditos

| Componente | Origen | Licencia | Uso |
|---|---|---|---|
| | | | Submódulo / fork modificado / dependencia |

Detalle en [`THIRD_PARTY.md`](THIRD_PARTY.md).

## Licencia

Código: MIT · Documentación: CC BY 4.0
