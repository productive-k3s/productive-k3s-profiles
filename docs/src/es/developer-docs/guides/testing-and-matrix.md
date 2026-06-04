# Tests Y Matriz

`productive-k3s-profiles` es dueño del árbol fuente público de scenarios, pero todavía no tiene un harness raíz de tests de runtime equivalente al viejo repositorio de Infra.

## Qué se valida acá

Hoy las superficies prácticas de validación son:

- targets `make` locales de cada scenario dentro de `scenarios/...`
- validación de packaging en `productive-k3s-ops`
- validación de compatibilidad del engine en `productive-k3s-infra`, que clona este repositorio en un workspace temporal

## Validación local por scenario

Cuando un scenario expone targets locales de test o revisión, corrélos desde el directorio del scenario, por ejemplo:

```bash
make -C scenarios/local/multipass validate
make -C scenarios/local/multipass status
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

La superficie exacta es responsabilidad del Makefile de cada scenario.

## Validación de packaging y release

Los artefactos publicados `profile.tgz` se construyen fuera de este repositorio mediante `productive-k3s-ops`.

Eso significa que checks de packaging como:

- layout del paquete
- metadata del catálogo
- disponibilidad del artefacto publicado

pertenecen a `productive-k3s-ops`, no a este repositorio.

## Validación de compatibilidad con el engine

El engine de Infra todavía necesita demostrar que cambios de runtime no rompen profiles públicos.

El modelo esperado es:

1. `productive-k3s-infra` clona `productive-k3s-profiles` en un workspace temporal
2. los checks de integración del engine ejecutan contra ese checkout
3. un profile público roto sigue siendo un problema del profile, mientras que una interacción rota engine/profile se detecta en el CI de Infra

## Notas

!!! note
    Si más adelante este repositorio gana su propio harness raíz de tests, debería validar contenido fuente y contratos de scenarios, no duplicar las responsabilidades de ejecución de paquetes que ya pertenecen a `productive-k3s-infra`.
