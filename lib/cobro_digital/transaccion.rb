module CobroDigital
  class Transaccion < CobroDigital::Operador

    CONSULTAR_TRANSACCIONES_WS = 'consultar_transacciones'

    # { 'desde'=>'20160932', 'hasta'=>'20161001' }
    def self.consultar(desde, hasta)
      CobroDigital::Transaccion.new( :http_method => CobroDigital::Https::GET,
                                     :webservice  => CONSULTAR_TRANSACCIONES_WS,
                                     :render      => { :desde => desde.strftime('%Y%m%d'),
                                                       :hasta => hasta.strftime('%Y%m%d') } )
    end

  end
end
