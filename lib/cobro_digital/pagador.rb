module CobroDigital
  class Pagador < CobroDigital::Operador

    CREAR_PAGADOR_WS                  = 'crear_pagador'
    EDITAR_PAGADOR_WS                 = 'editar_pagador'
    VERIFICAR_PAGADOR_WS              = 'verificar_existencia_pagador'
    OBTENER_CODIGO_ELECTRONICO_WS     = 'obtener_codigo_electronico'
    CONSULTAR_ESTRUCTURA_PAGADORES_WS = 'consultar_estructura_pagadores'

    # { 'Nombre' => 'Juan', 'Su_identificador' => '1AF8', 'Unidad' => '201' }
    def self.crear(pagador)
      CobroDigital::Pagador.new( :http_method => CobroDigital::Https::POST,
                                 :webservice  => CREAR_PAGADOR_WS,
                                 :render      => { :pagador => pagador } )
    end

    # { 'identificador' => 'Su_identificador', 'buscar' => '1AF8', 'pagador' => { 'Nombre'=>'Juan Pablo' } }
    def self.editar(identificador, buscar, pagador)
      CobroDigital::Pagador.new( :http_method => CobroDigital::Https::POST,
                                 :webservice  => EDITAR_PAGADOR_WS,
                                 :render      => { :identificador => identificador,
                                                   :buscar        => buscar,
                                                   :pagador       => pagador })
    end

    # { 'identificador' => 'Su_identificador', 'buscar'=>'1AF8' }
    def self.verificar(identificador, buscar)
      CobroDigital::Pagador.new( :http_method => CobroDigital::Https::GET,
                                 :webservice  => VERIFICAR_PAGADOR_WS,
                                 :render      => { :identificador => identificador,
                                                   :buscar        => buscar })
    end

    def self.codigo_electronico(identificador, buscar)
      CobroDigital::Pagador.new( :http_method => CobroDigital::Https::GET,
                                 :webservice  => OBTENER_CODIGO_ELECTRONICO_WS,
                                 :render      => { :identificador => identificador,
                                                   :buscar        => buscar })
    end

    def self.estructura_de_datos
      CobroDigital::Pagador.new(:http_method => CobroDigital::Https::GET,
                                :webservice  => CONSULTAR_ESTRUCTURA_PAGADORES_WS,
                                :render      => {})
    end
  end
end
