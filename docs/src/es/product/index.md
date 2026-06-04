# Resumen Del Producto

`productive-k3s-profiles` es el repositorio fuente público de profiles y scenarios de Productive K3S.

No reemplaza:

- `productive-k3s-core`, que sigue siendo dueño del bootstrap del clúster
- `productive-k3s-infra`, que sigue siendo dueño del engine de runtime que ejecuta profiles empaquetados

Este repositorio es dueño de la superficie pública de authoring que después alimenta los artefactos `profile.tgz` publicados:

- `profiles/` fuente
- `scenarios/` fuente
- defaults y scripts auxiliares por escenario
- sidecars de metadata de paquete como `*.package.yaml`

En las páginas siguientes podés ver para qué sirve este repositorio, cómo se relaciona con el engine de Infra y cómo debe authoring y consumirse el contenido público de profiles/scenarios.

## Páginas

- [Cómo usar Productive K3S Profiles](how-to-use.md)
- [Razones del diseño](reasons-behind.md)
- [Open vs Pro](open-vs-pro.md)
- [Relación con Productive K3S Infra y Core](productive-k3s-relationship.md)
