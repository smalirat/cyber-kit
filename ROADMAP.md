# Roadmap del Cyber Kit

> Cómo usar este documento: primero leé la **recomendación de ramas** y las **fases**. Después elegí el siguiente proyecto de la tabla de su rama. Cada proyecto tiene una etiqueta de **tipo** para ir alternando lo que construís.

## 1. Tipos de proyecto (para alternar)

| Etiqueta | Tipo | Qué producís | Qué muestra |
|---|---|---|---|
| `LAB` | Laboratorio / write-up | Entorno reproducible + paso a paso | Metodología, que sabés hacerlo con tus manos |
| `TOOL` | Herramienta propia | Código tuyo con tests y docs | Que programás y automatizás |
| `DETECT` | Detecciones como código | Reglas versionadas + CI + cobertura | Ingeniería, no sólo "clicks" en consola |
| `REPORT` | Informe profesional | PDF/MD tipo pentest, incidente o threat report | Comunicación con cliente o dirección |
| `OSS` | Código de terceros | Integrar, extender o contribuir a herramientas existentes | Que sabés leer código ajeno y trabajar en comunidad |

**Regla de alternancia:** nunca hagas dos proyectos seguidos del mismo tipo. Una secuencia sana sería `LAB → DETECT → REPORT → TOOL → OSS → LAB`...

## 2. Recomendación de ramas

| Prioridad | Rama | Por qué en ese orden |
|---|---|---|
| **0. Base** | 0. Homelab | Sin lab no hay dónde atacar ni qué defender. Hacé 0.1 a 0.3 al principio y sumá 0.4 y 0.5 cuando otra rama lo pida. |
| **1. Empezar** | 2. Defensiva (Blue Team) | Es donde más puestos junior hay (analista SOC o detection engineer). Además te da la telemetría que después vas a atacar. |
| **2. Empezar en paralelo** | 1. Ofensiva (Red Team) | Usás el mismo lab: atacás, mirás qué registró el SIEM y escribís la detección. Ese ciclo *purple team* es lo que más diferencia tu portfolio. |
| **3. Después** | 4. AppSec / DevSecOps | Tiene mucha demanda y te luce si programás. Conviene llegar sabiendo cómo se explota una app (rama 1). |
| **4. Más adelante** | 3. Forense y análisis | Necesita bases de sistemas operativos y de lo que ya viste en Blue. La curva de entrada es más alta. |
| **5. Transversal / al final** | 6. GRC | No lo ignores: uno o dos proyectos chicos alcanzan para mostrar que entendés riesgo y negocio. Reutilizá tus labs como objeto de análisis. |
| **Continuo** | 5. Infraestructura | Hardening, cloud y contenedores se van sumando cuando otra rama lo necesite. |

### Fases sugeridas

| Fase | Meses | Foco | Proyectos | Hito de portfolio |
|---|---|---|---|---|
| 0 | 0–2 | Homelab | 0.1, 0.2, 0.3 | Lab con red segmentada, AD y SIEM, levantable con un comando |
| 1 | 2–4 | Blue + primeros ataques | 0.4, 2.1, 1.1, 2.2 | Casos de uso SOC + reglas Sigma con CI |
| 2 | 4–7 | Purple team | 1.2, 1.4, 2.3 | Informe de pentest + kill chain de AD con sus detecciones |
| 3 | 7–10 | AppSec | 4.1, 4.2, 4.3, 5.1 | Pipeline DevSecOps sobre una app propia |
| 4 | 10–13 | Profundizar | 2.4, 3.1, 3.2, 1.5, 0.5 | Herramienta propia publicada + informe de malware |
| 5 | 13+ | Especialización | 4.4, 4.5, 5.2, 5.3, 5.4, 6.x, 3.3–3.4, 2.5 | Elegís un perfil (ver sección 4) |

---

## 3. Proyectos por rama

Dificultad: 🟢 básica · 🟡 intermedia · 🟠 intermedia-avanzada · 🔴 avanzada

> ⚠️ **Ética y legalidad:** todo lo ofensivo se hace sólo contra tu lab, contra plataformas que lo autorizan (HTB, THM, PortSwigger, CyberDefenders) o dentro del alcance escrito de un programa de bug bounty. Si una plataforma prohíbe publicar soluciones de máquinas activas, publicá sólo las retiradas.

### Rama 0 — Homelab (la plataforma) · empezar acá

Vive en [`homelab/`](homelab/). Todo lo demás corre encima.

