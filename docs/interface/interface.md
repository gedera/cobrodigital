# Interfaz — cobro_digital

> meta: artefacto · RFC-004 · generado arch-structure · anclado a v1.9.0 · cobertura total de `lib/**`

## 1. Resumen

API Ruby pública de la gema adaptadora del WS de CobroDigital. Superficie: el módulo `CobroDigital` con el transporte `Client`, la clase base `Operador` y cinco subclases-operación (`Pagador`, `Boleta`, `Transaccion`, `Micrositio`, `Meta`) que se construyen con métodos de clase y se ejecutan con `#call`.

## 2. Símbolos públicos

| símbolo | tipo | nota |
|---|---|---|
| `CobroDigital` | módulo | namespace raíz (`lib/cobro_digital.rb`) |
| `CobroDigital::SOAP` | constante (`'soap'`) | cliente de transporte default |
| `CobroDigital::HTTPS` | constante (`'https'`) | cliente de transporte alternativo |
| `CobroDigital::CLIENTS` | constante (`[SOAP, HTTPS]`) | clientes soportados |
| `CobroDigital::URI` | constante (String) | endpoint `…/ws3/`; derivada de `ENV['ENDPOINT_COBRODIGITAL']` |
| `CobroDigital::WSDL` | constante (String) | endpoint `…/ws3/?wsdl`; derivada de `ENV['ENDPOINT_COBRODIGITAL']` |
| `CobroDigital::TIMEOUT` | constante (`300`) | open/read timeout en segundos |
| `CobroDigital::LOG_LEVEL` | constante (Symbol) | nivel de log del cliente SOAP; derivada de `ENV['COBRODIGITAL_LOG_LEVEL']` (default `:error`) |
| `CobroDigital::DEBUG_LOG` | constante (Boolean) | `true` si `LOG_LEVEL == :debug`; gobierna `pretty_print_xml` |
| `CobroDigital::LOG_FILTERS` | constante (`[:parametros_de_entrada]`) | nodo SOAP enmascarado en el log (protege sid + PII) |
| `CobroDigital::Https` | módulo | namespace de métodos HTTP |
| `CobroDigital::Https::POST` | constante (`'Post'`) | método HTTP POST |
| `CobroDigital::Https::GET` | constante (`'Get'`) | método HTTP GET |
| `CobroDigital::Client` | clase | transporte hacia el WS |
| `CobroDigital::Client#id_comercio` | attr_accessor | credencial del comercio |
| `CobroDigital::Client#sid` | attr_accessor | credencial del comercio (secreto) |
| `CobroDigital::Client#client_to_use` | attr_accessor | `'soap'` \| `'https'` |
| `CobroDigital::Client#http_method` | attr_accessor | `'Post'` \| `'Get'` (solo transporte HTTPS) |
| `CobroDigital::Client#pagadores` | attr_accessor | acumulador (Array, inicializa `[]`) |
| `CobroDigital::Client#boletas` | attr_accessor | acumulador (Array, inicializa `[]`) |
| `CobroDigital::Client#transacciones` | attr_accessor | acumulador (Array, inicializa `[]`) |
| `CobroDigital::Client#micrositios` | attr_accessor | acumulador (Array, inicializa `[]`) |
| `CobroDigital::Client#requests` | attr_accessor | sin inicializar en `#initialize` |
| `CobroDigital::Client#request_xml` | attr_accessor | XML del último request SOAP (`#soap_client`) |
| `CobroDigital::Client#initialize(attrs={})` | método de instancia | `attrs`: `:id_comercio`, `:sid`, `:con_client`, `:http_method`; levanta `ArgumentError` si `client_to_use` ∉ `CLIENTS` |
| `CobroDigital::Client#soap_client(params)` | método de instancia | arma y ejecuta el request Savon `:webservice_cobrodigital` |
| `CobroDigital::Client#https_client(params)` | método de instancia | ejecuta vía `Net::HTTP` (`Post`/`Get`) |
| `CobroDigital::Client#call(request)` | método de instancia | despacha a `#{client_to_use}_client` mergeando `#comercio` |
| `CobroDigital::Client#comercio` | método de instancia | bloque de identificación `{idComercio, sid, handshake}` (handshake = MD5) |
| `CobroDigital::Operador` | clase | clase base de las operaciones |
| `CobroDigital::Operador#http_method` | attr_accessor | método HTTP del transporte |
| `CobroDigital::Operador#webservice` | attr_accessor | nombre del método del WS |
| `CobroDigital::Operador#render` | attr_accessor | payload de la operación (Hash) |
| `CobroDigital::Operador#response` | attr_accessor | respuesta cruda tras `#call` |
| `CobroDigital::Operador#client` | attr_accessor | `Client` instanciado en `#call` |
| `CobroDigital::Operador#initialize(attrs={})` | método de instancia | `attrs`: `:http_method`, `:webservice`, `:render` |
| `CobroDigital::Operador#request` | método de instancia | `{ metodo_webservice: webservice }.merge(render)` |
| `CobroDigital::Operador#call(id_comercio, sid, opt={})` | método de instancia | instancia `Client` y ejecuta; guarda `#response` |
| `CobroDigital::Operador#parse_response` | método de instancia | decodifica el JSON de salida → `{ resultado:, log:, datos: }` |
| `CobroDigital::Pagador` | clase `< Operador` | operaciones sobre pagadores |
| `CobroDigital::Pagador::CREAR_PAGADOR_WS` | constante (`'crear_pagador'`) | nombre del método WS |
| `CobroDigital::Pagador::EDITAR_PAGADOR_WS` | constante (`'editar_pagador'`) | nombre del método WS |
| `CobroDigital::Pagador::VERIFICAR_PAGADOR_WS` | constante (`'verificar_existencia_pagador'`) | nombre del método WS |
| `CobroDigital::Pagador::OBTENER_CODIGO_ELECTRONICO_WS` | constante (`'obtener_codigo_electronico'`) | nombre del método WS |
| `CobroDigital::Pagador::CONSULTAR_ESTRUCTURA_PAGADORES_WS` | constante (`'consultar_estructura_pagadores'`) | nombre del método WS |
| `CobroDigital::Pagador.crear(pagador)` | método de clase (constructor) | POST; `render: { pagador: }` |
| `CobroDigital::Pagador.editar(identificador, buscar, pagador)` | método de clase (constructor) | POST |
| `CobroDigital::Pagador.verificar(identificador, buscar)` | método de clase (constructor) | GET |
| `CobroDigital::Pagador.codigo_electronico(identificador, buscar)` | método de clase (constructor) | GET |
| `CobroDigital::Pagador.estructura_de_datos` | método de clase (constructor) | GET; `render: {}` |
| `CobroDigital::Boleta` | clase `< Operador` | operaciones sobre boletas |
| `CobroDigital::Boleta::GENERAR_BOLETA_WS` | constante (`'generar_boleta'`) | nombre del método WS |
| `CobroDigital::Boleta::INHABILITAR_BOLETA_WS` | constante (`'inhabilitar_boleta'`) | nombre del método WS |
| `CobroDigital::Boleta::OBTENER_CODIGO_BARRA_WS` | constante (`'obtener_codigo_de_barras'`) | nombre del método WS |
| `CobroDigital::Boleta.generar(identificador, buscar, fechas_vencimiento, importes, concepto, plantilla=nil)` | método de clase (constructor) | POST; `fechas_vencimiento` se formatean a `%Y%m%d` |
| `CobroDigital::Boleta.inhabilitar(nro_boleta)` | método de clase (constructor) | POST |
| `CobroDigital::Boleta.obtener_codigo_de_barras(nro_boleta)` | método de clase (constructor) | GET |
| `CobroDigital::Transaccion` | clase `< Operador` | consulta de transacciones |
| `CobroDigital::Transaccion::CONSULTAR_TRANSACCIONES_WS` | constante (`'consultar_transacciones'`) | nombre del método WS |
| `CobroDigital::Transaccion::FILTRO_TIPO` | constante (`'tipo'`) | clave de filtro |
| `CobroDigital::Transaccion::FILTRO_NOMBRE` | constante (`'nombre'`) | clave de filtro |
| `CobroDigital::Transaccion::FILTRO_CONCEPTO` | constante (`'concepto'`) | clave de filtro |
| `CobroDigital::Transaccion::FILTRO_NRO_BOLETA` | constante (`'nro_boleta'`) | clave de filtro |
| `CobroDigital::Transaccion::FILTRO_IDENTIFICADOR` | constante (`'identificador'`) | clave de filtro |
| `CobroDigital::Transaccion::FILTRO_TIPO_EGRESO` | constante (`'egresos'`) | valor de filtro tipo |
| `CobroDigital::Transaccion::FILTRO_TIPO_INGRESO` | constante (`'ingresos'`) | valor de filtro tipo |
| `CobroDigital::Transaccion::FILTRO_TIPO_TARJETA_CREDITO` | constante (`'tarjeta_credito'`) | valor de filtro tipo |
| `CobroDigital::Transaccion::FILTRO_TIPO_DEBITO_AUTOMATICO` | constante (`'debito_automatico'`) | valor de filtro tipo |
| `CobroDigital::Transaccion.render(desde, hasta, filtros={})` | método de clase | arma `{ desde, hasta, filtros }`; `desde`/`hasta` a `%Y%m%d` |
| `CobroDigital::Transaccion.consultar(desde, hasta, filtros={})` | método de clase (constructor) | GET |
| `CobroDigital::Micrositio` | clase `< Operador` | consulta de actividad de micrositio |
| `CobroDigital::Micrositio::CONSULTAR_ACTIVIDAD_MICROSITIO_WS` | constante (`'consultar_actividad_micrositio'`) | nombre del método WS |
| `CobroDigital::Micrositio.consultar_actividad(identificador, buscar, desde, hasta)` | método de clase (constructor) | GET; `desde`/`hasta` a `%Y%m%d` |
| `CobroDigital::Meta` | clase `< Operador` | agrupa operaciones en una llamada batch al WS `meta` |
| `CobroDigital::Meta::META_WS` | constante (`'meta'`) | nombre del método WS |
| `CobroDigital::Meta.transaction(desde, hasta, filtros={})` | método de clase | helper que arma una `Transaccion.consultar` con filtro tipo=ingreso por default |
| `CobroDigital::Meta.render(objs)` | método de clase | indexa N operaciones en `{ 0 => …, 1 => … }` |
| `CobroDigital::Meta.meta(objs)` | método de clase (constructor) | POST; `render: render(objs)` |
| `CobroDigital::VERSION` | constante (`'1.9.0'`) | versión de la gema (`lib/cobro_digital/version.rb`) |

