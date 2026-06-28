# cobro_digital

Adaptador Ruby para el Web Service v3 de [CobroDigital](http://cobrodigital.com), una pasarela de pago. La gema modela las operaciones del WS (crear/editar pagadores, generar/inhabilitar boletas, consultar transacciones y actividad de micrositios) y resuelve el transporte hacia el endpoint, vía SOAP (default) o HTTPS.

Requiere dar de alta el comercio con CobroDigital, que entrega: **id del comercio**, **sid del comercio**, estructura de pagador, plantilla de boleta y manual de implementación. Es posible solicitar datos de prueba.

## Instalación

En el `Gemfile`:

```ruby
gem 'cobro_digital'
```

Luego `bundle`, o instalar a mano con `gem install cobro_digital`.

> **Entorno:** la gema usa `present?` y `constantize` (ActiveSupport) y los ejemplos usan helpers de fecha de ActiveSupport. Asume un host que provee ActiveSupport (típicamente Rails). Ver [`docs/topology/topology.md`](docs/topology/topology.md).

## Configuración

| variable | default | propósito |
|---|---|---|
| `ENDPOINT_COBRODIGITAL` | `https://cobro.digital:14365` | endpoint base del WS (override sandbox/prod) |

Detalle: [`docs/config/configuracion.md`](docs/config/configuracion.md).

## Índice de artefactos

| capa | doc | contenido |
|---|---|---|
| interfaz | [`docs/interface/interface.md`](docs/interface/interface.md) | API Ruby pública (`CobroDigital::*`) |
| consumidas | [`docs/consumed/cobrodigital.md`](docs/consumed/cobrodigital.md) | el WS de CobroDigital: operaciones, payloads, mapeo de error |
| configuración | [`docs/config/configuracion.md`](docs/config/configuracion.md) | inventario de configuración runtime |
| topología | [`docs/topology/topology.md`](docs/topology/topology.md) | dependencias y modos de transporte |
| test | [`docs/test/testing.md`](docs/test/testing.md) | suite RSpec |
| comportamiento | [`docs/behavior/behavior.md`](docs/behavior/behavior.md) | flujos: operación simple · batch meta |
| glosario | [`docs/glossary/glossary.md`](docs/glossary/glossary.md) | términos del dominio (pagador, boleta, transacción…) |
| datos · api · errores · eventos · seguridad · multi-tenancy · data-lifecycle | n/a | ver Mapa de conocimiento en [`AGENTS.md`](AGENTS.md) |
| release | _pendiente_ | se publica con `/gem-release` |

## Uso

Toda operación es una subclase de `CobroDigital::Operador`: se construye con un método de clase y se ejecuta con `#call(comercio_id, comercio_sid)`. La respuesta cruda queda en `#response`; `#parse_response` la decodifica a `{ resultado:, log:, datos: }`.

> En los ejemplos, `comercio_id` y `comercio_sid` son las credenciales entregadas por CobroDigital. **No las hardcodees** — leelas de configuración/entorno (`ENV`, credentials de Rails, etc.).

```ruby
comercio_id  = ENV.fetch('COBRODIGITAL_ID')
comercio_sid = ENV.fetch('COBRODIGITAL_SID') # secreto
```

### Pagadores

Los pagadores son los clientes a facturar.

```ruby
# Crear
estructura = { 'Apellido y nombres' => 'Santos Torrealba', 'Id' => 1234, 'Documento' => 33123456 }
pagador = CobroDigital::Pagador.crear(estructura)
pagador.call(comercio_id, comercio_sid)
pagador.response

# Editar
CobroDigital::Pagador.editar('id', 1234, estructura).call(comercio_id, comercio_sid)

# Verificar existencia
CobroDigital::Pagador.verificar('id', 1234).call(comercio_id, comercio_sid)

# Código electrónico (solo tras generar la primera boleta)
CobroDigital::Pagador.codigo_electronico('id', 1234).call(comercio_id, comercio_sid)

# Estructura de pagadores del comercio
CobroDigital::Pagador.estructura_de_datos.call(comercio_id, comercio_sid)
```

> El WS no controla duplicados: es posible dar de alta el mismo pagador repetidas veces. El control de unicidad es responsabilidad del consumidor.

### Boletas

```ruby
# Generar — fechas (máx 4, la 1ª es la de emisión) e importes (máx 4, el 1º es el valor; el resto, recargos)
vencimientos = [Date.today, Date.today + 10, Date.today + 20]
importes     = [100, 110, 120]
boleta = CobroDigital::Boleta.generar('id', 1234, vencimientos, importes, 'Factura A 10', 'init_273')
boleta.call(comercio_id, comercio_sid)
boleta.response # => numero de boleta

# Inhabilitar
CobroDigital::Boleta.inhabilitar(123).call(comercio_id, comercio_sid)

# Código de barras (uno por vencimiento/importe; render a imagen con la gema barby, código 128b)
CobroDigital::Boleta.obtener_codigo_de_barras(123).call(comercio_id, comercio_sid)
```

### Transacciones

Movimientos de ingreso/egreso de la cuenta. Filtros disponibles (constantes de `CobroDigital::Transaccion`):

| constante | valor |
|---|---|
| `FILTRO_TIPO` | `tipo` |
| `FILTRO_NOMBRE` | `nombre` |
| `FILTRO_CONCEPTO` | `concepto` |
| `FILTRO_NRO_BOLETA` | `nro_boleta` |
| `FILTRO_IDENTIFICADOR` | `identificador` |
| `FILTRO_TIPO_EGRESO` | `egresos` (retiros del dinero depositado) |
| `FILTRO_TIPO_INGRESO` | `ingresos` (cobranzas) |
| `FILTRO_TIPO_TARJETA_CREDITO` | `tarjeta_credito` |
| `FILTRO_TIPO_DEBITO_AUTOMATICO` | `debito_automatico` (CBU) |

```ruby
filtro = { CobroDigital::Transaccion::FILTRO_TIPO => CobroDigital::Transaccion::FILTRO_TIPO_INGRESO }
tx = CobroDigital::Transaccion.consultar(Date.today - 365, Date.today, filtro)
tx.call(comercio_id, comercio_sid)
tx.response
```

### Micrositios

```ruby
CobroDigital::Micrositio
  .consultar_actividad('id', 1234, Date.today - 30, Date.today)
  .call(comercio_id, comercio_sid)
```

### Respuesta y parser

El WS responde un JSON. `#parse_response` (tras `#call`) lo decodifica:

```ruby
boleta = CobroDigital::Boleta.obtener_codigo_de_barras(123)
boleta.call(comercio_id, comercio_sid)
boleta.parse_response
# => { resultado: true,
#      log: ["Codigos de barra de la boleta encontrados correctamente."],
#      datos: ["73852040502403101111600000002"] }
```

| clave | significado |
|---|---|
| `resultado` | `true` si la consulta fue correcta (`ejecucion_correcta == '1'`) |
| `log` | mensajes / errores del WS |
| `datos` | resultado de la consulta (opcional, según la operación) |

## SOAP vs HTTPS

El transporte default es SOAP (vía `savon`). El cliente HTTPS (`Net::HTTP`) es alternativo: `Cliente.new(con_client: CobroDigital::HTTPS)`. Detalle de ambos modos en [`docs/topology/topology.md`](docs/topology/topology.md).

## Desarrollo

```sh
bundle exec rspec   # suite (ver docs/test/test.md)
bundle exec rake    # task default :spec
```

## Contributing

Bug reports y pull requests en GitHub: <https://github.com/gedera/cobrodigital>.

## License

Open source bajo los términos de la [MIT License](http://opensource.org/licenses/MIT).
