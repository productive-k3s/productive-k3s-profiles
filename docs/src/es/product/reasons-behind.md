# Razones Del Diseño De `productive-k3s-profiles`

`productive-k3s-profiles` existe porque el contenido fuente de profiles/scenarios y la ejecución de runtime resuelven problemas distintos.

## Por qué no alcanza con `productive-k3s-core`

`productive-k3s-core` es el contrato de bootstrap para instalar y validar un stack basado en K3S.

Eso alcanza cuando:

- ya existe un host
- el operador puede trabajar directamente sobre esa máquina
- la topología del clúster es lo bastante simple como para armarla a mano

No alcanza cuando además necesitás estandarizar:

- cómo se provisionan las máquinas
- cómo se declaran los roles de nodos
- cómo se renderizan inventarios y hostnames
- cómo se secuencian los pasos de bootstrap multinodo
- cómo debería correrse una validación específica de infraestructura

## Por qué separar los profiles del engine de Infra

Este repositorio está centrado intencionalmente en el contenido fuente público y no en el engine de runtime.

La separación existe para que:

- cambiar un scenario público no fuerce un nuevo bundle de `productive-k3s-infra`
- `productive-k3s-infra` pueda validar compatibilidad contra este repo sin ser dueño de su contenido
- `productive-k3s-ops` pueda construir artefactos `profile.tgz` desde un repo fuente limpio

## Por qué los scenarios siguen siendo la unidad práctica de authoring

Aunque los artefactos publicados están orientados a profiles, la implementación sigue estando guiada por scenarios.

El objetivo de diseño es ofrecer caminos de despliegue que sean:

- reutilizables
- evaluables
- explícitos
- cercanos a lo que un equipo realmente ejecutaría

Por eso los entrypoints públicos son cosas como:

- clústeres locales con Multipass
- bootstrap on-premises por SSH
- un camino básico single-node sobre AWS

y no una colección de helpers desconectados.

## Por qué mantener capas compartidas por debajo

Aun cuando la interfaz pública está orientada a scenarios, la implementación igual necesita fronteras de reutilización.

Por eso el repositorio mantiene lógica fuente compartida en capas como:

- `ansible/roles/remote_cluster` para bootstrap y validación del lado SSH
- `opentofu/` para concerns de provisioning
- convenciones compartidas de testing y validación ejercitadas por CI

Esa separación hace más fácil evolucionar un camino público sin copiar y pegar todo en cada uno de los demás.

## Por qué importa la separación explícita por modos

Los modos `server`, `agent`, `stack` y `single-node` expuestos por `productive-k3s-core` son lo que vuelve realista la orquestación de infraestructura.

Le permiten a este repositorio:

1. crear o apuntar máquinas primero
2. ensamblar el clúster después
3. instalar el stack compartido al final

Sin esa separación, el authoring de scenarios públicos tendría que pelear contra un bootstrap más monolítico.

## Racional general

Tomado como conjunto, el repositorio busca ubicarse entre scripting crudo de infraestructura y una plataforma privada totalmente productizada.

Apunta a ofrecer:

- flujos de infraestructura que sigan siendo públicos y entendibles
- scenarios más realistas que ejemplos de juguete
- un puente estable hacia entornos K3S reales, remotos o multinodo
- una frontera de contenido limpia entre los repos OSS y Pro de profiles

## Ver también

- [Resumen del producto](index.md)
- [Cómo usar Productive K3S Profiles](how-to-use.md)
- [Relación con Productive K3S Infra y Core](productive-k3s-relationship.md)
