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

Los defaults de profile y la metadata de paquete deben mantenerse consistentes.
Todo input requerido declarado como `source: package-default` en un sidecar
`*.package.yaml` debe tener un valor no vacío en el `.env` correspondiente,
porque ese `.env` se convierte en el contrato de defaults del paquete. Los
valores específicos de una instalación deben marcarse como `source:
local-override` y ser provistos por el operador mediante `--env-file`.

Durante la generación de release, los profiles empaquetados también declaran el
path del scenario dentro del paquete y los targets de ejecución en
`profile.yaml`. Infra consume esa metadata en vez de hardcodear nombres de
scenarios de este repositorio.

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
