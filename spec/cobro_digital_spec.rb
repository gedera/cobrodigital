require 'spec_helper'
require 'json'
require 'date'

describe CobroDigital do
  it 'has a version number' do
    expect(CobroDigital::VERSION).not_to be nil
  end
end

describe CobroDigital::Pagador do
  describe '.crear' do
    subject(:op) { described_class.crear('Nombre' => 'Juan') }

    it 'apunta al webservice crear_pagador por POST' do
      expect(op.webservice).to eq(CobroDigital::Pagador::CREAR_PAGADOR_WS)
      expect(op.http_method).to eq(CobroDigital::Https::POST)
    end

    it 'arma el render con el pagador' do
      expect(op.render).to eq(pagador: { 'Nombre' => 'Juan' })
    end

    it 'incluye metodo_webservice en el request' do
      expect(op.request).to include(metodo_webservice: CobroDigital::Pagador::CREAR_PAGADOR_WS)
    end
  end

  describe '.verificar' do
    it 'consulta por GET' do
      op = described_class.verificar('id', 1234)
      expect(op.http_method).to eq(CobroDigital::Https::GET)
      expect(op.render).to eq(identificador: 'id', buscar: 1234)
    end
  end
end

describe CobroDigital::Boleta do
  describe '.generar' do
    it 'formatea las fechas de vencimiento a %Y%m%d' do
      op = described_class.generar('id', 1, [Date.new(2024, 1, 5), Date.new(2024, 1, 15)], [100, 110], 'Concepto')
      expect(op.render[:fechas_vencimiento]).to eq(%w[20240105 20240115])
      expect(op.render[:importes]).to eq([100, 110])
      expect(op.webservice).to eq(CobroDigital::Boleta::GENERAR_BOLETA_WS)
    end
  end
end

describe CobroDigital::Transaccion do
  describe '.consultar' do
    it 'formatea el rango de fechas y conserva los filtros' do
      filtro = { CobroDigital::Transaccion::FILTRO_TIPO => CobroDigital::Transaccion::FILTRO_TIPO_INGRESO }
      op = described_class.consultar(Date.new(2024, 1, 1), Date.new(2024, 1, 31), filtro)
      expect(op.render).to eq(desde: '20240101', hasta: '20240131', filtros: filtro)
      expect(op.http_method).to eq(CobroDigital::Https::GET)
    end
  end
end

describe CobroDigital::Operador do
  describe '#parse_response' do
    # Doble mínimo del sobre que devuelve el WS (output = JSON string).
    FakeResponse = Struct.new(:body)

    def operador_con_output(output_hash)
      op = described_class.new
      op.response = FakeResponse.new(
        webservice_cobrodigital_response: { output: output_hash.to_json }
      )
      op
    end

    it 'decodifica resultado/log/datos de una respuesta exitosa' do
      op = operador_con_output(
        'ejecucion_correcta' => '1',
        'log' => ['ok'],
        'datos' => ['Pago aprobado'] # string no-JSON: ejercita el rescue (queda tal cual)
      )
      parsed = op.parse_response
      expect(parsed[:resultado]).to be(true)
      expect(parsed[:log]).to eq(['ok'])
      expect(parsed[:datos]).to eq(['Pago aprobado'])
    end

    it 'marca resultado=false cuando ejecucion_correcta != 1' do
      op = operador_con_output('ejecucion_correcta' => '0', 'log' => ['error de negocio'])
      parsed = op.parse_response
      expect(parsed[:resultado]).to be(false)
      expect(parsed[:log]).to eq(['error de negocio'])
      expect(parsed[:datos]).to eq([])
    end
  end
end
