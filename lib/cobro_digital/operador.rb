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
      output = response.body[:webservice_cobrodigital_response][:output]
      parsed_response = JSON.parse(output)

      raw_datos = parsed_response['datos'] || []

      datos = raw_datos.map do |row|
        row.is_a?(Array) ? row : (JSON.parse(row) rescue row)
      end.flatten

      { resultado: (parsed_response['ejecucion_correcta'] == '1'), log: parsed_response['log'], datos:  datos }
    end
  end
end
