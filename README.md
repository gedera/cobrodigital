# CobroDigital

Adaptador para comunicarse con el servicio WS de CobroDigital (Version 3.0).

Para poder hacer uso de la gema. Requiere previamente comunicarse con CobroDigital para dar de alta el comercio que se hará uso del servicio (Es posible solicitar datos de prueba). Ellos harán entrega de:

* id del comercio (requerido para cualquier comunicación con el webservice, es la manera de identificarse con el webservice)
* sid del comercio (requerido para cualquier comunicación con el webservice, es la manera de identificarse con el webservice)
* Estructura de pagador (Esta estructura debe ser informada por cada comercio. esta estructura es del cliente a facturar)
* Plantilla, modelo de boleta para los clientes.
* Manual de implementación.

## Instalación

Añadir esta linea en el Gemfile:

```ruby
gem 'cobro_digital'
```

Luego ejecuta:

    $ bundle

O instala la gema a mano:

    $ gem install cobro_digital

## Uso

### Pagadores

Los Pagadores son los clientes a los que se les facturará, las acciones posibles son las de `crear un pagador`, `editar un pagador`, `verificar un pagador`, `obtener codigo electronico`.

#### Crear Pagador

Consiste en crear un pagador en el webservice de CobroDigital, para ello es necesario:

* Comunicarse con CobroDigital para definir la estructura de pagador que se quiera notificar.
* Es importante determinar un identificador único por pagador.
* El webservice de CobroDigital solo verifica que la estructura sea correcta, pero no realiza ninguna tipo de validación, por lo tanto es importante llevar el control de si un pagador ya fue dado de alta o no. Ya que es posible dar de alta eternamente el mismo pagador.

Para la creación de un pagador simplemente es necesario comunicar:
* Estructura de un pagador.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
estructura_pagador = 'Apellido y nombres' => "Santos Torrealba", 'Id' => 1234, 'Documento' => 33123456, 'Direccion del cliente' => "Falsa 1234", 'Telefono' => "222314", 'E-mail' => "santos.torrealba@who.com" # Estructura brindada por cobrodigital para realizar pruebas
pagador = CobroDigital.Pagador.crear(estructura_pagador)
pagador.call(comercio_id, comercio_sid)
pagador.response # Obtengo el resultado.
```

#### Editar un Pagador

Consiste en editar algún dato dentro de la estructura de pagador de uno especifico.

Para la edición de un pagador simplemente es necesario comunicar:
* Nombre del identificador.
* Valor del identificador.
* Nueva configuración de la estructura pagador.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
estructura_pagador = 'Apellido y nombres' => "Probando Probando", 'Id' => 1234, 'Documento' => 33123456, 'Direccion del cliente' => "Falsa 1234", 'Telefono' => "222314", 'E-mail' => "santos.torrealba@who.com" # Estructura brindada por cobrodigital para realizar pruebas
pagador = CobroDigital.Pagador.editar('id', 1234, estructura_pagador)
pagador.call(comercio_id, comercio_sid)
pagador.response # Obtengo el resultado.
```

#### Verificar Pagador

Permite verificar la existencia o no de un pagador en el webservice.

Para la verificación de un pagador simplemente es necesario comunicar:
* Nombre del identificador.
* Valor del identificador.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
pagador = CobroDigital.Pagador.verificar('id', 1234)
pagador.call(comercio_id, comercio_sid)
pagador.response # Obtengo el resultado.
```

#### Codigo Electronico

Para obtener el código electrónico con el cual le posibilitara a las personas realizar pagos por medio de pagosmiscuentas y linkpagos. Cabe que aclarar que este codigo solo sera posible obtener una vez generada la primer boleta.

Para la verificación de un pagador simplemente es necesario comunicar:
* Nombre del identificador.
* Valor del identificador.

Retorno el numero de código electrónico.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
pagador = CobroDigital.Pagador.codigo_electronico('id', 1234)
pagador.call(comercio_id, comercio_sid)
pagador.response # Obtengo el resultado.
```

### Boleta

Las boletas es la manera de informar la factura a CobroDigital para poder realizar el cobro por algunos de los medios proporcionados por ellos, las acciones posibles son las de `generar boleta`, `inhabilitar boleta`, `obtener codigo de barras`.

#### Generar Boleta

Es la manera de informar una factura a cobrar.

Para la generación de una boleta es necesario comunicar:
* nombre del identificador.
* el valor del identificador.
* Array de vencimientos como máximo 4. Siempre la primera fecha deberá ser la fecha de emisión. ejemplo: [Date.today, Date.today+10.days, Date.today+20.days]
* Array de importes como máximo 4. Siempre el primer monto es el valor de la factura, los siguientes son con los recargos. [100, 110, 120]
* concepto, una simple leyenda.
* plantilla, es la plantilla de estilo de la boleta (Cada comercio debe proporcionar esta plantilla, comunicarse con CobroDigital para mas detalle)

