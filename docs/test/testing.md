# Test — cobro_digital

> meta: artefacto · RFC-013 · generado arch-structure + arch-enrich · anclado a 45e32b7 · inventario estructural (§a-§d) + §e-§h enriquecidos

## 1. Resumen

Suite mínima RSpec con un único spec de smoke (`spec/cobro_digital_spec.rb`). Cobertura efectiva ≈ nula: contiene un test placeholder que falla a propósito (`expect(false).to eq(true)`). No hay tests de las operaciones ni del transporte.

## 2. §a Suites, frameworks y niveles

| framework | versión | dónde |
|---|---|---|
| RSpec | no fijado (no hay `Gemfile.lock` versionado; no declarado en gemspec) | `.rspec`, `spec/`, `Rakefile` (`RSpec::Core::RakeTask`) |

| suite (archivo) | nivel | propósito | tags |
|---|---|---|---|
| `spec/cobro_digital_spec.rb` | unit | smoke: versión presente + 1 placeholder que falla | — |

## 3. §b Comando de corrida

| contexto | comando |
|---|---|
| local | `bundle exec rspec` |
| vía rake (default task) | `bundle exec rake` → `:spec` (`Rakefile`) |
| CI | `.travis.yml` presente pero **legacy** (Ruby 1.8.7); no refleja pipeline actual — sin CI vigente verificable en el repo |

Config RSpec (`.rspec`): `--format documentation --color`.

## 4. §c Fixtures / Factories

Ninguna. No hay `spec/factories/`, `spec/fixtures/` ni FactoryBot. `spec/spec_helper.rb` solo agrega `lib` al `$LOAD_PATH` y requiere `cobro_digital`.

## 5. §d Configuración de coverage

Ninguna. No hay SimpleCov ni `.simplecov` ni umbral declarado.

## 6. §e Gaps de cobertura

| dominio / flujo | cubierto | nota |
|---|---|---|
| `CobroDigital::VERSION` presente | sí | único assert real que pasa |
| construcción de operaciones (`Pagador`/`Boleta`/`Transaccion`/`Micrositio`/`Meta`) | **no** | ningún test ejercita los constructores ni el `render` |
| `Operador#parse_response` (decodificación del JSON del WS) | **no** | lógica con riesgo (aplanado de `datos`, `rescue` por fila) sin un solo test |
| selección de transporte SOAP/HTTPS (`Client#call`) | **no** | sin test ni doble del WS |
| formateo de fechas a `%Y%m%d` | **no** | regla de borde (vencimientos, rangos) sin cobertura |

> **Gap dominante:** la cobertura real de negocio es **nula**. El spec `does something useful` (`expect(false).to eq(true)`) es un placeholder que **falla a propósito** → la suite está roja por diseño. Deuda histórica, no un flujo no-implementado.

## 7. §f Contract-assessment

| contrato público | test que lo cubre | estado |
|---|---|---|
| interfaz (`docs/interface/`) | — | **sin cobertura** |
| dependencias consumidas (`docs/consumed/`) — payloads/parseo del WS | — | **sin cobertura** (candidato a contract-test con doble de Savon) |
| errores | n/a | la gema no define errores propios |

## 8. §g Link a incidente

`—`. No hay tests de regresión atados a incidentes (no existe historial de tests funcionales).

## 9. §h PII en fixtures/factories

Sin fixtures ni factories → **sin PII en datos de prueba**. Nota: el README/glosario muestran datos de pagador de ejemplo (nombre, documento, e-mail) como **documentación**, no como fixtures de test; no son datos de test versionados. Si a futuro se agregan factories de pagador, clasificar como **PII** (nombre/documento/e-mail/teléfono) — nunca versionar valores reales.

## 10. Cobertura y fronteras

- **Cobertura:** total sobre `spec/` (1 archivo) + §e-§h enriquecidos. El estado real de testing es deuda, no un gap del artefacto.
- **Honestidad:** el spec placeholder que falla (`expect(false).to eq(true)`) hace que `bundle exec rspec` salga con suite roja — documentado, no inventado.
