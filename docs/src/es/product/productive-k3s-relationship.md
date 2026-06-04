# Relación Con Productive K3S Infra Y Core

`productive-k3s-profiles`, `productive-k3s-infra` y `productive-k3s-core` tienen responsabilidades distintas.

## Qué hace Productive K3S Core

`productive-k3s-core` es el proyecto de bootstrap del clúster. Es responsable de:

- instalar `k3s`
- armar el modo de clúster seleccionado
- instalar componentes compartidos del stack
- validar el comportamiento del stack resultante

## Qué hace Productive K3S Infra

`productive-k3s-infra` es el engine de runtime. Es responsable de:

- ejecutar artefactos empaquetados `profile.tgz`
- mergear defaults del paquete con overrides locales
- persistir y restaurar state de runtime
- dispatch de comandos, manejo de errores y telemetría

## Qué hace Productive K3S Profiles

`productive-k3s-profiles` es dueño del contenido fuente público que prepara el contexto de infraestructura alrededor de esas fases:

- crear o apuntar las máquinas
- derivar roles de nodos y hostnames de servicios
- renderizar metadata generada y archivos tipo inventario
- orquestar la secuencia de bootstrap entre uno o varios nodos
- declarar metadata de paquete y defaults de los profiles publicados

## Interfaz compartida de bootstrap

Los flujos de infraestructura de este repositorio tratan a los modos de ejecución de `productive-k3s-core` como la interfaz pública de bootstrap:

- `single-node`
- `server`
- `agent`
- `stack`

Los distintos scenarios consumen esos modos de forma diferente:

- `multipass`: `server`, `agent`, `stack`
- `onprem-basic`: `single-node` o `server`, `agent`, `stack` según la topología
- `aws-single-node`: operativamente un nodo, pero envuelto por la misma capa compartida de bootstrap remoto alrededor de `productive-k3s-core`

## Por qué importa la separación

Esta separación mantiene reemplazable la automatización de infraestructura.

Podés cambiar:

- cómo se provisionan las máquinas
- de dónde salen los inventarios
- qué transporte se usa
- cómo evoluciona el engine de runtime

sin redefinir cada vez el contrato central de bootstrap del clúster.
