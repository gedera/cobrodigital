# coding: utf-8
require "cobro_digital/version"
require "cobro_digital/operador"
require "cobro_digital/pagador"
require "cobro_digital/boleta"
require "cobro_digital/transaccion"
require "cobro_digital/micrositio"
require "cobro_digital/meta"
require "savon"
require "net/http"
require "uri"
require "digest"

module CobroDigital

  SOAP    = 'soap'
  HTTPS   = 'https'

  CLIENTS = [SOAP, HTTPS]
  URI     = ((ENV['ENDPOINT_COBRODIGITAL'] || 'https://cobro.digital:14365') + '/ws3/').freeze
  WSDL    = ((ENV['ENDPOINT_COBRODIGITAL'] || 'https://cobro.digital:14365') + '/ws3/?wsdl').freeze

  TIMEOUT = 300

  # Nivel de log del cliente SOAP. Default `:error` para no filtrar el `sid`
  # ni PII del pagador a los logs de la app. Subir a `:debug` solo para
  # troubleshooting explícito (vía ENV['COBRODIGITAL_LOG_LEVEL']).
  # Se sanea el string vacío (`COBRODIGITAL_LOG_LEVEL=`) que produciría `:""`.
  _log_level = ENV['COBRODIGITAL_LOG_LEVEL'].to_s
  LOG_LEVEL  = (_log_level.empty? ? 'error' : _log_level).to_sym
  DEBUG_LOG  = (LOG_LEVEL == :debug)

  # Nodo del mensaje SOAP que transporta credenciales (`sid`) y PII del pagador.
  # Savon lo enmascara como `***FILTERED***` en el log, incluso en `:debug`.
  LOG_FILTERS = [:parametros_de_entrada].freeze

  module Https
    POST = 'Post'
    GET  = 'Get'
  end

  class Client

    attr_accessor :id_comercio, :sid, :client_to_use, :http_method, :pagadores, :boletas, :transacciones, :micrositios, :requests, :request_xml

    def initialize(attrs={})
      @id_comercio    = attrs[:id_comercio]
      @sid            = attrs[:sid]
      @client_to_use  = attrs[:con_client].present? ? attrs[:con_client] : CobroDigital::SOAP
      # @with_handshake = attrs[:handshake].present? ? attrs[:handshake] : true
      @pagadores      = []
      @boletas        = []
      @transacciones  = []
      @micrositios    = []
      @request_xml    = nil

      unless CobroDigital::CLIENTS.include?(@client_to_use)
        raise ArgumentError, "client_to_use inválido: #{@client_to_use.inspect} (esperado uno de #{CobroDigital::CLIENTS.inspect})"
      end
    end

    def soap_client(params)
      # `log: true` para que se sigan registrando errores SOAP/HTTP; la
      # verbosidad la controla `log_level` (default :error → no loguea el body).
      # `filters` enmascara el nodo con sid + PII como ***FILTERED*** si algo se
      # llega a loguear. ADVERTENCIA: con COBRODIGITAL_LOG_LEVEL=debug el XML
      # formateado incluye el sid en claro — no habilitar debug en producción.
      client = Savon.client(
        wsdl: CobroDigital::WSDL,
        log: true,
        log_level: CobroDigital::LOG_LEVEL,
        filters: CobroDigital::LOG_FILTERS,
        pretty_print_xml: CobroDigital::DEBUG_LOG,
        open_timeout: CobroDigital::TIMEOUT,
        read_timeout: CobroDigital::TIMEOUT
      )
      operation = client.operation(:webservice_cobrodigital)
      request = operation.build(message: { 'parametros_de_entrada' => params.to_json })
      # Contrato público: `@request_xml` siempre disponible tras el call. Retiene
      # el XML con sid + PII en memoria — el consumidor no debe loguearlo.
      @request_xml = request.pretty

      client.call(:webservice_cobrodigital, message: { 'parametros_de_entrada' => params.to_json })
    end

    def https_client(params)
      case http_method
      when CobroDigital::Https::POST
        uri = ::URI.parse(CobroDigital::URI)
        req = "Net::HTTP::#{http_method}".constantize.new(uri)
        req.set_form_data(params)
      when CobroDigital::Https::GET
        uri = ::URI.parse([CobroDigital::URI, ::URI.encode_www_form(params)].join('?'))
        req = "Net::HTTP::#{http_method}".constantize.new(uri)
      end

      Net::HTTP.start(
        uri.hostname,
        uri.port,
        use_ssl: uri.scheme == CobroDigital::HTTPS,
        open_timeout: CobroDigital::TIMEOUT,
        read_timeout: CobroDigital::TIMEOUT
      ) do |http|
        http.request(req)
      end
    end

    def call(request)
      send("#{client_to_use}_client", comercio.merge(request))
    end

    def comercio
      { 'idComercio' => @id_comercio, 'sid' => @sid, 'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s) }
    end

  end
end
