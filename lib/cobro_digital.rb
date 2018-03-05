# coding: utf-8
require "cobro_digital/version"
require "cobro_digital/operador"
require "cobro_digital/pagador"
require "cobro_digital/boleta"
require "cobro_digital/transaccion"
require "cobro_digital/micrositio"
require "cobro_digital/meta"
require "savon"

module CobroDigital

  SOAP    = 'soap'
  HTTPS   = 'https'

  CLIENTS = [SOAP, HTTPS]
  URI     = 'https://www.cobrodigital.com:14365/ws3/'
  WSDL    = 'https://www.cobrodigital.com:14365/ws3/?wsdl'

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
    end

    def soap_client(params)
      client = Savon.client(wsdl: CobroDigital::WSDL, log_level: :debug, pretty_print_xml: true)
      operation = client.operation(:webservice_cobrodigital)
      request = operation.build(message: { 'parametros_de_entrada' => params.to_json })
      @request_xml = request.pretty
      client.call(:webservice_cobrodigital, message: { 'parametros_de_entrada' => params.to_json })
    end

    def https_client(params)
      case http_method
      when CobroDigital::Https::POST
        uri = URI(CobroDigital::URI)
        req = "Net::HTTP::#{http_method}".constantize.new(uri)
        req.set_form_data(params)
      when CobroDigital::Https::GET
        uri = URI([CobroDigital::URI, URI.encode_www_form(data)].join('?'))
        req = "Net::HTTP::#{http_method}".constantize.new(uri)
      end

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == CobroDigital::HTTPS) { |http| http.request(req) }
    end

    def call(request)
      send("#{client_to_use}_client", comercio.merge(request))
    end

    def comercio
      { 'idComercio' => @id_comercio, 'sid' => @sid, 'handshake' => Digest::MD5.hexdigest(Time.now.to_f.to_s) }
    end

  end
end