## 3. Inferencias

| inferencia | confidence | a verificar |
|---|---|---|
| `Client#requests` es atributo público pero no se inicializa ni se usa en el código leído | inferred | ¿atributo muerto o lo setea un consumidor externo? |
| `Client#pagadores/boletas/transacciones/micrositios` se inicializan a `[]` pero no se leen ni escriben en `lib/**` | inferred | acumuladores planeados sin uso actual |
| `Pagador.estructura_de_datos` y `Pagador::CONSULTAR_ESTRUCTURA_PAGADORES_WS` no figuran en el README | declared | superficie real, no documentada para el humano |
| El comentario `@with_handshake` comentado en `Client#initialize` sugiere un handshake opcional descartado | inferred | confirmar que el handshake es siempre-on (hoy lo es vía `#comercio`) |

## 4. Cobertura y fronteras

- **Cobertura:** total sobre `lib/**` (8 archivos). Todos los símbolos top-level del namespace `CobroDigital` están listados.
- **Fuera de alcance (otra capa):** el contrato del payload que cada operación envía al WS y la forma de la respuesta cruda → `docs/consumed/cobrodigital.md` (RFC-018). El significado de negocio de cada operación → `docs/glossary/` (RFC-009, `arch-enrich`).
- **Sin dependencia de ActiveSupport (desde v1.9.0):** el código usa solo stdlib (`to_s.empty?` en `Client#initialize`, `Net::HTTP::Post/Get` en `Client#https_client`). La gema ya no asume Rails → ver `docs/topology/topology.md`.