Retorna un numero de boleta.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
nombre_identificador = 'id'
valor_identificador = 1234
vencimientos = [Date.today, Date.today+10.days, Date.today+20.days]
importes = [100,110,120]
concepto = "Factura A 10"
plantilla = 'init_273' #Proporcionado por CobroDigital para realizar pruebas.
boleta = CobroDigital.Boleta.generar(nombre_identificador, valor_identificador, vencimientos, importes, concepto, plantilla)
boleta.call(comercio_id, comercio_sid)
boleta.response # Obtengo el resultado.
```

#### Inhabilitar Boleta

Dar de baja una boleta ya generada en el webservice.

Para la inhabilitación de una boleta es necesario comunicar:
* numero de boleta (obtenida en la generación)

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
numero_boleta = 123
boleta = CobroDigital.Boleta.inhabilitar(numero_boleta)
boleta.call(comercio_id, comercio_sid)
boleta.response # Obtengo el resultado.
```

#### Obtener codigo de barras

Obtener el string de los códigos de barras. Serán tantos como vencimientos e importes informados. En caso de querer renderizarlo a imagen deberá de hacer uso del código 128b, para ello se puede hacer uso de la gema barby.

Para la obtención de los códigos de barra es necesario comunicar:
* numero de boleta (obtenida en la generación)


```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
numero_boleta = 123
boleta = CobroDigital.Boleta.obtener_codigo_de_barras(numero_boleta)
boleta.call(comercio_id, comercio_sid)
boleta.response # Obtengo el resultado.
```

### Transacciones

Es posible realizar todas los movimientos ya sea de ingreso y egreso en la cuenta proporcionada a cobrodigital.

Para poder realizar las consulta de las transacciones es necesario comunicar:
* fecha_desde: Comienzo desde donde se quiere obtener las transacciones.
* fecha_hasta: Fin desde donde se quiere obtener las transacciones.
* filtros: Los filtros nos permiten obtener transacciones mas especificas:
** nombre: Nombre del pagador.
** concepto: Concepto de la transaccion.
** nro_boleta: Transacciones relacionadas a una boleta especifica.
** identificador: consiste en el nombre del identificador del pagador, mas el valor del identificador. Por ejemplo "dni: 11222333". 
** tipo: Relacionado con la clase de transacciones. Es posible consultar los siguientes valores:
*** egresos: Transacciones de retiro del dinero depositado por los pagadores.
*** ingresos: Todo lo que incremente el saldo de la cuenta CobroDigital. Generalmente son sólo las cobranzas.
*** tarjeta_credito: Solo aquellas cobranzas abonadas con tarjeta de crédito.
*** debito_automatico: Está relacionado a los débitos realizados por CBU.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
numero_boleta = 123
filtro = { CobroDigital.Transaccion::FILTRO_TIPO => CobroDigital.Transaccion::FILTRO_TIPO_INGRESO} # Solo consulta por transacciones de ingreso
transacciones = CobroDigital.Transaccion.consultar(Date.today - 1.year, Date.today)
transacciones.call(comercio_id, comercio_sid)
transacciones.response # Obtengo el resultado.
```

Para consultar los tipos de filtros, se puede consultar las siguientes constantes:

```ruby
CobroDigital.Transaccion::FILTRO_TIPO          => 'tipo'
CobroDigital.Transaccion::FILTRO_NOMBRE        => 'nombre'
CobroDigital.Transaccion::FILTRO_CONCEPTO      => 'concepto'
CobroDigital.Transaccion::FILTRO_NRO_BOLETA    => 'nro_boleta'
CobroDigital.Transaccion::FILTRO_IDENTIFICADOR => 'identificador'

CobroDigital.Transaccion::FILTRO_TIPO_EGRESO            => 'egresos'           # Transacciones de retiro del dinero depositado por los pagadores.
CobroDigital.Transaccion::FILTRO_TIPO_INGRESO           => 'ingresos'          # Todo lo que incremente el saldo de la cuenta CobroDigital. Generalmente son sólo las cobranzas.
CobroDigital.Transaccion::FILTRO_TIPO_TARJETA_CREDITO   => 'tarjeta_credito'   # Solo aquellas cobranzas abonadas con tarjeta de crédito.
CobroDigital.Transaccion::FILTRO_TIPO_DEBITO_AUTOMATICO => 'debito_automatico' # Está relacionado a los débitos realizados por CBU.

filtro = { CobroDigital.Transaccion::FILTRO_TIPO          => CobroDigital.Transaccion::FILTRO_TIPO_INGRESO,
           CobroDigital.Transaccion::FILTRO_NOMBRE        => "Algun nombre",
           CobroDigital.Transaccion::FILTRO_CONCEPTO      => "Algun concepto"
           CobroDigital.Transaccion::FILTRO_NRO_BOLETA    => "Algun numero de boleta",
           CobroDigital.Transaccion::FILTRO_IDENTIFICADOR => "Algun identificar" }
```


## SOAP vs HTTPS

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cobro_digital. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
