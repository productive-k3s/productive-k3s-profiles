# Targets De Make

`make` es la interfaz principal de desarrollo y validación de contenido de este repositorio.

Los profiles publicados se consumen a través de `pk3s` o `productive-k3s-infra`, no mediante un CLI de runtime propio en este repo:

```bash
pk3s infra install multipass-1-server-2-agents
./productive-k3s-infra.sh profile install --tgz ./multipass-1-server-2-agents.tgz
```

Los targets raíz de abajo siguen siendo deliberadamente source-oriented y están orientados a desarrollo del repositorio, CI y authoring de scenarios.

## Targets de nivel raíz

| Target | Propósito |
| --- | --- |
| `make docs-build` | Construir el sitio MkDocs en modo estricto |
| `make docs-serve` | Servir la documentación localmente |
| `make docs-up` | Levantar el servidor de docs en background |
| `make docs-down` | Detener el servidor de docs y limpiar artefactos |
| `make test-static PROFILE=...` | Ejecutar sólo la suite `static` para el profile o scenario público elegido |
| `make test-contract PROFILE=...` | Ejecutar sólo la suite `contract` para el profile o scenario público elegido |
| `make test-live PROFILE=...` | Ejecutar sólo la suite `live` para el profile o scenario público elegido |
| `make test-matrix` | Ejecutar `static + contract` sobre todos los scenarios públicos |
| `make test-live-matrix` | Ejecutar `live` sobre todos los scenarios públicos |

Selectores soportados:

- `PROFILE=<nombre-del-profile-publicado>`
- `SCENARIO=<nombre-del-scenario-fuente>`

Ejemplos:

```bash
make test-static PROFILE=multipass-1-server-2-agents
make test-contract PROFILE=aws-single-node-basic INFRA_VERSION=0.9.62-0.9.4
make test-live PROFILE=on-prem-basic INFRA_VERSION=0.9.62-0.9.4
make test-static SCENARIO=onprem-basic
make test-matrix
```

## Selección del engine de Infra

El runner raíz de tests valida el contenido fuente contra una versión elegida de `productive-k3s-infra`.

Variables disponibles:

| Variable | Propósito |
| --- | --- |
| `INFRA_VERSION` | Clonar y usar una rama o tag publicada específica de `productive-k3s-infra` |
| `PRODUCTIVE_K3S_INFRA_REPO_DIR` | Usar un checkout local de Infra en vez de clonar una release |

Comportamiento:

- si `PRODUCTIVE_K3S_INFRA_REPO_DIR` está seteado, el checkout local tiene prioridad
- si omites `INFRA_VERSION`, el runner resuelve la última release publicada de `productive-k3s-infra`

Ejemplos:

```bash
make test-contract PROFILE=aws-single-node-basic INFRA_VERSION=0.9.62-0.9.4
PRODUCTIVE_K3S_INFRA_REPO_DIR=../productive-k3s-infra make test-static PROFILE=multipass-1-server-2-agents
```

## Targets locales por scenario

Los Makefiles source-oriented de cada scenario siguen exponiendo entrypoints locales, por ejemplo:

```bash
make -C scenarios/local/multipass validate
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

Esos targets siguen siendo útiles durante el authoring, pero no son lo mismo que el runner raíz de validación de contenido.

## Notas

!!! note
    `make test-matrix` es la superficie raíz de validación friendly para CI en este repositorio.

!!! note
    `make test-live` y `make test-live-matrix` están pensados para validación de runtime manejada por maintainers antes de un push o release.
