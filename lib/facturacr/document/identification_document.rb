require "facturacr/document"
require 'active_model'
require 'nokogiri'

module FE
  class Document
    
      
      class IdentificationDocument
        include ActiveModel::Validations
        
        TYPES = {'01'=>'Cédula Fisica', '02'=>'Cédula Jurídica', '03'=>'DIMEX', '04'=>'NITE'}
        
        attr_accessor :document_type, :id_number, :raw_id_number
        
        validates :document_type, presence: true, inclusion: TYPES.keys
        validates :id_number, presence: true, length: {is: 12}
        
        def initialize(args={})
          
          @document_type = args[:type]
          @raw_id_number = args[:number]
          @id_number = "%012d" % args[:number]
          
        end
        
        def build_xml(node)
          raise "Invalid Record: #{errors.messages}" unless valid?
          node = Nokogiri::XML::Builder.new if node.nil?         
          node.Identificacion do |x|
            x.Tipo document_type
            x.Numero raw_id_number
          end
        end      
        def to_xml(builder)
          build_xml(builder).to_xml
        end
      end
    
  end
end