# Glosario — cobro_digital

> meta: artefacto · RFC-009 · generado arch-enrich · anclado a v1.9.0 · cobertura parcial (acreta por PR); ausencia ≠ inexistencia

## 1. Resumen

Lenguaje ubicuo del bounded context de la gema: los términos del dominio de cobranza de CobroDigital tal como los modela esta gema. Sin capa de datos propia (`docs/data/` = n/a), el `**Binding:**` apunta al símbolo público que materializa el concepto (`docs/interface/interface.md`), no a tabla/columna.

## 2. Términos

## comercio

La entidad cliente de CobroDigital que usa el webservice. Se identifica en cada request con dos credenciales emitidas por CobroDigital al dar de alta: `id_comercio` (identificador público) y `sid` (secreto). No es un objeto del dominio de la gema — son argumentos de `#call` que viajan en el bloque de identificación.

**Binding:** `CobroDigital::Client#id_comercio`, `CobroDigital::Client#sid`; bloque armado en `Client#comercio` (`lib/cobro_digital.rb:84`).

## handshake

Token anti-replay que acompaña la identificación del comercio en cada request: el MD5 de `Time.now.to_f`. Se regenera por llamada. El comentario `@with_handshake` (comentado en `Client#initialize`) sugiere que alguna vez fue opcional; hoy es siempre-on.

**Binding:** `Client#comercio` → `Digest::MD5.hexdigest(Time.now.to_f.to_s)` (`lib/cobro_digital.rb:85`).

## pagador

El cliente final al que el comercio le factura (a quien se le cobra). Su forma (campos) la define cada comercio con CobroDigital — la gema no la valida ni la fija. El WS **no controla duplicados**: dar de alta el mismo pagador dos veces crea dos. El control de unicidad es del consumidor.

**Binding:** `CobroDigital::Pagador` (`lib/cobro_digital/pagador.rb`).

## identificador / buscar

Par clave-valor para localizar un pagador en el WS: `identificador` es el nombre del campo identificador (ej. `'Su_identificador'`, `'id'`); `buscar` es el valor a matchear (ej. `1234`). Aparece en casi toda operación que opera sobre un pagador existente.

**Binding:** argumentos de `Pagador.editar/verificar/codigo_electronico`, `Boleta.generar`, `Micrositio.consultar_actividad`.

## boleta

El documento de cobro que el comercio informa a CobroDigital para que ejecute el cobro por los medios de la pasarela. Lleva hasta 4 vencimientos (el 1º = fecha de emisión) y hasta 4 importes (el 1º = valor; el resto = recargos por vencimiento). Generarla devuelve un número de boleta.

**Binding:** `CobroDigital::Boleta` (`lib/cobro_digital/boleta.rb`).

## codigo electronico

Código que habilita a los pagadores a pagar por PagosMisCuentas y LinkPagos. Solo se puede obtener **después** de generada la primera boleta del pagador.

**Binding:** `Pagador.codigo_electronico` → WS `obtener_codigo_electronico` (`lib/cobro_digital/pagador.rb:34`).

## codigo de barras

String del código de barras de una boleta (uno por vencimiento/importe). Para renderizarlo a imagen se usa el código 128b (la gema no renderiza; sugiere `barby`).

**Binding:** `Boleta.obtener_codigo_de_barras` → WS `obtener_codigo_de_barras`.

## plantilla

Modelo de estilo/formato de la boleta. Cada comercio la provee/acuerda con CobroDigital (ej. `'init_273'`). Argumento opcional de `Boleta.generar`.

**Binding:** parámetro `plantilla` de `Boleta.generar` (`lib/cobro_digital/boleta.rb:9`).

## transaccion

Un movimiento de la cuenta del comercio en CobroDigital. Se consulta por rango de fechas con filtros. Tipos:

- **ingreso** (`ingresos`): todo lo que incrementa el saldo de la cuenta; generalmente las cobranzas.
- **egreso** (`egresos`): retiros del dinero depositado por los pagadores.
- **tarjeta_credito**: cobranzas abonadas con tarjeta de crédito.
- **debito_automatico**: débitos realizados por CBU.

**Binding:** `CobroDigital::Transaccion` + constantes `FILTRO_TIPO_*` (`lib/cobro_digital/transaccion.rb`).

## micrositio

El sitio de pago que CobroDigital expone para un pagador. La gema consulta su **actividad** en un rango de fechas.

**Binding:** `CobroDigital::Micrositio.consultar_actividad` → WS `consultar_actividad_micrositio`.

## meta

Operación batch: agrupa N operaciones (crear pagadores, generar/inhabilitar boletas, etc.) en una sola llamada al WS, indexadas `{ 0 => …, 1 => … }`. Cada sub-operación lleva su propio `metodo_webservice` y `handshake`.

**Binding:** `CobroDigital::Meta.meta(objs)` → WS `meta` (`lib/cobro_digital/meta.rb:64`).

## resultado / log / datos

La tripleta de la respuesta parseada (`Operador#parse_response`): `resultado` (Boolean, éxito de la consulta), `log` (mensajes/errores del WS), `datos` (payload de la consulta, opcional). Es el contrato de salida que todo consumidor inspecciona.

**Binding:** `Operador#parse_response` (`lib/cobro_digital/operador.rb:22`).

## 3. Inferencias

| término | inferencia | confidence | a verificar |
|---|---|---|---|
| handshake | propósito anti-replay/idempotencia | inferred | confirmar con manual de CobroDigital si el WS lo valida o lo ignora |
| meta | el batch es transaccional (todo-o-nada) o best-effort | unknown | preguntar a CobroDigital — el código no lo expresa |
| micrositio | "actividad" = pagos/visitas/intentos | inferred | precisar qué devuelve `datos` para esta consulta |

## 4. Cobertura y fronteras

- **Cobertura:** parcial declarada. Cubre los términos materializados en la superficie pública actual. Acreta por PR que toque el dominio.
- **Sin binding tabular:** gema sin DB; los bindings apuntan a símbolos públicos (ISO 11179 admite materialización no-tabular cuando hay símbolo estable que *es* el concepto).
- **Candidatos a glosario canónico (RFC-019):** `boleta`, `pagador`, `transaccion` probablemente aparecen en otros repos del fleet que integran cobranza → **flaggeados** como candidatos a entrada canónica. arch-enrich no la crea (es cross-repo); se propone la promoción.
- **No documentado:** la semántica fina de los campos del payload del WS (los define el manual de CobroDigital, no versionado acá).
