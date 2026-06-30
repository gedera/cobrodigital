---
name: cobro-digital
description: >-
  Gema adaptadora del Web Service v3 de CobroDigital (pasarela de pago).
  Modela las operaciones del WS — crear/editar/verificar pagadores, generar/
  inhabilitar boletas, obtener código de barras, consultar transacciones y
  actividad de micrositios, y agrupar operaciones en batch (meta) — y resuelve
  el transporte SOAP (default, vía savon) o HTTPS hacia el endpoint del comercio.
  Activala cuando trabajes con cobranzas/boletas/pagadores contra CobroDigital,
  cuando integres o depures la comunicación con su webservice, o cuando un host
  consuma la gema `cobro_digital`.
triggers:
  - "cobrodigital"
  - "cobro digital"
  - "generar boleta"
  - "crear pagador"
  - "consultar transacciones cobrodigital"
  - "webservice de pago cobrodigital"
  - "gema cobro_digital"
---

# cobro_digital

## Qué es / cuándo usar

Adaptador Ruby del WS v3 de CobroDigital (pasarela de pago argentina). Úsalo
para invocar las operaciones del webservice desde un host Ruby/Rails. La gema
no persiste estado ni define excepciones propias: arma el payload, lo envía y
decodifica la respuesta.

## Contrato resumido

**Patrón de uso:** cada operación es una subclase de `CobroDigital::Operador`
construida por un método de clase y ejecutada con `#call(id_comercio, sid)`.

```ruby
op = CobroDigital::Boleta.generar(id, buscar, vencimientos, importes, concepto, plantilla)
op.call(comercio_id, comercio_sid) # ejecuta; guarda #response
op.parse_response                  # => { resultado: Bool, log: [..], datos: [..] }
```

**Superficie pública** (detalle: [`docs/interface/interface.md`](../docs/interface/interface.md)):

- `CobroDigital::Pagador` — `.crear`, `.editar`, `.verificar`, `.codigo_electronico`, `.estructura_de_datos`
- `CobroDigital::Boleta` — `.generar`, `.inhabilitar`, `.obtener_codigo_de_barras`
- `CobroDigital::Transaccion` — `.consultar(desde, hasta, filtros)` + constantes `FILTRO_*`
- `CobroDigital::Micrositio` — `.consultar_actividad`
- `CobroDigital::Meta` — `.meta(objs)` (batch de operaciones en una llamada)
- `CobroDigital::Client` — transporte; `CobroDigital::VERSION`

**Config:** `ENV['ENDPOINT_COBRODIGITAL']` (default `https://cobro.digital:14365`)
y `ENV['COBRODIGITAL_LOG_LEVEL']` (default `error`). Credenciales `id_comercio`/`sid`
se pasan por argumento en cada `#call`, no por env.

**Gotchas:**
- `parse_response` **no levanta excepción** ante `resultado: false` — el unhappy
  path se inspecciona vía `resultado`/`log`. Fallos de transporte propagan
  `Savon::*` / `Net::HTTP` / `JSON::ParserError` sin envolver.
- El WS **no controla duplicados** (`crear_pagador` es no-idempotente): el
  control de unicidad es del consumidor.
- `client_to_use` inválido (≠ `'soap'`/`'https'`) → `ArgumentError` en `Client.new`.
- **No usar `COBRODIGITAL_LOG_LEVEL=debug` en producción**: el XML formateado del
  request expone el `sid` + PII del pagador.
- Requiere Ruby `>= 2.7, < 3.0` (stack savon 2.12). Desde v1.9.0 **no** depende de
  ActiveSupport (solo stdlib).

## Índice de artefactos

| capa | doc | estado |
|---|---|---|
| interfaz | [`docs/interface/interface.md`](../docs/interface/interface.md) | API Ruby pública |
| consumidas | [`docs/consumed/cobrodigital.md`](../docs/consumed/cobrodigital.md) | WS de CobroDigital (estructural §a/§b/§d + §c/§e enriquecidos) |
| configuración | [`docs/config/configuracion.md`](../docs/config/configuracion.md) | inventario base + §f enriquecido |
| topología | [`docs/topology/topology.md`](../docs/topology/topology.md) | deps + modos de transporte |
| test | [`docs/test/testing.md`](../docs/test/testing.md) | RSpec (suite mínima) |
| comportamiento | [`docs/behavior/behavior.md`](../docs/behavior/behavior.md) | operación simple · batch meta |
| glosario | [`docs/glossary/glossary.md`](../docs/glossary/glossary.md) | términos del dominio |
| seguridad | [`docs/security/security.md`](../docs/security/security.md) | secrets-semántica §f (sanitización logs sid+PII) + confianza §g (auth saliente) |
| datos · api · errores · eventos · multi-tenancy · data-lifecycle | — | n/a (ver Mapa de conocimiento en `AGENTS.md`) |
| release | [`docs/release/release.md`](../docs/release/release.md) | presente — publicación tag-driven a RubyGems vía `/gem-release` |

## Uso correcto / gotchas

- Para varias operaciones en una sola llamada al WS, construí cada operación y
  pasalas a `CobroDigital::Meta.meta([...])`.
- Las fechas de `Boleta.generar`, `Transaccion.consultar` y `Micrositio.consultar_actividad`
  se formatean internamente a `%Y%m%d` — pasá objetos `Date`/`Time`, no strings.
- El handshake (`MD5` de `Time.now`) se regenera por request automáticamente.
