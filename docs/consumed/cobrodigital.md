# Dependencias consumidas — cobro_digital → WS CobroDigital

> meta: artefacto · RFC-018 · generado arch-structure + arch-enrich · anclado a v1.9.0 · cobertura estructural (§a/§b/§d) + §c/§e enriquecidos 2/2

## 1. Resumen

La gema **es** un adaptador: su única dependencia consumida es el Web Service v3 de CobroDigital (pasarela de pago externa). Toda la superficie pública de la gema termina en una llamada a un único método SOAP (`webservice_cobrodigital`) o a su equivalente HTTPS sobre `…/ws3/`.

## 2. §a Identidad

| campo | valor |
|---|---|
| proveedor/servicio | CobroDigital — WS v3 (pasarela de pago) |
| sub-tipo | **externo** (no es repo del fleet) |
| transporte | SOAP 1.x sobre HTTPS (default) · HTTP form POST/GET (alternativo) |
| cliente nuestro | `CobroDigital::Client` (`lib/cobro_digital.rb`); SOAP vía `savon ~> 2.12.1`, HTTPS vía `Net::HTTP` |
| endpoint | `https://cobro.digital:14365/ws3/` (default); override por `ENV['ENDPOINT_COBRODIGITAL']` |
| WSDL | `…/ws3/?wsdl` |
| auth | credenciales de comercio en cada request: `idComercio` + `sid` + `handshake` (MD5 de `Time.now.to_f`) — ver `Client#comercio` |
| doc oficial | Manual de implementación entregado por CobroDigital (no versionado en el repo); <http://cobrodigital.com> |

## 3. §b Operaciones consumidas

Todas viajan como un único método SOAP `webservice_cobrodigital` cuyo `parametros_de_entrada` es el JSON de `comercio.merge(request)`. El campo `metodo_webservice` discrimina la operación real:

| operación (`metodo_webservice`) | transporte | qué mandamos | constructor de la gema |
|---|---|---|---|
| `crear_pagador` | POST | `{ pagador: {…} }` | `Pagador.crear` |
| `editar_pagador` | POST | `{ identificador, buscar, pagador }` | `Pagador.editar` |
| `verificar_existencia_pagador` | GET | `{ identificador, buscar }` | `Pagador.verificar` |
| `obtener_codigo_electronico` | GET | `{ identificador, buscar }` | `Pagador.codigo_electronico` |
| `consultar_estructura_pagadores` | GET | `{}` | `Pagador.estructura_de_datos` |
| `generar_boleta` | POST | `{ identificador, buscar, fechas_vencimiento[`%Y%m%d`], importes, concepto, plantilla }` | `Boleta.generar` |
| `inhabilitar_boleta` | POST | `{ nro_boleta }` | `Boleta.inhabilitar` |
| `obtener_codigo_de_barras` | GET | `{ nro_boleta }` | `Boleta.obtener_codigo_de_barras` |
| `consultar_transacciones` | GET | `{ desde[`%Y%m%d`], hasta[`%Y%m%d`], filtros }` | `Transaccion.consultar` |
| `consultar_actividad_micrositio` | GET | `{ identificador, buscar, desde, hasta }` | `Micrositio.consultar_actividad` |
| `meta` | POST | `{ 0 => {metodo_webservice,…}, 1 => {…}, … }` (batch) | `Meta.meta` |

**Respuesta (forma común):** el WS responde un sobre cuyo `output` es un JSON string. `Operador#parse_response` lo decodifica a:

| clave | origen en el JSON del WS | tipo |
|---|---|---|
| `resultado` | `ejecucion_correcta == '1'` | Boolean |
| `log` | `log` | Array\<String\> (mensajes / errores) |
| `datos` | `datos` (opcional) | Array (aplanado; cada fila se intenta `JSON.parse`) |

## 4. §d Errores del proveedor → mapeo nuestro

| condición del proveedor | manejo en la gema | excepción nuestra |
|---|---|---|
| `ejecucion_correcta != '1'` | `parse_response` devuelve `resultado: false` + `log` con los mensajes; **no levanta excepción** | — (no se traduce a excepción; el consumidor inspecciona `resultado`/`log`) |
| fallo de transporte SOAP (HTTP ≠ 200, SOAP Fault) | sin `rescue` en la gema → propaga | `Savon::SOAPFault` / `Savon::HTTPError` (de `savon`, sin envolver) |
| fallo de transporte HTTPS | sin `rescue` en la gema → propaga | excepción de `Net::HTTP` (sin envolver) |
| `output` no parseable como JSON | sin `rescue` en `parse_response` (el `rescue` interno solo cubre filas de `datos`) | `JSON::ParserError` (sin envolver) |

> La gema **no define excepciones propias** ni mapea las del proveedor a un catálogo propio → por eso `docs/errors/` es `n/a` para este repo (ver Mapa de conocimiento en `AGENTS.md`).

## 5. §c Semántica de retry/idempotencia

| aspecto | estado | detalle |
|---|---|---|
| retry | **no implementado** | la gema no reintenta; `TIMEOUT = 300s` open/read (`lib/cobro_digital.rb:20`). Cualquier reintento es responsabilidad del consumidor. |
| idempotencia de escrituras | **no garantizada por el WS** | `crear_pagador` es **no idempotente**: el WS no deduplica (README §Crear Pagador: "es posible dar de alta eternamente el mismo pagador"). Reintentar a ciegas un POST puede duplicar pagadores/boletas. |
| seguridad del reintento | condicional | **lecturas** (GET: `verificar`, `consultar_*`, `obtener_*`) son seguras de reintentar. **escrituras** (POST: `crear/editar_pagador`, `generar/inhabilitar_boleta`, `meta`) NO — verificar estado antes de reintentar. |
| rol del `handshake` | `unknown` | se regenera por request (`Client#comercio`); no se confirmó si el WS lo usa como clave de idempotencia/anti-replay → no asumir que dedup. Verificar con el manual de CobroDigital. |

## 6. §e Degradación (qué pasa si CobroDigital cae)

| escenario | comportamiento actual | decisión de negocio |
|---|---|---|
| WS no responde / timeout (300s) | la excepción de transporte (`Savon::*` / `Net::HTTP`) **propaga sin envolver** al consumidor | no hay fallback ni cola en la gema; el consumidor decide reintento/cola/degradación |
| WS responde error de negocio (`ejecucion_correcta != '1'`) | `parse_response` devuelve `resultado: false` + `log`; **no excepción** | el consumidor debe inspeccionar `resultado` y actuar; un flujo que ignore `resultado` trata un fallo como éxito |
| SLA del proveedor | `unknown` | no documentado en el repo; consultar contrato con CobroDigital |

> **Sin fallback local:** la gema es un transporte fino. Toda resiliencia (retry con backoff, circuit-breaker, cola de outbox para escrituras) vive —o debería— en el host consumidor, no acá.

## 7. Cobertura y fronteras

- **Cobertura:** §a/§b/§d estructurales + §c/§e enriquecidos, anclados al código del cliente.
- **Subset, no la API completa:** se documentan solo los 11 métodos que la gema expone vía constructores; el WS de CobroDigital puede ofrecer más.
- **Fuera de alcance:** el wire-schema interno de cada payload del WS (campos opcionales, validaciones server-side) vive en el Manual de implementación de CobroDigital, no versionado acá.
