# Test — cobro_digital

> meta: artefacto · RFC-013 · generado arch-structure + arch-enrich · anclado a v1.9.0 · inventario estructural (§a-§d) + §e-§h enriquecidos

## 1. Resumen

Suite RSpec (`spec/cobro_digital_spec.rb`) que cubre la versión, los constructores de las operaciones (`Pagador`/`Boleta`/`Transaccion`) y el parser `Operador#parse_response`. No cubre el transporte real (SOAP/HTTPS) — requiere doble del WS.

## 2. §a Suites, frameworks y niveles

| framework | versión | dónde |
|---|---|---|
| RSpec | `~> 3.13` (dev-dep en `cobro_digital.gemspec`) | `.rspec`, `spec/`, `Rakefile` (`RSpec::Core::RakeTask`) |

| suite (archivo) | nivel | propósito | tags |
|---|---|---|---|
| `spec/cobro_digital_spec.rb` | unit | versión · constructores de operaciones (webservice/http_method/render/fechas) · `parse_response` (éxito y `resultado=false`) | — |

## 3. §b Comando de corrida

| contexto | comando |
|---|---|
| local | `bundle exec rspec` |
| vía rake (default task) | `bundle exec rake` → `:spec` (`Rakefile`) |
| CI | GitHub Actions `.github/workflows/main.yml` — `bundle exec rspec` sobre Ruby 2.7 en PRs y push a `master` |

Config RSpec (`.rspec`): `--format documentation --color`.

## 4. §c Fixtures / Factories

Ninguna. No hay `spec/factories/`, `spec/fixtures/` ni FactoryBot. `spec/spec_helper.rb` solo agrega `lib` al `$LOAD_PATH` y requiere `cobro_digital`. El doble del sobre del WS para `parse_response` es un `Struct` anónimo vía `let` (sin constante leaky).

## 5. §d Configuración de coverage

Ninguna. No hay SimpleCov ni `.simplecov` ni umbral declarado.

## 6. §e Gaps de cobertura

| dominio / flujo | cubierto | nota |
|---|---|---|
| `CobroDigital::VERSION` presente | sí | — |
| construcción de operaciones (`Pagador.crear/.verificar`, `Boleta.generar`, `Transaccion.consultar`) | **sí** | verifica `webservice`, `http_method`, `render`, `request` y formateo `%Y%m%d` |
| `Operador#parse_response` | **sí** | respuesta exitosa (`resultado/log/datos`, rescue por fila) y `resultado=false` |
| `Micrositio`/`Meta` | **no** | constructores sin test directo |
| selección de transporte SOAP/HTTPS (`Client#call`, `soap_client`, `https_client`) | **no** | requiere doble de Savon/`Net::HTTP` |
| guard de `client_to_use` inválido (`ArgumentError`) | **no** | agregado en v1.9.0, sin test aún |

## 7. §f Contract-assessment

| contrato público | test que lo cubre | estado |
|---|---|---|
| interfaz (`docs/interface/`) — constructores + `parse_response` | sí (parcial) | cubre la construcción y el parseo; falta el transporte |
| dependencias consumidas (`docs/consumed/`) — payloads/parseo del WS | parcial | `parse_response` cubierto; el envío real (Savon) sin contract-test |
| errores | n/a | la gema no define errores propios |

## 8. §g Link a incidente

`—`. No hay tests de regresión atados a incidentes.

## 9. §h PII en fixtures/factories

Sin fixtures ni factories → **sin PII en datos de prueba**. Los tests usan datos sintéticos triviales (`'Nombre' => 'Juan'`, `'id'`, números). Si a futuro se agregan factories de pagador, clasificar como **PII** (nombre/documento/e-mail/teléfono) — nunca versionar valores reales.

## 10. Cobertura y fronteras

- **Cobertura:** total sobre `spec/` (1 archivo) + §e-§h enriquecidos.
- **Fuera de alcance:** el transporte real (SOAP vía Savon, HTTPS vía `Net::HTTP`) no se ejercita — necesita un doble del WS; candidato a contract-test.
