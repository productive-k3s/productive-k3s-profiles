---
title: "Productive K3S Profiles"
template: "home.html"
hide:
  - navigation
  - toc
eyebrow: "Public profile and scenario sources for Productive K3S"
eyebrow_es: "Fuentes públicas de profiles y scenarios de Productive K3S"
hero_title: "Productive K3S Profiles"
hero_title_es: "Productive K3S Profiles"
lead: "Productive K3S Profiles is the public source-of-truth repository for profile and scenario content that later becomes published self-contained profile artifacts."
lead_es: "Productive K3S Profiles es el repositorio fuente público para el contenido de profiles y scenarios que luego se publica como artefactos autocontenidos."
sublead: "It owns authoring, defaults, helper scripts, and scenario contracts, while Productive K3S Infra remains the runtime engine and Productive K3S Core remains the cluster bootstrap layer."
sublead_es: "Es dueño del authoring, defaults, scripts auxiliares y contratos de scenarios, mientras que Productive K3S Infra sigue siendo el engine de runtime y Productive K3S Core la capa de bootstrap del clúster."
primary_label: "View on GitHub"
primary_label_es: "Ver en GitHub"
primary_url: "https://github.com/productive-k3s/productive-k3s-profiles"
secondary_label: "Open README"
secondary_label_es: "Abrir README"
secondary_url: "https://github.com/productive-k3s/productive-k3s-profiles/blob/main/README.md"
card_title: "What it does"
card_title_es: "Qué hace"
card_items:
  - Defines public profile defaults and package metadata
  - Owns public scenario implementations and helper assets
  - Validates scenario content before it becomes a published profile artifact
card_items_es:
  - Define defaults públicos de profiles y metadata de paquete
  - Es dueño de las implementaciones públicas de scenarios y sus assets auxiliares
  - Valida el contenido de scenarios antes de convertirlo en artefactos de profile publicados
why_title: "Why it exists"
why_title_es: "Por qué existe"
why_options:
  - label: "DIY INFRASTRUCTURE"
    text: "Raw infrastructure scripts are flexible, but hard to reuse, review, and publish consistently."
  - label: "ENGINE OWNERSHIP"
    text: "Bundling all public scenarios into the runtime engine makes every scenario change heavier than it needs to be."
why_options_es:
  - label: "INFRAESTRUCTURA DIY"
    text: "Los scripts crudos de infraestructura son flexibles, pero difíciles de reutilizar, revisar y publicar de forma consistente."
  - label: "OWNERSHIP DEL ENGINE"
    text: "Meter todos los scenarios públicos dentro del engine de runtime vuelve cada cambio más pesado de lo necesario."
bridge_note: "Productive K3S Profiles provides the content layer: repeatable, reviewable source material that the Infra engine can execute."
bridge_note_es: "Productive K3S Profiles aporta la capa de contenido: material fuente repetible y auditable que luego puede ejecutar el engine de Infra."
bridge_points:
  - Keep Productive K3S Core as the bootstrap contract
  - Keep Productive K3S Infra as the runtime engine
  - Evolve scenarios without forcing engine bundle releases
bridge_points_es:
  - Mantener Productive K3S Core como contrato de bootstrap
  - Mantener Productive K3S Infra como engine de runtime
  - Evolucionar scenarios sin forzar releases del bundle del engine
scenarios_title: "Target scenarios"
scenarios_title_es: "Escenarios objetivo"
scenarios:
  - Local multi-node validation with Multipass
  - Existing hosts reachable over SSH
  - Basic single-node cloud evaluation on AWS
  - Teams that want reusable source content before their own hardening
scenarios_es:
  - Validación local multinodo con Multipass
  - Hosts existentes alcanzables por SSH
  - Evaluación cloud básica de nodo único en AWS
  - Equipos que quieren contenido reutilizable antes de su propio hardening
principles_title: "Design principles"
principles_title_es: "Principios de diseño"
principles:
  - title: "Profiles and scenarios first"
    text: "the public source tree should describe real deployment paths, not disconnected fragments"
  - title: "Keep runtime separate"
    text: "the execution engine and the source tree should evolve independently"
  - title: "Stay explicit"
    text: "defaults, helper scripts, and package metadata should be obvious to review"
principles_es:
  - title: "Profiles y scenarios primero"
    text: "el árbol fuente público debe describir caminos reales de despliegue, no fragmentos desconectados"
  - title: "Separar el runtime"
    text: "el engine de ejecución y el árbol fuente deben poder evolucionar por separado"
  - title: "Mantenerlo explícito"
    text: "defaults, scripts auxiliares y metadata de paquete deben ser fáciles de revisar"
environments_title: "Supported source coverage"
environments_title_es: "Cobertura fuente soportada"
environments:
  - Multipass on a local development machine
  - Existing Ubuntu or Debian hosts reachable over SSH
  - Basic AWS EC2 single-node setups
  - Source trees later consumed by `k3s-ops`, `productive-k3s-infra`, and `pk3s`
environments_es:
  - Multipass en una máquina de desarrollo local
  - Hosts Ubuntu o Debian existentes alcanzables por SSH
  - Setups básicos de nodo único sobre AWS EC2
  - Árboles fuente luego consumidos por `k3s-ops`, `productive-k3s-infra` y `pk3s`
not_title: "What it is not"
not_title_es: "Qué no es"
not_items:
  - Not a replacement for Productive K3S Core
  - Not the package execution engine
  - Not a promise that every public scenario is production-ready as-is
not_items_es:
  - No reemplaza a Productive K3S Core
  - No es el engine que ejecuta paquetes
  - No promete que cada scenario público esté listo para producción tal como viene
not_note: "It is the public content layer for Productive K3S infrastructure profiles."
not_note_es: "Es la capa pública de contenido para los profiles de infraestructura de Productive K3S."
---
