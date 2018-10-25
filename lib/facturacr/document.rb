require 'active_model'

module FE  
  class Document
    include ActiveModel::Validations
    
    CONDITIONS = {
      "01"=>"Contado", 
      "02"=>"Crédito", 
      "03"=>"Consignación", 
      "04"=>"Apartado", 
      "05"=>"Arrendamiento con Opción de Compra", 
      "06"=>"Arrendamiento en Función Financiera",
      "99"=>"Otros"
    }
    PAYMENT_TYPES = {
      "01"=>"Efectivo",
      "02"=>"Tarjeta",
      "03"=>"Cheque",
      "04"=>"Transferencia",
      "05"=>"Recaudado por Terceros",
      "99"=>"Otros"
    }
    DOCUMENT_TYPES = {
      "01"=> "Factura Electronica",
      "02"=> "Nota de débito",
      "03"=> "Nota de crédito",
      "04"=> "Tiquete Electrónico",
      "05"=> "Nota de despacho",
      "06"=> "Contrato",
      "07"=> "Procedimiento",
      "08"=> "Comprobante Emitido en Contingencia",
      "99"=> "Otros"
      
    }
    DOCUMENT_SITUATION = {
      "1" => "Normal",
      "2" => "Contingencia",
      "3" => "Sin Internet"
    }
  
    attr_accessor :serial, :date, :issuer, :receiver, :condition, :credit_term, 
                  :payment_type, :service_type, :reference_information, 
                  :regulation, :number, :document_type, :security_code, 
                  :items, :references, :namespaces, :summary, :document_situation, :headquarters, :terminal
    
    validates :date, presence: true
    validates :number, presence: true
    validates :issuer, presence: true
    validates :condition, presence: true, inclusion: CONDITIONS.keys
    validates :credit_term, presence: true, if: ->{condition.eql?("02")}
    validates :payment_type, presence: true, inclusion: PAYMENT_TYPES.keys
    validates :document_type, presence: true, inclusion: DOCUMENT_TYPES.keys
    validates :document_situation, presence: true, inclusion: DOCUMENT_SITUATION.keys
    validates :summary, presence: true
    validates :regulation, presence: true
    validates :security_code, presence: true, length: {is: 8}
    validates :references, presence: true, if: -> {document_type.eql?("02") || document_type.eql?("03")}
    
    
    def initialize
      raise "Subclasses must implement this method"
    end
    
    def document_name
      raise "Subclasses must implement this method"
    end
    
    def key
      raise "Documento inválido: #{errors.messages}" unless valid?  
      country = "506"
      day = "%02d" % @date.day
      month = "%02d" % @date.month
      year = "%02d" % (@date.year - 2000)
      id_number = @issuer.identification_document.id_number

      type = @document_situation
      security_code = @security_code

      result = "#{country}#{day}#{month}#{year}#{id_number}#{sequence}#{type}#{security_code}"
      raise "The key is invalid: #{result}" unless result.length.eql?(50)
      
      result
    end
    
    def headquarters
      @headquarters ||= "001"
    end
  
    def terminal
      @terminal ||= "00001"
    end 
    
    def sequence
      cons = ("%010d" % @number)
      "#{headquarters}#{terminal}#{@document_type}#{cons}"
    end
  
    def build_xml
      raise "Documento inválido: #{errors.messages}" unless valid?
      builder  = Nokogiri::XML::Builder.new
      
      builder.send(document_tag, @namespaces) do |xml|
        xml.Clave key
        xml.NumeroConsecutivo sequence
        xml.FechaEmision @date.xmlschema
        issuer.build_xml(xml)
        receiver.build_xml(xml) if receiver.present?
        xml.CondicionVenta @condition
        xml.PlazoCredito @credit_term if @credit_term.present? && @condition.eql?("02")
        xml.MedioPago @payment_type
        xml.DetalleServicio do |x|
          @items.each do |item|
            item.build_xml(x)
          end
        end
        
        summary.build_xml(xml)
        
        if references.present?
          references.each do |r|
            r.build_xml(xml)
          end
        end
        
        regulation.build_xml(xml)
      end
      
      builder
    end
    
    def generate
      build_xml.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML)
    end
    
    def api_payload
      payload = {}
      payload[:clave] = key
      payload[:fecha] = @date.xmlschema
      payload[:emisor] = {
        tipoIdentificacion: @issuer.identification_document.document_type,
        numeroIdentificacion: @issuer.identification_document.id_number
      }
      if @receiver&.identification_document.present?
        payload[:receptor] = {
          tipoIdentificacion: @receiver.identification_document.document_type,
          numeroIdentificacion: @receiver.identification_document.id_number
        }
      end
      
      payload
    end
    
  end
  
  
end

require 'facturacr/document/code'
require 'facturacr/document/exoneration'
require 'facturacr/document/fax'
require 'facturacr/document/identification_document'
require 'facturacr/document/issuer'
require 'facturacr/document/item'
require 'facturacr/document/location'
require 'facturacr/document/phone_type'
require 'facturacr/document/phone'
require 'facturacr/document/receiver'
require 'facturacr/document/reference'
require 'facturacr/document/regulation'
require 'facturacr/document/summary'
require 'facturacr/document/tax'
