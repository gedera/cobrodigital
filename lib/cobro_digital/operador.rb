module CobroDigital
  class Operador

    attr_accessor :http_method, :webservice, :render, :response

    def initialize(attrs={})
      @http_method = attrs[:http_method]
      @webservice  = attrs[:webservice]
      @render      = attrs[:render]
    end

    def request
      { :metodo_webservice => @webservice }.merge(render)
    end

    def call(id_comercio, sid, opt={})
      client = CobroDigital::Client.new(opt.merge(:id_comercio => id_comercio, :sid => sid, :http_method => http_method))
      @response = client.call(request)
    end

  end
end
