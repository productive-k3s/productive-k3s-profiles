# Organización Del Proyecto

El repositorio está organizado alrededor del árbol fuente público de profiles y scenarios de Productive K3S.

## Estructura de alto nivel

```text
productive-k3s-profiles/
  profiles/
    cloud/
    edge/
    local/
  scenarios/
    cloud/
      aws-single-node/
    edge/
      onprem-basic/
      onprem-basic-arm/
    local/
      multipass/
  docs/
  scripts/
```

## División de responsabilidades

- `profiles/`: defaults públicos de profiles y sidecars de metadata de paquete
- `scenarios/`: implementaciones públicas de scenarios, scripts auxiliares y Makefiles locales de scenario
- `docs/`: sitio público de documentación de profiles y scenarios
- `scripts/`: helpers locales del repositorio, como wrappers de documentación

## Artefactos generados

Cada scenario puede escribir metadata generada bajo su propio directorio `generated/`, normalmente incluyendo cosas como:

- `cluster.json`
- `hosts.yml`
- state local específico del provider o inputs renderizados

Estos artefactos forman parte del flujo orientado a código fuente porque exponen la vista resuelta en runtime del scenario.

## Notas

!!! note
    La ejecución pública de paquetes no ocurre en este repositorio. Los operadores consumen los artefactos publicados mediante `pk3s` o `productive-k3s-infra`.

!!! note
    La compatibilidad con el engine de Infra se valida desde el CI del engine clonando este repositorio en un workspace temporal.
