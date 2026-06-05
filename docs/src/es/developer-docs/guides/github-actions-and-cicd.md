# Flujo De CI/CD

`productive-k3s-profiles` usa por default un modelo liviano de CI.

La idea es validar la estructura del contenido público y los contratos de compatibilidad con el engine en cada cambio, sin obligar a correr validaciones live de runtime en cada pull request.

## Qué existe hoy

- targets raíz determinísticos de `make` para docs y validación de contenido
- suites raíz `static`, `contract` y `live`
- un runner local del repositorio que delega la ejecución en una versión elegida de `productive-k3s-infra`
- un workflow de CI default que ejecuta `make test-matrix`
- un workflow separado de docs para el sitio publicado

## Contrato de CI default

El camino de CI default para este repositorio es:

1. correr `make test-matrix`
2. dejar `live` como validación manual, salvo que un maintainer decida ejecutarla explícitamente

En la práctica eso significa:

- `static` corre en CI
- `contract` corre en CI
- `live` queda como validación manual antes de push o release

Eso mantiene el CI rápido y reproducible, y al mismo tiempo permite a los maintainers ejercitar el camino completo de runtime cuando haga falta.

## Workflow de tests actual

El repositorio incluye `.github/workflows/tests.yml`.

Hoy ese workflow:

1. hace checkout del repositorio
2. instala OpenTofu
3. corre `make test-matrix INFRA_VERSION=development`

La matriz acá es intencionalmente content-focused:

- valida todos los scenarios públicos
- usa la versión elegida del engine de Infra como dueño del contrato
- no corre la suite live completa por default

## Validación live manual

Los maintainers pueden correr validación live local antes de pushear cambios sensibles en scenarios, por ejemplo:

```bash
make test-live PROFILE=multipass-1-server-2-agents INFRA_VERSION=0.9.62-0.9.4
make test-live PROFILE=on-prem-basic INFRA_VERSION=0.9.62-0.9.4
make test-live-matrix INFRA_VERSION=0.9.62-0.9.4
```

Como esos flujos pueden requerir Multipass, reachability por SSH o credenciales de cloud, intencionalmente no se exigen en cada corrida de CI.

## Relación con el CI de Infra

Este repositorio valida contenido público desde el lado del contenido.

`productive-k3s-infra` todavía necesita su propia lane de compatibilidad que clone este repositorio y demuestre que cambios del engine no rompen profiles públicos.

Eso da dos direcciones complementarias:

- `profiles -> infra`: ¿este contenido satisface el contrato esperado por el engine?
- `infra -> profiles`: ¿un cambio del engine rompió contenido público existente?

## Notas

!!! note
    Los checks de packaging y publicación siguen perteneciendo a `productive-k3s-ops`, no a este repositorio.
