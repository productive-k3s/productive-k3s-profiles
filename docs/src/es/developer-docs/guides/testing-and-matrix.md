# Tests Y Matriz

`productive-k3s-profiles` ahora es dueño de un runner raíz de tests de contenido.

Ese runner valida los profiles y scenarios públicos contra una versión elegida del engine `productive-k3s-infra`, sin mover la responsabilidad de runtime fuera del repositorio de Infra.

## Superficies de validación

Ahora hay tres capas prácticas de validación:

- validación raíz de contenido en este repositorio
- targets `make` locales dentro de `scenarios/...`
- validación de packaging y catálogo en `productive-k3s-ops`

## Validación raíz de contenido

Usá la raíz del repositorio cuando quieras validar el árbol fuente público en sí:

```bash
make test-static PROFILE=multipass-1-server-2-agents
make test-contract PROFILE=aws-single-node-basic INFRA_VERSION=0.9.62-0.9.4
make test-live PROFILE=on-prem-basic INFRA_VERSION=0.9.62-0.9.4
make test-matrix
```

Suites soportadas:

- `static`: validación de forma y chequeos source-level
- `contract`: checks de compatibilidad contra el contrato del engine de Infra
- `live`: ejecución real del scenario contra una versión elegida del engine de Infra

Notas:

- `test-matrix` corre sólo `static + contract`
- `test-live` está pensado para validación manual antes del push
- si omites `INFRA_VERSION`, el runner resuelve la última release publicada de `productive-k3s-infra`
- si seteas `PRODUCTIVE_K3S_INFRA_REPO_DIR`, el runner usa ese checkout local de Infra en vez de clonar una release

## Por qué el runner delega en Infra

Los scenarios públicos siguen siendo contenido fuente. No son un engine de runtime autónomo.

Por eso el runner raíz de este repo delega intencionalmente la ejecución en `productive-k3s-infra`, porque el harness de Infra sigue siendo dueño de:

- la preparación del checkout temporal del scenario
- el overlay compartido de `ansible/`, `scripts/` y `tests/`
- los manifests de ejecución y los summaries de matriz

Eso mantiene limpia la frontera de responsabilidades:

- `productive-k3s-profiles` valida contenido público
- `productive-k3s-infra` valida compatibilidad del engine

## Validación local por scenario

Los targets locales de cada scenario siguen siendo útiles durante el authoring, por ejemplo:

```bash
make -C scenarios/local/multipass validate
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

Esos targets pertenecen al Makefile de cada scenario y siguen siendo source-oriented.

## Validación de packaging y release

Los artefactos publicados `profile.tgz` se construyen fuera de este repositorio mediante `productive-k3s-ops`.

Eso significa que cuestiones de packaging como:

- layout del paquete
- metadata del catálogo
- disponibilidad del artefacto publicado

pertenecen a `productive-k3s-ops`, no acá.

## Modelo de CI

El contrato de CI default esperado para este repositorio es:

1. correr `make test-matrix`
2. dejar `live` como validación manual, salvo que un maintainer quiera ejecutarla explícitamente

Eso da confianza estructural rápida en cada cambio sin obligar a correr Multipass o validaciones de runtime dependientes de cloud en cada pull request.

## Notas

!!! note
    `productive-k3s-infra` todavía necesita su propia lane de compatibilidad que clone este repositorio y demuestre que cambios del engine no rompen profiles públicos.
