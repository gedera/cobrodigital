# CobroDigital

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/cobro_digital`. To experiment with that code, run `bin/console` for an interactive prompt.

Para poder hacer uso de la gema. Require previamente comunicarse con CobroDigital para dar de alta el comercio que se hara uso del servicio. Ellos haran entrega de:

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
* Es importante determinar un identificador unico por pagador.
* El webservice de CobroDigital solo verifica que la estructura sea correcta, pero no realiza ninguna tipo de validación, por lo tanto es importante llevar el control de si un pagador ya fue dado de alta o no. Ya que es posible dar de alta eternamente el mismo pagador.

Para la creación de un pagador simplemente es neceario comunicar:
* Estructura de un pagador.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
estructura_pagador = 'Apellido y nombres' => "Santos Torrealba", 'Id' => 1234, 'Documento' => 33123456, 'Direccion del cliente' => "Falsa 1234", 'Telefono' => "222314", 'E-mail' => "santos.torrealba@who.com" # Estructura brindada por cobrodigital para realizar pruebas
pagador = CobroDigital.Pagador.crear(estructura_pagador)
response = pagador.call(comercio_id, comercio_sid)
```

#### Editar un Pagador

Consiste en editar algun dato dentro de la estructura de pagador de uno especifico.

Para la edición de un pagador simplemente es necesario comunicar:
* Nombre del identificador.
* Valor del identificador.
* Nueva configuración de la estructura pagador.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
estructura_pagador = 'Apellido y nombres' => "Probando Probando", 'Id' => 1234, 'Documento' => 33123456, 'Direccion del cliente' => "Falsa 1234", 'Telefono' => "222314", 'E-mail' => "santos.torrealba@who.com" # Estructura brindada por cobrodigital para realizar pruebas
pagador = CobroDigital.Pagador.editar('id', 1234, estructura_pagador)
response = pagador.call(comercio_id, comercio_sid)
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
response = pagador.call(comercio_id, comercio_sid)
```

#### Codigo Electronico

Para obtener el codigo electronico con el cual le posibilitara a las personas realizar pagos por medio de pagosmiscuentas y linkpagos.

Para la verificación de un pagador simplemente es necesario comunicar:
* Nombre del identificador.
* Valor del identificador.

Retorno el numero de codigo electronico.

```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
pagador = CobroDigital.Pagador.codigo_electronico('id', 1234)
response = pagador.call(comercio_id, comercio_sid)
```

### Boleta

Las boletas es la menera de informar la factura a CobroDigital para poder realizar el cobro por algunos de los medios proporcionados por ellos, las acciones posibles son las de `generar boleta`, `inhabilitar boleta`, `obtener codigo de barras`.

#### Generar Boleta

Es la menera de informar una factura a cobrar.

Para la generación de una boleta es necesario comunicar:
* nombre del identificador.
* el valor del identificador.
* Array de vencimientos como maximo 4. Siempre la primera fecha deberá ser la fecha de emisión. ejemplo: [Date.today, Date.today+10.days, Date.today+20.days]
* Array de importes como maximo 4. Siempre el primer monto es el valor de la factura, los siguientes son con los recargos. [100, 110, 120]
* concepto, una simple leyenda.
* plantilla, es la plantilla de la boleta (Cada comercio debe proporcionar esta plantilla)

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
response = boleta.call(comercio_id, comercio_sid)
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
response = boleta.call(comercio_id, comercio_sid)
```

#### Obtener codigo de barras

Obtener el string de los codigos de barras. Seran tantos como vencimientos e importes informados. En caso de querer renderizarlo a imagen debera de hacer uso del codigo 128b, para ello se puede hacer uso de la gema barby.

Para la obtención de los codigos de barra es necesario comunicar:
* numero de boleta (obtenida en la generación)


```ruby
comercio_id = 'HA765587' #Brindado por cobrodigital para realizar pruebas
comercio_sid = 'wsZ0ya68K791phuu76gQ5L662J6F2Y4j7zqE2Jxa3Mvd22TWNn4iip6L9yq' #Brindado por cobrodigital para realizar pruebas
numero_boleta = 123
boleta = CobroDigital.Boleta.obtener_codigo_de_barras(numero_boleta)
response = boleta.call(comercio_id, comercio_sid)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cobro_digital. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