| # | Dif. | Tipo | Proyecto | Objetivo | Herramientas | Entregable | Qué demuestra |
|---|---|---|---|---|---|---|---|
| 0.1 | 🟢 | `LAB` | **Red segmentada y router-firewall** | 4 segmentos (corp, soc, dmz, attacker) detrás de un router con política explícita | VirtualBox, Vagrant, Ubuntu, nftables, dnsmasq | `lab.yml` + Vagrantfile + diagrama + tests automáticos de la política de red | Redes, firewalling, infraestructura como código, testing de infraestructura |
| 0.2 | 🟡 | `LAB` | **Dominio Active Directory** | DC y estación unidos a `lab.local`, con OUs, usuarios, GPOs y debilidades que se activan con un flag | Windows Server 2022 y Windows 10/11 (evaluación), PowerShell, BadBlood | Provisioning automático + documento de "vulnerabilidades sembradas" | Administración Windows y AD (la base de 1.4 y 2.1) |
| 0.3 | 🟡 | `LAB` | **Stack de monitoreo** | Que todo el lab mande telemetría a un SIEM | Wazuh, Sysmon, auditd, logs de nftables y dnsmasq, Suricata (opcional) | Agentes desplegados automáticamente + verificación de ingesta | La base del Blue Team: 2.1 se construye encima |
| 0.4 | 🟡 | `OSS` | **Zona atacante y objetivos** | Kali + un catálogo de apps vulnerables en contenedores | Kali, Docker Compose, Juice Shop, DVWA, crAPI, VAmPI | Catálogo levantable por perfil + guía de alcance | Integración de herramientas de terceros |
| 0.5 | 🟠 | `TOOL` | **Plataforma de lab** | Golden images, snapshots y reset, perfiles, CI | Packer, Ansible, GitHub Actions | CLI `lab` (up/reset/snapshot/status) + imágenes propias + CI que valida la configuración | Automatización de plataforma, mentalidad DevOps |

### Rama 5 — Infraestructura, identidad y sistemas

| # | Dif. | Tipo | Proyecto | Objetivo | Herramientas | Entregable | Qué demuestra |
|---|---|---|---|---|---|---|---|
| 5.1 | 🟡 | `TOOL` | **Hardening automatizado con CIS** | Llevar Linux y Windows a un benchmark CIS y medirlo | Ansible, Lynis, OpenSCAP, CIS-CAT Lite, PowerShell DSC | Playbooks + informe con el score antes y después | Que el hardening es medible y repetible, no un checklist manual |
| 5.2 | 🟡 | `OSS` | **Seguridad de contenedores y K8s** | Escanear, aplicar políticas y detectar en runtime en un clúster local | kind/k3s, Trivy, kube-bench, Kyverno, Falco | Políticas versionadas + reglas Falco propias + write-up de un ataque mitigado | Seguridad cloud-native, uso real de herramientas CNCF |
| 5.3 | 🟠 | `LAB` | **Auditoría y remediación en AWS** | Desplegar un escenario vulnerable, auditarlo y corregirlo en código | CloudGoat, Prowler, ScoutSuite, Pacu, Terraform | Hallazgos + PR de Terraform que los corrige + informe | IAM en la nube, gestión de postura (CSPM), pensar en IaC |
| 5.4 | 🔴 | `LAB` | **Identidad y PKI** | SSO con MFA para los servicios del lab y mTLS entre servicios | Keycloak/Authentik, step-ca, OAuth2/OIDC, rotación de certificados | Arquitectura de identidad + configuración + análisis de amenazas | IAM, criptografía aplicada, Zero Trust con fundamentos |

### Rama 2 — Defensiva (Blue Team) · empezar acá

