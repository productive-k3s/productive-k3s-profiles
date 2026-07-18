---
title: "Productive K3S Profiles"
template: "home.html"
hide:
  - navigation
  - toc
eyebrow: "Curated deployment solutions ready to use"
eyebrow_es: "Soluciones curadas de despliegue listas para usar"
hero_title: "Productive K3S Profiles"
hero_title_es: "Productive K3S Profiles"
lead: "Productive K3S Profiles gives you curated deployment solutions that Productive K3S Infra can execute over different platforms."
lead_es: "Productive K3S Profiles te da soluciones curadas de despliegue que Productive K3S Infra puede ejecutar sobre distintas plataformas."
sublead: "Use this repository to choose recommended solution paths such as existing on-prem infrastructure over SSH or a simple AWS single-node evaluation, while Infra keeps the orchestration layer and Core keeps the base installation contract."
sublead_es: "Usá este repositorio para elegir caminos recomendados de solución como infraestructura on-prem existente vía SSH o una evaluación simple de AWS single-node, mientras Infra mantiene la capa de orquestación y Core el contrato base de instalación."
primary_label: "View on GitHub"
primary_label_es: "Ver en GitHub"
primary_url: "https://github.com/productive-k3s/productive-k3s-profiles"
secondary_label: "Open README"
secondary_label_es: "Abrir README"
secondary_url: "https://github.com/productive-k3s/productive-k3s-profiles/blob/main/README.md"
card_title: "What it does"
card_title_es: "Qué hace"
card_items:
  - Defines curated deployment solutions ready to execute through Infra
  - Packages platform decisions, defaults, and helper assets into reusable paths
  - Keeps the public solution catalog separate from the deployment engine
card_items_es:
  - Define soluciones curadas de despliegue listas para ejecutarse con Infra
  - Empaqueta decisiones de plataforma, defaults y assets auxiliares en caminos reutilizables
  - Mantiene separado el catálogo público de soluciones respecto del engine de despliegue
why_title: "Why it exists"
why_title_es: "Por qué existe"
why_options:
  - label: "CURATED PATHS"
    text: "Teams want ready-to-use solution paths instead of rebuilding the same deployment decisions every time."
  - label: "SEPARATE LAYERS"
    text: "The solutions should evolve without forcing the deployment engine and the base installation layer to absorb all the change."
why_options_es:
  - label: "CAMINOS CURADOS"
    text: "Los equipos quieren caminos de solución listos para usar en lugar de reconstruir siempre las mismas decisiones de despliegue."
  - label: "CAPAS SEPARADAS"
    text: "Las soluciones deben poder evolucionar sin obligar al engine de despliegue ni a la capa base de instalación a absorber todos los cambios."
bridge_note: "Productive K3S Profiles is the curated solution layer in the ecosystem."
bridge_note_es: "Productive K3S Profiles es la capa de soluciones curadas dentro del ecosistema."
bridge_points:
  - Keep Core as the base installation contract
  - Keep Infra as the orchestration engine
  - Let curated solution paths evolve on their own cadence
bridge_points_es:
  - Mantener a Core como contrato base de instalación
  - Mantener a Infra como engine de orquestación
  - Dejar que los caminos curados de solución evolucionen a su propio ritmo
scenarios_title: "Recommended paths"
scenarios_title_es: "Caminos recomendados"
scenarios:
  - "On-prem basic: deploy over existing hosts reachable through SSH"
  - "AWS single-node: evaluate a simple cloud path on EC2"
  - "Multipass: validate a local multi-node path before going further"
  - "ARM path: keep an explicit public route for smaller ARM targets"
scenarios_es:
  - "On-prem basic: desplegá sobre hosts existentes alcanzables por SSH"
  - "AWS single-node: evaluá un camino cloud simple sobre EC2"
  - "Multipass: validá un camino local multinodo antes de avanzar"
  - "ARM path: mantené una ruta pública explícita para objetivos ARM más chicos"
principles_title: "Design principles"
principles_title_es: "Principios de diseño"
principles:
  - title: "Curated over ad hoc"
    text: "publish solution paths that feel ready to use, not disconnected fragments"
  - title: "Keep orchestration separate"
    text: "Infra executes the solutions, but does not own the solution catalog"
  - title: "Keep the contracts visible"
    text: "defaults, helper scripts, and packaging metadata should remain reviewable"
principles_es:
  - title: "Curado por encima de ad hoc"
    text: "publicá caminos de solución que se sientan listos para usar, no fragmentos desconectados"
  - title: "Separá la orquestación"
    text: "Infra ejecuta las soluciones, pero no posee el catálogo de soluciones"
  - title: "Dejá visibles los contratos"
    text: "defaults, scripts auxiliares y metadata de empaquetado deben seguir siendo revisables"
environments_title: "How it fits"
environments_title_es: "Dónde encaja"
environments:
  - Start here when you want to choose a curated solution path
  - Continue to Infra when you want that path executed on a platform
  - Continue to CLI when you want the simplest and recommended operator interface
  - Remember that this repository owns the solution definitions, not the deployment engine
environments_es:
  - Empezá acá cuando quieras elegir un camino curado de solución
  - Seguí por Infra cuando quieras que ese camino se ejecute sobre una plataforma
  - Seguí por CLI cuando quieras la interfaz operativa más simple y recomendada
  - Recordá que este repositorio posee las definiciones de solución, no el engine de despliegue
not_title: "What it is not"
not_title_es: "Qué no es"
not_items:
  - Not the deployment engine
  - Not the base Kubernetes installation layer
  - Not a claim that every public path is already the final form for every production need
not_items_es:
  - No es el engine de despliegue
  - No es la capa base de instalación Kubernetes
  - No afirma que cada camino público ya sea la forma final para toda necesidad de producción
not_note: "It is the curated solution layer for Productive K3S deployments."
not_note_es: "Es la capa de soluciones curadas para los despliegues de Productive K3S."
---
