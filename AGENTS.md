# AGENTS.md — cobro_digital

Fuente de verdad para estructura, convenciones, entorno y arquitectura de esta gema. Leer antes de hacer cambios.

## 1. Identidad

`cobro_digital` es una gema Ruby: adaptador para comunicarse con el Web Service de [CobroDigital](http://cobrodigital.com) (versión 3.0 del WS), una pasarela de pago.

- `summary`: "Adaptador CobroDigital" (`cobro_digital.gemspec`).
- `description`: "Adaptador para el Web Service de CobroDigital".
- La gema modela las operaciones del webservice (crear/editar pagadores, generar/inhabilitar boletas, consultar transacciones y actividad de micrositios) y resuelve el transporte hacia el endpoint de CobroDigital.
- Requiere credenciales del comercio (`id_comercio` y `sid`) entregadas por CobroDigital para autenticarse contra el webservice (ver `README.md`).
- El endpoint default es `https://cobro.digital:14365/ws3/`, configurable vía la variable de entorno `ENDPOINT_COBRODIGITAL` (`lib/cobro_digital.rb`).

## 2. Convenciones del framework

Este repo consume skills del framework de agentes, declaradas en el manifiesto raíz `skills.yml`.

- Las skills vendoreadas en `.agents/skills/` traen conocimiento de las dependencias del repo.
- Leer la skill de una dependencia antes de responder o decidir sobre ella.

## 3. Entorno

- Ruby: el repo no fija versión vía `.ruby-version`. El único pin de versión presente es el legacy `.travis.yml` (Ruby 1.8.7), que NO refleja el entorno de desarrollo actual; confirmar la versión de Ruby antes de asumirla.
- Gestor de versiones: chruby (no rvm/rbenv).
- Dependencias: gestionadas con Bundler. El `Gemfile` toma las dependencias del gemspec (`gemspec`). No hay `Gemfile.lock` versionado.
- Dependencia de runtime: `savon ~> 2.12.1` (cliente SOAP).
- Dependencias de desarrollo: `bundler ~> 2.6.6`, `rake >= 13.2.1` (`cobro_digital.gemspec`).

## 4. YARD

Documentación incremental con la skill `yard`.

- Verificar cobertura de documentación: `bundle exec yard stats --list-undoc`.

## 5. Testing

- Framework: RSpec (`.rspec`, carpeta `spec/`, `Rakefile` registra `RSpec::Core::RakeTask`).
- Correr la suite: `bundle exec rspec` (o `bundle exec rake`, cuya tarea default es `:spec`).
- Código nuevo debe venir acompañado de tests.

## 6. Releases

- Publicar con la skill `/gem-release`.

## 7. Arquitectura

El código vive en `lib/` bajo el módulo `CobroDigital` (`lib/cobro_digital.rb` es el require raíz).

- `CobroDigital::Client` (`lib/cobro_digital.rb`): transporte hacia el webservice. Mantiene credenciales (`id_comercio`, `sid`) y elige el cliente a usar: `soap` (vía Savon, default) o `https` (vía `Net::HTTP`, métodos `Post`/`Get`). Arma el bloque de identificación del comercio (incluye un `handshake` MD5) y ejecuta la llamada.
- `CobroDigital::Operador` (`lib/cobro_digital/operador.rb`): clase base de las operaciones. Define `request`, `call(id_comercio, sid, opt)` —que instancia un `Client` y ejecuta— y `parse_response`, que decodifica el JSON de salida del webservice en `{ resultado:, log:, datos: }`.
- `CobroDigital::Pagador` (`lib/cobro_digital/pagador.rb`): operaciones sobre pagadores (clientes a facturar): `crear`, `editar`, `verificar`, `codigo_electronico`, `estructura_de_datos`.
- `CobroDigital::Boleta` (`lib/cobro_digital/boleta.rb`): operaciones sobre boletas: `generar`, `inhabilitar`, `obtener_codigo_de_barras`.
- `CobroDigital::Transaccion` (`lib/cobro_digital/transaccion.rb`): consulta de transacciones (`consultar`) con filtros por tipo (ingresos, egresos, tarjeta de crédito, débito automático), nombre, concepto, nro de boleta e identificador.
- `CobroDigital::Micrositio` (`lib/cobro_digital/micrositio.rb`): consulta de actividad de micrositio (`consultar_actividad`).
- `CobroDigital::Meta` (`lib/cobro_digital/meta.rb`): agrupa varias operaciones en una sola llamada al webservice `meta` (batch), y expone helpers (`transaction`, `render`, `meta`).
- `CobroDigital::VERSION` (`lib/cobro_digital/version.rb`): versión actual de la gema.

Cada operación es una subclase de `Operador` que se construye con métodos de clase (constructores) y luego se ejecuta con `#call`.
