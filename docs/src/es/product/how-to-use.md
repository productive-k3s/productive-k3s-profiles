# Cómo Usar Productive K3S Profiles

`productive-k3s-profiles` es el repositorio fuente público del contenido de profiles y scenarios. En el flujo normal para usuarios finales, los operadores consumen `profile.tgz` publicados a través de `pk3s` o `productive-k3s-infra`; no ejecutan este repo directamente.

## Elegí el profile correcto

- `multipass-1-server-2-agents`: clúster local de tres nodos sobre VMs de Multipass
- `on-prem-basic` / `on-prem-arm`: bootstrap de hosts existentes por `SSH`
- `aws-single-node-basic`: provisioning de una instancia `EC2` con `OpenTofu` y bootstrap remoto

## Entendé la separación de responsabilidades

Cada scenario de este repositorio define el comportamiento de infraestructura alrededor del clúster, mientras que:

- `productive-k3s-core` sigue siendo responsable del bootstrap del clúster
- `productive-k3s-infra` sigue siendo responsable de la ejecución de paquetes, el state, la telemetría y el dispatch de runtime

En la práctica eso significa que `productive-k3s-profiles` es dueño de:

- creación de hosts o selección de hosts existentes
- inventarios generados y metadata del clúster
- orquestación de las fases `server`, `agent` y `stack` cuando el scenario lo necesita
- validación específica del scenario

`productive-k3s-infra` después consume este contenido:

- indirectamente, una vez que `productive-k3s-ops` construyó un `profile.tgz`
- o directamente en flujos de desarrollo/CI cuando usa un clon temporal de este repositorio para validar compatibilidad del engine

## Engine opcional de instalación de K3S

El engine por default sigue siendo el camino nativo de bootstrap de Productive K3S.

Los usuarios avanzados también pueden optar por:

```bash
PRODUCTIVE_K3S_ENGINE=k3sup
```

Eso está documentado intencionalmente como experimental.

Por qué existe:

- para mostrar que `k3sup` puede complementar a `productive-k3s-core`
- para permitir que usuarios avanzados experimenten con las mismas decisiones opinionadas de plataforma de Productive K3S usando un backend de instalación de K3S que ya conocen

Qué no significa:

- `k3sup` no es el producto
- `k3sup` no reemplaza el contrato de bootstrap de Productive K3S
- `k3sup` no amplía la matriz pública de soporte más allá de la cobertura documentada de VMs, sistemas operativos y scenarios del repositorio

## Consumí profiles publicados

El camino normal para usuarios es package-first:

```bash
pk3s profile show multipass-1-server-2-agents
pk3s infra install multipass-1-server-2-agents
pk3s infra install aws-single-node-basic --env-file ./aws.env
```

Si trabajás directo con el engine de runtime, la interfaz equivalente es `productive-k3s-infra`:

```bash
./productive-k3s-infra.sh profile validate --tgz ./multipass-1-server-2-agents.tgz
./productive-k3s-infra.sh profile install --tgz ./aws-single-node-basic.tgz --env-file ./aws.env
```

El `profile.env` embebido en un `profile.tgz` público se trata como defaults del paquete. Los valores específicos de instalación siguen perteneciendo a la máquina que invoca mediante `--env-file`, especialmente para targets cloud y on-prem.

## Elegí el modo fuente de Productive K3S Core

La mayoría de los scenarios públicos soportan dos modos fuente:

- `PRODUCTIVE_K3S_SOURCE=local`: empaqueta un checkout local hermano de `productive-k3s-core`
- `PRODUCTIVE_K3S_SOURCE=remote`: descarga un bundle publicado por GitHub Release

Si se usa `remote`, `PRODUCTIVE_K3S_VERSION` puede fijar una versión específica. Si se omite, el scenario resuelve el último release desde `PRODUCTIVE_K3S_RELEASE_REPO`.

## Usá los entrypoints de desarrollo

Los profiles `.env` fuente siguen siendo válidos acá para authoring, CI y pruebas de compatibilidad contra el engine de Infra.

Ejemplos de desarrollo:

```bash
make -C scenarios/local/multipass up
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

En el CI del engine, `productive-k3s-infra` debería clonar este repositorio en un workspace temporal y validar que los cambios del engine siguen funcionando contra el árbol público de scenarios. Eso mantiene desacoplado a `infra` del contenido fuente, sin perder cobertura de compatibilidad.

Patrones habituales de comandos por scenario:

- sólo infraestructura: `infra-up`
- sólo preflight: `preflight`
- bootstrap completo: `up`
- sólo validación: `validate`
- inspección del estado generado: `status`
- cleanup o teardown: `clean` o `down`

Ver [Targets de Make](../user-docs/make-targets.md) para el detalle completo.

## Notas

!!! note
    Estos scenarios públicos son deliberadamente pragmáticos. Están pensados para poder evaluarse, reutilizarse y explicarse. No se presentan como blueprints completamente endurecidos para producción.

!!! note
    Los artefactos generados dentro de cada scenario forman parte del flujo público. Hacen más fácil inspeccionar decisiones de infraestructura, inputs de bootstrap y estado de validación.
