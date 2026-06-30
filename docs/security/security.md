# Seguridad — cobro_digital

> meta: artefacto · RFC-017 · generado arch-structure + arch-enrich · anclado a v1.9.0 · estructural (§a-§e) + §f secrets-semántica / §g confianza enriquecidos · NO contiene valores ni vulnerabilidades

## 1. Resumen

Gema cliente de un WS de pago. No tiene authn/authz propia (no recibe requests): su superficie de seguridad es **saliente** — autentica contra el WS de CobroDigital con la credencial de comercio (`id_comercio` + `sid`) y toma una decisión deliberada de **sanitización de logs** para no filtrar esa credencial ni la PII del pagador. Sin roles, policies, endpoints ni audit trail propios.

## 2. Seguridad

### §a Conteos (auth · roles · policies · secrets)

| dimensión | conteo | nota |
|---|---|---|
| mecanismos de auth | 1 | credencial de comercio (`id_comercio` + `sid`) por argumento, saliente |
| roles | 0 | sin RBAC |
| policies | 0 | sin Pundit/authorization |
| secrets manejados | 2 | `id_comercio`, `sid` (credencial del comercio; transitan, no se persisten) |

### §b Auth por dirección

| dirección | mecanismo | fuente | nota |
|---|---|---|---|
| entrante | n/a | — | la gema no expone superficie; no recibe requests autenticables |
| saliente (→ WS CobroDigital) | credencial de comercio `id_comercio` + `sid` | argumento de `#call(id_comercio, sid)` — NO env, NO archivo | el host custodia la credencial y la pasa por llamada (`lib/cobro_digital.rb:51`) |
| saliente — handshake | `MD5(Time.now)` por request | generado en cada request | identifica el request; se regenera automáticamente (ver `docs/behavior`) |

### §c Authz (roles · modelo · claims)

**Veredicto: n/a** — la gema no implementa modelo de autorización (sin roles, sin claims, sin Pundit/Current). La autorización efectiva la resuelve el WS de CobroDigital contra la credencial de comercio.

### §d Endpoint → authz

**Veredicto: n/a** — la gema no expone endpoints propios (RFC-003 `docs/api` = n/a). No hay mapeo endpoint→authz que documentar.

### §e Audit

**Veredicto: n/a** — la gema no mantiene audit trail propio. El logging del cliente SOAP (§f) es diagnóstico, no auditoría; su default no registra el body.

### §f Secrets-semántica (enrich)

> cobertura: 1/1 superficie de secrets enriquecida.

| aspecto | decisión | binding |
|---|---|---|
| custodia de credencial | `id_comercio`/`sid` se pasan por argumento en cada `#call`, **no** por env ni archivo de config → la gema no persiste ni cachea la credencial; el host es el custodio | `lib/cobro_digital.rb:51` · `consumed §a` |
| sanitización de log | `LOG_FILTERS = [:parametros_de_entrada]` → Savon enmascara el nodo SOAP con `sid` + PII del pagador como `***FILTERED***` en el log | `lib/cobro_digital.rb:35-36` |
| default seguro | `LOG_LEVEL` default `:error` (no loguea el body del request); configurable vía `ENV['COBRODIGITAL_LOG_LEVEL']` | `lib/cobro_digital.rb:26-31` |
| accessors sensibles | comentario explícito: no loguear `sid` ni `request_xml` (credencial + XML con sid + PII) | `lib/cobro_digital.rb:45-47` |
| failure-mode de seguridad | **`COBRODIGITAL_LOG_LEVEL=debug` en producción expone el `sid` en claro** en el XML formateado → no habilitar debug en prod | `lib/cobro_digital.rb:68-70` · `docs/config §f` |

### §g Confianza + zona de red (enrich)

> cobertura: 1/1 frontera enriquecida.

| frontera | zona | confianza |
|---|---|---|
| gema → WS CobroDigital (`cobro.digital:14365`) | saliente a internet (proveedor externo, no fleet) | transporte SOAP (default, vía `savon`) o HTTPS; la credencial de comercio viaja en el payload → depende del cifrado de transporte del endpoint |
| host → gema | in-process (misma VM Ruby) | el host inyecta la credencial por argumento; la gema confía en que el host la custodia de forma segura (fuera del alcance de la gema) |

## 3. Inferencias

| afirmación | confianza | a verificar |
|---|---|---|
| El cifrado en tránsito de la credencial depende del endpoint del comercio (`ENDPOINT_COBRODIGITAL`); la gema no fuerza TLS | inferido | confirmar que el endpoint de prod usa HTTPS/SOAP sobre TLS |
| El host es responsable de la custodia de `id_comercio`/`sid` (rotación, almacenamiento) | declarado | la gema solo los recibe por arg; la custodia es contrato del consumidor |
| `***FILTERED***` cubre el nodo `:parametros_de_entrada`; otros nodos con datos sensibles (si los hubiera) no estarían filtrados | inferido | confirmar que toda PII/credencial viaja solo en `:parametros_de_entrada` |

## 4. Cobertura y fronteras

- **§a/§b estructural + §f/§g enriquecidos:** cubiertos (la superficie real de la gema es secrets-semántica + frontera de confianza saliente).
- **§c/§d/§e `n/a`:** la gema no tiene authz/endpoints/audit propios — declarado con motivo, no es deuda.
- **Custodia de la credencial** (rotación, vault, almacenamiento del `sid`): **fuera de alcance** — es responsabilidad del host consumidor, no de la gema.
- **TLS/cifrado de transporte:** lo provee el endpoint del comercio, no la gema; queda fuera de su control.
- **NO contiene** valores reales de credenciales ni descripción de vulnerabilidades explotables (RFC-017 §3).
- **Frontera con config (RFC-012):** las env vars de log (`COBRODIGITAL_LOG_LEVEL`) viven en `docs/config §f`; acá se documenta su consecuencia de seguridad, no se redefine el inventario.
