# Release — cobro_digital

> meta: artefacto · RFC-014 · generado arch-structure + arch-enrich · anclado a v1.9.0 · estructural (§a versión·changelog·build-trigger·anchor) + §b deploy·rollback·ambientes·dueño enriquecidos 4/4

## 1. Resumen

Gema Ruby publicada a RubyGems mediante pipeline **tag-driven** (patrón 1): el push de un tag `v*` dispara `gem build` + `gem push` vía GitHub Actions. La versión vive en `lib/cobro_digital/version.rb`, el historial en `CHANGELOG.md` (Keep a Changelog), y la publicación se orquesta con la skill `/gem-release`.

## 2. Release

### §a Estructura (versión · changelog · build-trigger · anchor)

| campo | valor | fuente |
|---|---|---|
| versión actual | `1.9.0` | `lib/cobro_digital/version.rb` (`CobroDigital::VERSION`) |
| esquema de versión | SemVer (`MAJOR.MINOR.PATCH`) | gemspec `spec.version = CobroDigital::VERSION` |
| changelog | `CHANGELOG.md` — formato Keep a Changelog; última entrada `[1.9.0] — 2026-06-29` | `CHANGELOG.md` |
| build-trigger | push de tag `v*` (ej. `v1.9.0`) | `.github/workflows/release.yml` (`on.push.tags: ['v*']`) |
| build steps | `gem build cobro_digital.gemspec` → `gem push *.gem` | `.github/workflows/release.yml` (job `build`) |
| runner | `ubuntu-latest` · Ruby `2.7` (savon ~> 2.12.1 no corre en Ruby 3.0+) | `.github/workflows/release.yml` (`ruby/setup-ruby`) |
| credencial de publicación | `GEM_HOST_API_KEY` ← `secrets.RUBYGEMS_API_KEY` (nativo de `gem push`; no se escribe a disco) | `.github/workflows/release.yml` (`env`) |
| anchor (artefacto distribuido) | `documentation_uri` version-locked → `…/blob/v#{version}/skill` | `cobro_digital.gemspec:16` |
| destino | RubyGems.org | `gem push` (sin `allowed_push_host` override) |
| orquestación local | skill `/gem-release` (bump · CHANGELOG · skill regen · tag · publish) | declarado en CHANGELOG/AGENTS |

### Patrón de trigger (RFC-014, 1 de 4)

**Patrón 1 — publish de gema, per-repo-visible.** El artefacto es una gema; el release es la publicación del `.gem` a RubyGems disparada por tag en el propio repo. No hay branches `production`/`staging` (patrón 3) ni deploy a infraestructura (patrón 2/4): el "deploy" de una gema es su disponibilidad en el registry para los hosts que la declaren.

### §b Operación (deploy · rollback · ambientes · dueño) — enrich

> cobertura: 4/4 campos enriquecidos.

| campo | valor |
|---|---|
| deploy | Publicación del `.gem` a **RubyGems.org** vía `gem push`, disparada por push de tag `v*` (`.github/workflows/release.yml`). No hay deploy a infraestructura: el "deploy" es la disponibilidad en el registry. Los hosts la consumen declarándola en su `Gemfile` y corriendo `bundle install`. |
| rollback | `gem yank cobro_digital -v X.Y.Z` despublica una versión de RubyGems. **Camino preferido: publicar una versión nueva con el fix** (SemVer hacia adelante); el `yank` se reserva para release defectuoso o credencial filtrada. RubyGems **no permite re-push** del mismo número de versión — una vez publicada, esa versión es inmutable. |
| ambientes | Sin ambientes de runtime propios (no hay `production`/`staging` — patrón 1, no patrón 3). El único "ambiente" es **RubyGems.org** como registry de publicación. El ambiente de ejecución de la gema lo define el **host consumidor** (su Ruby, su Rails/no-Rails, su stack). Build en runner efímero Ruby 2.7. |
| dueño | Maintainer **@gedera** (`homepage = github.com/gedera/cobrodigital`; autor de los commits del CHANGELOG). Se **infiere** que custodia la credencial de publicación (`RUBYGEMS_API_KEY` en secrets del repo) — no verificable estáticamente. |

## 3. Inferencias

| afirmación | confianza | a verificar |
|---|---|---|
| El "deploy" de la gema = disponibilidad en RubyGems tras `gem push` (no hay target de infra) | inferido | confirmar que ningún consumidor espera un artefacto adicional (imagen, paquete OS) |
| El runner se fija a Ruby 2.7 porque `gem build` evalúa el gemspec con el Ruby del runner y savon 2.12 no soporta 3.0+ | declarado | comentario explícito en `release.yml:23-24`, `main.yml:21` y `cobro_digital.gemspec:18-19`; la restricción dura es `required_ruby_version < 3.0` (`gemspec:20`) |
| `/gem-release` es el orquestador local del flujo de release | inferido | declarado en CHANGELOG + AGENTS.md §6; verificar que el flujo no se corre a mano |

## 4. Cobertura y fronteras

- **Estructural completo (§a):** versión, changelog, build-trigger y anchor son derivables del repo y están cubiertos.
- **§b deploy/rollback/ambientes/dueño:** enriquecidos 4/4 (`arch-enrich`); anclados a operación real (RubyGems tag-driven, `gem yank` para rollback, maintainer @gedera).
- **CI de validación (no-release):** `.github/workflows/main.yml` (rspec en PRs/push a master) es la capa de test/CI, no release → vive en `docs/test/testing.md`, no acá.
- **Sin branches de ambiente:** este repo no usa el patrón 3 (`production`/`staging`); la única "promoción" es el tag `v*`.
- **Gemfile.lock no versionado** (decisión declarada en AGENTS.md §3): la resolución de deps del build la fija el gemspec (`savon ~> 2.12.1`), no un lock.
