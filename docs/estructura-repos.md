# Estructura de repositorios

## Modelo: un repo índice + repos por proyecto + algunos repos agrupados

```text
github.com/<usuario>/
├── <usuario>                    # Repo de perfil (README que aparece en tu perfil de GitHub)
├── cyber-kit                    # ESTE repo: índice del portfolio, roadmap y plantillas
│
├── homelab-iac                  # Rama 0 — repo propio (base de todo lo demás); hoy vive en cyber-kit/homelab
├── blue-detection-as-code       # 2.2  — repo propio
├── blue-ir-playbooks            # 2.3  — repo propio
├── red-ad-killchain             # 1.4  — repo propio (purple)
├── red-recon-tool               # 1.5  — repo propio (herramienta)
├── appsec-devsecops-pipeline    # 4.2  — repo propio
├── appsec-llm-redteam           # 4.5  — repo propio
│
├── writeups                     # 1.1, 3.3 — AGRUPADO (CTFs, crackmes, labs cortos)
├── reports                      # 1.2, 2.3, 3.1, 3.2, 6.x — AGRUPADO (informes en PDF + fuente MD)
└── forks/                       # Forks donde hacés contribuciones (Sigma, Velociraptor, Nuclei...)
```

Convención de nombres: `<rama>-<tema>` con prefijos `red-`, `blue-`, `dfir-`, `appsec-`, `infra-`, `grc-`. Así se agrupan solos en tu lista de repos.

## Estructura del repo índice (este)

```text
cyber-kit/
├── README.md                 # Portfolio: quién sos, proyectos destacados y tabla por rama
├── ROADMAP.md                # Fases, proyectos y estado
├── docs/
│   ├── estructura-repos.md   # Este documento
│   └── diagramas/            # Diagrama general del homelab, etc.
├── templates/
│   ├── README-proyecto.md
│   ├── informe-pentest.md
│   ├── threat-report.md
│   └── THIRD_PARTY.md
└── LICENSE
```

## Estructura de un repo de proyecto

```text
blue-detection-as-code/
├── README.md                 # Basado en templates/README-proyecto.md
├── LICENSE                   # MIT o Apache-2.0 para código; CC BY 4.0 para documentación
├── THIRD_PARTY.md            # Qué código ajeno usás, con qué licencia y en qué versión
├── docs/
│   ├── arquitectura.png
│   └── informe.md
├── src/ | rules/ | playbooks/   # Lo central del proyecto
├── tests/
├── lab/                      # Vagrantfile / docker-compose / terraform para reproducirlo
├── third_party/              # Submódulos de git fijados a un commit (nunca código copiado sin atribuir)
└── .github/workflows/        # CI: lint, tests, scans
```

## ¿Repo propio o agrupado?

| Criterio | Repo propio | Agrupado |
|---|---|---|
| Tiene código ejecutable, tests o CI | ✅ | |
| Se puede reproducir (tiene `lab/` o IaC) | ✅ | |
| Duró más de ~2 semanas o tiene más de ~5 archivos relevantes | ✅ | |
| Lo vas a linkear en el CV o en LinkedIn como proyecto "estrella" | ✅ | |
| Otros lo podrían usar (herramienta, reglas, playbooks) | ✅ | |
| Es un write-up de un CTF, una máquina o un crackme | | ✅ `writeups` |
| Es un informe sin código propio | | ✅ `reports` |
| Es un ejercicio de menos de un día o un tutorial seguido paso a paso | | ✅ (o no lo publiques) |
| Repite algo que ya está en otro repo | | ✅ como sección de ese repo |

**Regla práctica:** si pasa 3 o más criterios de la columna "Repo propio", se lo merece. Ante la duda, empezalo dentro de un repo agrupado y separalo cuando crezca (`git subtree split` conserva el historial).

## Código de terceros: cómo usarlo sin perder credibilidad

Usar código ajeno está perfecto, y demuestra que sabés integrar. Lo que resta puntos es que parezca propio.

| Situación | Cómo hacerlo |
|---|---|
| Usás una herramienta tal cual (Sigma, Atomic Red Team, GOAD) | Submódulo en `third_party/` fijado a un commit, o instrucciones de instalación con la versión exacta |
| La modificaste | Hacé un fork, trabajá en una rama y documentá el diff en el README ("qué cambié y por qué") |
| Copiás un fragmento | Sólo si la licencia lo permite. Ponele un comentario con la fuente y la licencia, y anotalo en `THIRD_PARTY.md` |
| Lo mejoraste y sirve a otros | Mandá un PR upstream y linkealo en el portfolio: un PR aceptado vale más que un repo propio |
| Licencia GPL/AGPL | Si distribuís código derivado, el tuyo hereda la licencia. Para wrappers o integraciones, mantenelo como proceso separado |
| Sin licencia | Legalmente no podés reutilizarlo. Linkealo, pero no lo copies |

En el README del índice, marcá cada proyecto con su origen: **Propio**, **Integración** (código ajeno orquestado por vos) o **Contribución** (PR a terceros).

## Higiene antes de publicar

- [ ] Nada de credenciales, tokens, IPs públicas reales ni `.env` (pasá `gitleaks detect` antes de cada push).
- [ ] Nada de datos de clientes ni de programas de bug bounty sin divulgación autorizada.
- [ ] Ninguna muestra de malware en el repo: sólo hashes y links a MalwareBazaar.
- [ ] Capturas sin datos personales (anonimizá usuarios y hostnames si hace falta).
- [ ] Si el contenido es ofensivo, agregá un *disclaimer* de uso autorizado en el README.
