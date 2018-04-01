module FE
  class Document
    class Exoneration
      include ActiveModel::Validations
      
      
      DOCUMENT_TYPES = {
        "01" => "Compras Autorizadas",
        "02" => "Ventas exentas a diplomáticos",
        "03" => "Orden de Compra (Instituciones Públicas y otros organismos)",
        "04" => "Exenciones Dirección General de Hacienda",
        "05" => "Zonas Francas",
        "99" => "Otros"
      }
      attr_accessor :document_type, :document_number, :institution, :date, :total_tax, :percentage
      
      validates :document_type, presence: true, inclusion: DOCUMENT_TYPES.keys
      validates :document_number, presence: true
      validates :institution, presence: true
      validates :date, presence: true
      validates :total_tax,presence: true
      validates :percentage, presence: true
      
      def initialize(args={})
        @document_type = args[:document_type]
        @document_number = args[:document_number]
        @institution = args[:institution]
        @date = args[:date].xmlschema
        @total_tax = args[:total_tax]
        @percentage = args[:percentage]
      end
      
      def build_xml(node)
        raise "Invalid Record: #{errors.messages}" unless valid?
        node = Nokogiri::XML::Builder.new if node.nil?
        
        node.Exoneracion do |xml|
          xml.TipoDocument @document_type
          xml.NumeroDocumento @document_number
          xml.NombreInstitucion @institution
          xml.FechaEmision @date
          xml.MontoImpuesto @total_tax
          xml.PorcentajeCompra @percentage
        end
      end
      
    end
  end
end