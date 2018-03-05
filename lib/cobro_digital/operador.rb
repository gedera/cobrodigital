module CobroDigital
  class Operador

    attr_accessor :http_method, :webservice, :render, :response, :client

    def initialize(attrs={})
      @http_method = attrs[:http_method]
      @webservice  = attrs[:webservice]
      @render      = attrs[:render]
      @client      = nil
    end

    def request
      { :metodo_webservice => @webservice }.merge(render)
    end

    def call(id_comercio, sid, opt = {})
      @client = CobroDigital::Client.new(opt.merge(:id_comercio => id_comercio, :sid => sid, :http_method => http_method))
      @response = @client.call(request)
    end

    def parse_response
      parsed_response = JSON.parse(response.body[:webservice_cobrodigital_response][:output])

      datos = []

      if parsed_response['datos'].present?
        parsed_response['datos'].each do |data|
          _data = data.split("\"")
          _data.delete("")
          datos << _data
        end
      end

      { resultado: (parsed_response['ejecucion_correcta'] == '1'), log: parsed_response['log'], datos: datos.flatten }
    end

  end
end