| # | Dif. | Tipo | Proyecto | Objetivo | Herramientas | Entregable | Qué demuestra |
|---|---|---|---|---|---|---|---|
| 2.1 | 🟢 | `LAB` | **Operación SOC sobre el SIEM** | Usar el SIEM de 0.3 como analista: casos de uso, dashboards, triage | Wazuh, Sysmon (config de Olaf Hartong o SwiftOnSecurity), ATT&CK | Dashboards + 10 alertas documentadas con su triage | Que sabés de dónde sale la telemetría y qué hacer con una alerta |
| 2.2 | 🟡 | `DETECT` | **Detection-as-Code** | Reglas Sigma mapeadas a ATT&CK, probadas con ataques reales | Sigma, sigma-cli/pySigma, Atomic Red Team, GitHub Actions, ATT&CK Navigator | Repo de reglas + CI que las valida y convierte + mapa de cobertura | Detection engineering moderno (de los perfiles más buscados) |
| 2.3 | 🟡 | `REPORT` | **Respuesta a incidente simulada** | Llevar un caso de punta a punta, de la alerta al cierre | NIST SP 800-61r3, TheHive + Cortex o Shuffle (SOAR), playbooks | Playbooks + informe de incidente + timeline + lecciones aprendidas | Procesos de IR y comunicación bajo presión |
| 2.4 | 🟠 | `LAB` | **Threat hunting por hipótesis** | Cazar TTPs en datasets públicos sin depender de alertas | OTRF Security-Datasets, Splunk BOTS, KQL/SPL/EQL, Jupyter | Un hunt por hipótesis: pregunta, consulta, hallazgo y regla resultante | Pensamiento analítico y dominio de lenguajes de consulta |
| 2.5 | 🔴 | `TOOL` | **Pipeline de threat intel** | Ingerir feeds, enriquecer IOCs y producir inteligencia accionable | Python, MISP, abuse.ch, AlienVault OTX, STIX 2.1/TAXII | Herramienta + un threat report de una campaña real | CTI, programación y redacción de inteligencia |

> Gestión de vulnerabilidades: sumala dentro de 2.1 o 5.1 (OpenVAS/Greenbone + priorización con EPSS/KEV) en vez de hacer un proyecto aparte.

### Rama 1 — Ofensiva (Red Team) · empezar en paralelo

| # | Dif. | Tipo | Proyecto | Objetivo | Herramientas | Entregable | Qué demuestra |
|---|---|---|---|---|---|---|---|
| 1.1 | 🟢 | `LAB` | **Write-ups con metodología** | Resolver máquinas retiradas o labs documentando el *porqué* | HTB/THM, PortSwigger Academy, Nmap, Burp Suite, ffuf | Repo agrupado de write-ups con una plantilla común | Constancia y metodología (no sólo el flag) |
| 1.2 | 🟡 | `REPORT` | **Pentest completo de una app vulnerable** | Hacer un pentest web como si fuera para un cliente | OWASP Juice Shop o DVWA, Burp, sqlmap, Nuclei, OWASP WSTG, CVSS 4.0 | Informe profesional (ver la plantilla) con resumen ejecutivo | Que podés entregar un informe vendible |
| 1.3 | 🟡 | `LAB` | **Phishing simulado autorizado** | Armar una campaña contra cuentas de prueba del lab y medirla | GoPhish, MailHog, SPF/DKIM/DMARC | Campaña + métricas + recomendaciones de concientización (conecta con la rama 6) | Ingeniería social con criterio ético y foco defensivo |
| 1.4 | 🟠 | `LAB`+`DETECT` | **Kill chain en Active Directory (purple)** | Comprometer el dominio y escribir la detección de cada paso | AD del homelab (0.2) o GOAD, BloodHound CE, Impacket, NetExec, Rubeus, Certipy | Kill chain paso a paso: técnica ATT&CK → evidencia en el SIEM → regla Sigma | Lo más pedido en red team, y encima con mirada defensiva |
| 1.5 | 🔴 | `TOOL` | **Herramienta de recon propia** | Automatizar el reconocimiento de un alcance autorizado | Python o Go, subfinder/httpx (como librerías o wrappers), templates propios de Nuclei | Herramienta con tests, CI, releases y documentación | Programación ofensiva y diseño de herramientas |

> Bug bounty: tomalo como actividad continua, no como proyecto. Publicá sólo reportes ya divulgados (*disclosed*) y con permiso del programa.

### Rama 4 — Seguridad de aplicaciones y desarrollo

| # | Dif. | Tipo | Proyecto | Objetivo | Herramientas | Entregable | Qué demuestra |
|---|---|---|---|---|---|---|---|
| 4.1 | 🟢 | `REPORT` | **Modelado de amenazas** | Modelar con STRIDE una app propia (o la del 4.2) | OWASP Threat Dragon, diagramas de flujo de datos, STRIDE, OWASP ASVS | Documento con DFD, amenazas, riesgo y backlog de mitigaciones | *Security by design*: pensar antes de escanear |
| 4.2 | 🟡 | `TOOL` | **Pipeline DevSecOps** | Que la CI bloquee código inseguro en una app propia | GitHub Actions, Semgrep (con reglas propias), Gitleaks, Trivy, OWASP ZAP, Dependabot | Repo con pipeline, resultados SARIF y política de *quality gates* | Que integrás seguridad en el ciclo de desarrollo |
| 4.3 | 🟡 | `LAB` | **Seguridad de APIs** | Explotar y después **corregir** el OWASP API Top 10 | crAPI o VAmPI, Postman, Burp, tests automatizados | Informe + PR con los fixes + tests de regresión | Que sabés romper *y* arreglar |
| 4.4 | 🟠 | `OSS` | **Supply chain segura** | Publicar un artefacto con SBOM, firma y procedencia verificable | Syft/CycloneDX, Sigstore cosign, SLSA, OpenSSF Scorecard | Release firmado + instrucciones para verificarlo + score de Scorecard | Supply chain, un tema muy actual |
| 4.5 | 🔴 | `LAB`+`TOOL` | **Red teaming de LLMs** | Construir una app RAG vulnerable, atacarla y defenderla | OWASP Top 10 for LLM Apps, garak, promptfoo, PyRIT, guardrails | App + suite de evaluaciones en CI + informe con métricas antes y después | Seguridad de IA, un nicho emergente con poca competencia |

