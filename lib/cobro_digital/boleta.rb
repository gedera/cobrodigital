module CobroDigital
  class Boleta < CobroDigital::Operador

    GENERAR_BOLETA_WS       = 'generar_boleta'
    INHABILITAR_BOLETA_WS   = 'inhabilitar_boleta'
    OBTENER_CODIGO_BARRA_WS = 'obtener_codigo_de_barras'

    # { 'identificador' => 'Su_identificador', 'buscar' => '1AF8', 'fechas_vencimiento' => ['20170901','20170905'], 'importes' => [100.98, 102], 'concepto' => 'Boleta de Prueba', 'plantilla' => 'init' }
    def self.generar(identificador, buscar, fechas_vencimiento, importes, concepto, plantilla=nil)
      CobroDigital::Boleta.new( :http_method => CobroDigital::Https::POST,
                                :webservice  => GENERAR_BOLETA_WS,
                                :render      => { :identificador      => identificador,
			                                            :buscar             => buscar,
			                                            :fechas_vencimiento => fechas_vencimiento.map{ |date| date.strftime('%Y%m%d') },
                                                  :importes           => importes,
		                                              :concepto           => concepto,
		                                              :plantilla          => plantilla })
    end

    # { 'nro_boleta'=>'1' }
    def self.inhabilitar(nro_boleta)
      CobroDigital::Boleta.new( :http_method => CobroDigital::Https::POST,
                                :webservice  => INHABILITAR_BOLETA_WS,
                                :render      => { :nro_boleta  => nro_boleta } )
    end

    # { 'nro_boleta'=>'1' }
    def self.obtener_codigo_de_barras(nro_boleta)
      CobroDigital::Boleta.new( :http_method => CobroDigital::Https::GET,
                                :webservice  => OBTENER_CODIGO_BARRA_WS,
                                :render      => { :nro_boleta  => nro_boleta } )
    end

  end
end
