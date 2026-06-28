# Configuración — cobro_digital

> meta: artefacto · RFC-012 · generado arch-structure + arch-enrich · anclado a 45e32b7 · inventario base + §f cobertura 1/1

## 1. Resumen

Gema con configuración mínima: una única variable de entorno (`ENDPOINT_COBRODIGITAL`) que selecciona el endpoint del WS, más dos constantes de tuning fijas en código (`TIMEOUT`, cliente default). Las credenciales del comercio (`id_comercio`, `sid`) NO son configuración de entorno: se pasan por argumento en cada `#call`.

## 2. §a Hecho verificable

| métrica | valor |
|---|---|
| total vars (env) | 1 |
| requeridas | 0 |
| con default | 1 |
| derivadas | 2 (`URI`, `WSDL` ← `ENDPOINT_COBRODIGITAL`) |
| secretas (env) | 0 |

## 3. §b Inventario base

| nombre | tipo | requerida | default | origen | consumidor (file:line) | secret? | categoría | failure-mode | side-effect | business reason |
|---|---|---|---|---|---|---|---|---|---|---|
| `ENDPOINT_COBRODIGITAL` | String (URL base) | no | `https://cobro.digital:14365` | env | `lib/cobro_digital.rb:17-18` | no | — | — | — | — |

**Constantes de runtime (no env, fijas en código — `lib/cobro_digital.rb`):**

| constante | valor | nota |
|---|---|---|
| `CobroDigital::TIMEOUT` | `300` | open/read timeout (s) para SOAP y HTTPS |
| `CobroDigital::SOAP` | `'soap'` | cliente default si no se pasa `:con_client` |
| `CobroDigital::URI` | `"#{endpoint}/ws3/"` | derivada — ver §d |
| `CobroDigital::WSDL` | `"#{endpoint}/ws3/?wsdl"` | derivada — ver §d |

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

> Ambas se evalúan **una vez al cargar la gema** (`require`) y se `freeze`an. Cambiar `ENDPOINT_COBRODIGITAL` en runtime tras el `require` NO re-deriva las constantes.

## 5. §c/§e/§i/§j (sembrados)

- **§e Scheduling:** no aplica (gema sin scheduler).
- **§i Inyecciones al host:** no aplica (no hay Railtie/Engine; la gema no muta el host).
- **§j Inyección a gemas configuradas:** no aplica (no hay bloque `configure`; el `@with_handshake` configurable está comentado en `Client#initialize`).
- Campos `categoría · failure-mode · side-effect · scope-override · business reason` de §b: `—` (los llena `arch-enrich`).

## f. Enriquecimiento semántico

> cobertura: 1/1 vars enriquecidas; ausencia ≠ "no aplica".

### f.1 endpoint (`ENDPOINT_COBRODIGITAL`)

| var | categoría | failure-mode | side-effect | scope-override | business-reason / definición |
|---|---|---|---|---|---|
| `ENDPOINT_COBRODIGITAL` | integration | `silent-default` @ require — si falta, usa producción (`https://cobro.digital:14365`) silenciosamente | `restart` (las constantes `URI`/`WSDL` se `freeze`an al cargar la gema) | `boot-only` | selecciona el entorno del WS de CobroDigital (sandbox vs producción). **Sin var ⇒ producción.** Un entorno de pruebas que olvide setearla pega contra el WS real → riesgo de crear pagadores/boletas reales. |

**Ramificadores:** ninguno (no condiciona otras vars).

**Threading:** n/a (constantes evaluadas una vez al `require`).

## 6. Cobertura y fronteras

- **Cobertura:** total. Una sola env var; resto es tuning fijo en código.
- **Heurística a verificar (humano):** `ENDPOINT_COBRODIGITAL` se infiere `requerida=no` por tener default literal embebido. Confirmar que apuntar a producción vs sandbox se hace solo cambiando esta var.
- **Sin valor real comprometido:** el inventario no incluye literales de credenciales (las credenciales no son env vars).
