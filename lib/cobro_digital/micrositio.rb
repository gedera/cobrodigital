module CobroDigital
  class Micrositio < CobroDigital::Operador

    CONSULTAR_ACTIVIDAD_MICROSITIO_WS = 'consultar_actividad_micrositio'

    # { 'identificador'=>'Su_identificador', 'buscar'=>'1AF8', 'desde'=>'20160720', 'hasta'=>'20160801' }
    def self.consultar_actividad(identificador, buscar, desde, hasta)
      CobroDigital::Micrositio.new( :http_method => CobroDigital::Https::GET,
                                    :webservice  => CONSULTAR_ACTIVIDAD_MICROSITIO_WS,
                                    :render      => { :identificador => identificador,
                                                      :buscar        => buscar,
                                                      :desde         => desde.strftime('%Y%m%d'),
                                                      :hasta         => hasta.strftime('%Y%m%d') } )
    end

  end
end
