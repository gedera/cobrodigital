# coding: utf-8
module CobroDigital
  class Transaccion < CobroDigital::Operador

    CONSULTAR_TRANSACCIONES_WS = 'consultar_transacciones'

    FILTRO_TIPO          = 'tipo'
    FILTRO_NOMBRE        = 'nombre'
    FILTRO_CONCEPTO      = 'concepto'
    FILTRO_NRO_BOLETA    = 'nro_boleta'
    FILTRO_IDENTIFICADOR = 'identificador'

    FILTRO_TIPO_EGRESO            = 'egresos'           # Transacciones de retiro del dinero depositado por los pagadores.
    FILTRO_TIPO_INGRESO           = 'ingresos'          # Todo lo que incremente el saldo de la cuenta CobroDigital. Generalmente son sólo las cobranzas.
    FILTRO_TIPO_TARJETA_CREDITO   = 'tarjeta_credito'   # Solo aquellas cobranzas abonadas con tarjeta de crédito.
    FILTRO_TIPO_DEBITO_AUTOMATICO = 'debito_automatico' # Está relacionado a los débitos realizados por CBU.

    # { 'desde'=>'20160932', 'hasta'=>'20161001' }
    def self.consultar(desde, hasta, filtros={})
      CobroDigital::Transaccion.new( :http_method => CobroDigital::Https::GET,
                                     :webservice  => CONSULTAR_TRANSACCIONES_WS,
                                     :render      => { :desde   => desde.strftime('%Y%m%d'),
                                                       :hasta   => hasta.strftime('%Y%m%d'),
                                                       :filtros => filtros } )
    end

  end
end
