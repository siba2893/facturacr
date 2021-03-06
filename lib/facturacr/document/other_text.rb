module FE
  class Document
    class OtherText
      attr_accessor :xml_attributes, :content
      


      def initialize(args={})
        @xml_attributes = args[:xml_attributes] || {}
        @content = args[:content]
      end
      
      def build_xml(node)
        raise "xml_attributes is not a Hash" unless @xml_attributes.is_a?(Hash)
        
        node = Nokogiri::XML::Builder.new if node.nil?
        node.OtroTexto(@xml_attributes) do |xml|
          xml.text(@content)
        end
      end
      
      
      
      
    end
  end
end