### Rama 3 — Forense y análisis (fase 4)

| # | Dif. | Tipo | Proyecto | Objetivo | Herramientas | Entregable | Qué demuestra |
|---|---|---|---|---|---|---|---|
| 3.1 | 🟡 | `REPORT` | **Forense de disco y memoria** | Reconstruir un incidente a partir de evidencia | Volatility 3, Autopsy, KAPE, Eric Zimmerman Tools, plaso; casos de CyberDefenders | Informe forense con timeline y cadena de custodia | Metodología DFIR y rigor con la evidencia |
| 3.2 | 🟡 | `REPORT`+`DETECT` | **Análisis de malware** | Análisis estático y dinámico de una muestra real **en una VM aislada** | REMnux, FLARE-VM, CAPE Sandbox, muestras de MalwareBazaar, YARA | Malware report + reglas YARA + IOCs en formato STIX | Análisis de malware con salida accionable |
| 3.3 | 🔴 | `LAB` | **Ingeniería inversa** | Resolver crackmes y documentar el razonamiento | Ghidra, x64dbg, crackmes.one, scripts de Ghidra en Python | Write-ups + scripts de automatización | Bajo nivel, ensamblador, paciencia |
| 3.4 | 🔴 | `OSS` | **Artefactos de triage** | Extender una herramienta DFIR conocida con artefactos propios | Velociraptor (VQL), Sigma, Hayabusa | Artefactos publicados (idealmente con un PR aceptado upstream) | Contribución a la comunidad DFIR |

### Rama 6 — GRC · transversal y al final

| # | Dif. | Tipo | Proyecto | Objetivo | Herramientas | Entregable | Qué demuestra |
|---|---|---|---|---|---|---|---|
| 6.1 | 🟢 | `REPORT` | **Evaluación de riesgos del homelab** | Tratar tu lab como si fuera una organización | NIST CSF 2.0, ISO/IEC 27005, matriz de riesgo | Registro de riesgos + plan de tratamiento | Que traducís técnica a riesgo de negocio |
| 6.2 | 🟡 | `REPORT` | **Gap analysis para una pyme ficticia** | Comparar el estado actual contra ISO 27001:2022 o CIS Controls v8 | Anexo A de ISO 27001, CIS Controls v8, plantillas de políticas | Gap analysis + 3 políticas (contraseñas, backup, uso aceptable) + roadmap | Lenguaje de auditoría y cumplimiento |
| 6.3 | 🟡 | `REPORT` | **Privacidad y continuidad** | Hacer una DPIA y un plan BCP/DRP con ejercicio de mesa (*tabletop*) | Ley 25.326 (AR), RGPD, ISO 22301 | DPIA + BCP + informe del tabletop | Privacidad y resiliencia |
| 6.4 | 🟠 | `TOOL` | **Compliance-as-Code** | Generar evidencia de controles automáticamente desde tus labs | Prowler (frameworks de compliance), OpenSCAP, Python | Reporte automático de controles → evidencia mapeada a frameworks | Un perfil híbrido GRC + ingeniería, escaso y bien pago |

---

## 4. Perfiles de salida (para la fase 5)

| Perfil objetivo | Proyectos estrella para fijar arriba del portfolio |
|---|---|
| Analista SOC / Detection Engineer | 2.2, 1.4, 2.4, 2.3 |
| Pentester | 1.2, 1.4, 1.5, 4.3 |
| AppSec / DevSecOps | 4.2, 4.4, 4.1, 4.5 |
| Cloud Security | 5.3, 5.2, 4.2, 6.4 |
| Plataforma / Infra Security | 0.5, 0.1, 5.1, 5.2 |
| DFIR | 3.1, 3.2, 2.3, 3.4 |
