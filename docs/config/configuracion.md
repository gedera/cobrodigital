# Configuración — cobro_digital

> meta: artefacto · RFC-012 · generado arch-structure + arch-enrich · anclado a v1.9.0 · inventario base + §f cobertura 2/2

## 1. Resumen

Gema con configuración mínima: dos variables de entorno (`ENDPOINT_COBRODIGITAL` selecciona el endpoint del WS; `COBRODIGITAL_LOG_LEVEL` el nivel de log del cliente SOAP), más constantes de tuning fijas en código (`TIMEOUT`, cliente default, filtros de log). Las credenciales del comercio (`id_comercio`, `sid`) NO son configuración de entorno: se pasan por argumento en cada `#call`.

## 2. §a Hecho verificable

| métrica | valor |
|---|---|
| total vars (env) | 2 |
| requeridas | 0 |
| con default | 2 |
| derivadas | 3 (`URI`, `WSDL` ← `ENDPOINT_COBRODIGITAL`; `LOG_LEVEL` ← `COBRODIGITAL_LOG_LEVEL`) |
| secretas (env) | 0 |

## 3. §b Inventario base

| nombre | tipo | requerida | default | origen | consumidor (file:line) | secret? | categoría | failure-mode | side-effect | business reason |
|---|---|---|---|---|---|---|---|---|---|---|
| `ENDPOINT_COBRODIGITAL` | String (URL base) | no | `https://cobro.digital:14365` | env | `lib/cobro_digital.rb:21-22` | no | — | — | — | — |
| `COBRODIGITAL_LOG_LEVEL` | Symbol (nivel de log) | no | `error` | env | `lib/cobro_digital.rb:30-31` | no | — | — | — | — |

**Constantes de runtime (no env, fijas en código — `lib/cobro_digital.rb`):**

| constante | valor | nota |
|---|---|---|
| `CobroDigital::TIMEOUT` | `300` | open/read timeout (s) para SOAP y HTTPS |
| `CobroDigital::SOAP` | `'soap'` | cliente default si no se pasa `:con_client` |
| `CobroDigital::URI` | `"#{endpoint}/ws3/"` | derivada — ver §d |
| `CobroDigital::WSDL` | `"#{endpoint}/ws3/?wsdl"` | derivada — ver §d |
| `CobroDigital::LOG_LEVEL` | `error` (default) | derivada de `COBRODIGITAL_LOG_LEVEL` (string vacío → `error`) |
| `CobroDigital::DEBUG_LOG` | `false` (default) | `true` solo si `LOG_LEVEL == :debug`; gobierna `pretty_print_xml` |
| `CobroDigital::LOG_FILTERS` | `[:parametros_de_entrada]` | nodo SOAP enmascarado (`***FILTERED***`) — protege sid + PII |

**Credenciales (NO configuración de entorno — argumentos de invocación):**

| dato | dónde entra | secret? |
|---|---|---|
| `id_comercio` | argumento de `Operador#call(id_comercio, sid, …)` / `Client.new(id_comercio:)` | no |
| `sid` | argumento de `Operador#call(id_comercio, sid, …)` / `Client.new(sid:)` | **sí** |

## 4. §d Derivaciones simples

| var derivada | fórmula |
|---|---|
| `CobroDigital::URI` | `(ENV['ENDPOINT_COBRODIGITAL'] \|\| 'https://cobro.digital:14365') + '/ws3/'` |
| `CobroDigital::WSDL` | `(ENV['ENDPOINT_COBRODIGITAL'] \|\| 'https://cobro.digital:14365') + '/ws3/?wsdl'` |
| `CobroDigital::LOG_LEVEL` | `_l = ENV['COBRODIGITAL_LOG_LEVEL'].to_s; (_l.empty? ? 'error' : _l).to_sym` |

> Todas se evalúan **una vez al cargar la gema** (`require`). Cambiar las env en runtime tras el `require` NO re-deriva las constantes.

## 5. §c/§e/§i/§j (sembrados)

- **§e Scheduling:** no aplica (gema sin scheduler).
- **§i Inyecciones al host:** no aplica (no hay Railtie/Engine; la gema no muta el host).
- **§j Inyección a gemas configuradas:** no aplica (no hay bloque `configure`; el `@with_handshake` configurable está comentado en `Client#initialize`).
- Campos `categoría · failure-mode · side-effect · scope-override · business reason` de §b: `—` (los llena `arch-enrich`).

## f. Enriquecimiento semántico

> cobertura: 2/2 vars enriquecidas; ausencia ≠ "no aplica".

### f.1 endpoint (`ENDPOINT_COBRODIGITAL`)

| var | categoría | failure-mode | side-effect | scope-override | business-reason / definición |
|---|---|---|---|---|---|
| `ENDPOINT_COBRODIGITAL` | integration | `silent-default` @ require — si falta, usa producción (`https://cobro.digital:14365`) silenciosamente | `restart` (las constantes `URI`/`WSDL` se `freeze`an al cargar la gema) | `boot-only` | selecciona el entorno del WS de CobroDigital (sandbox vs producción). **Sin var ⇒ producción.** Un entorno de pruebas que olvide setearla pega contra el WS real → riesgo de crear pagadores/boletas reales. |

### f.2 logging (`COBRODIGITAL_LOG_LEVEL`)

| var | categoría | failure-mode | side-effect | scope-override | business-reason / definición |
|---|---|---|---|---|---|
| `COBRODIGITAL_LOG_LEVEL` | observability | `silent-default` @ require — sin var ⇒ `:error` (no loguea el body del request) | `restart` (constante evaluada al cargar la gema) | `boot-only` | controla la verbosidad del log de Savon. **Seguridad:** con `=debug` el XML formateado expone el `sid` + PII del pagador en claro → no habilitar en producción. El nodo `parametros_de_entrada` se enmascara vía `LOG_FILTERS` aun en debug, pero `pretty_print_xml` sigue exponiendo el body. |

**Ramificadores:** ninguno (no condiciona otras vars).

**Threading:** n/a (constantes evaluadas una vez al `require`).

## 6. Cobertura y fronteras

- **Cobertura:** total. Dos env vars (`ENDPOINT_COBRODIGITAL`, `COBRODIGITAL_LOG_LEVEL`); resto es tuning fijo en código.
- **Heurística a verificar (humano):** `ENDPOINT_COBRODIGITAL` se infiere `requerida=no` por tener default literal embebido. Confirmar que apuntar a producción vs sandbox se hace solo cambiando esta var.
- **Sin valor real comprometido:** el inventario no incluye literales de credenciales (las credenciales no son env vars).
