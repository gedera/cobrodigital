module CobroDigital
  class Meta < CobroDigital::Operador

    META_WS = 'meta'.freeze

    # md5(microtime(true)*rand())
    # { 'handshake'=>Digest::MD5.hexdigest(Time.now.to_f.to_s),
    #   'metodo_webservice'=>'meta',
    #   '0' => { 'metodo_webservice' => 'crear_pagador',
    #            'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s),
    #            'pagador' => { 'Nombre' => 'Juan',
    #                           'Su_identificador' => '1AF8',
    #                           'Unidad' => '201' } },
    #   '1' => { 'metodo_webservice' => 'crear_pagador',
    #            'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s),
    #            'pagador'=> { 'Nombre'=>'Pedro',
    #                          'Su_identificador'=>'1AG9',
    #                          'Unidad'=>'202' } },
    #   '2' => { 'metodo_webservice' => 'generar_boleta',
    #            'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s),
    #            'identificador' => 'Su_identificador',
    #            'buscar' => '1AF8',
    #            'importes'=> [10.50],
    #            'fechas_vencimiento' => ['20160930'],
    #            'plantilla' => 'init',
    #            'concepto' => 'Test I'},
    #   '3' => { 'metodo_webservice' => 'generar_boleta',
    #            'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s),
    #            'identificador' => 'Su_identificador',
    #            'buscar' => '1AG9',
    #            'importes'=> [11.99],
    #            'fechas_vencimiento' => ['20160929'],
    #            'plantilla' => 'init',
    #            'concepto' => 'Test II'},
    #   '4' => { 'metodo_webservice' => 'inhabilitar_boleta',
    #            'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s),
    #            'nro_boleta' => '4' },
    #   '5' => { 'metodo_webservice' => 'inhabilitar_boleta',
    #            'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s),
    #            'nro_boleta' => '65' } }

    def self.transaction(desde, hasta, filtros = {})
      filter = {
        ::CobroDigital::Transaccion::FILTRO_TIPO => ::CobroDigital::Transaccion::FILTRO_TIPO_INGRESO
      }

      filter.merge!(filtros) unless filtros.empty?

      CobroDigital::Transaccion.consultar(
        desde,
        hasta,
        filter
      )
    end

    def self.render(objs)
      querys = {}
      objs.each_with_index do |obj, i|
        querys[i] = obj.render.merge(metodo_webservice: obj.webservice)
      end
      querys
    end

    def self.meta(objs)
      CobroDigital::Meta.new(
        :http_method => CobroDigital::Https::POST,
        :webservice  => META_WS,
        :render      => render(objs)
      )
    end
  end
end
