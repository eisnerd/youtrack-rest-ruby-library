require 'uri'
require "rexml/xpath"
require "rexml/document"

module YouTrackAPI

  class Bundle

    attr_reader :kind, :name, :items
    
    def initialize(conn, kind, name)
      @conn = conn
      @kind = kind
      @name = name
      @items = []
    end

    def get
      @items = REXML::XPath.each(REXML::Document.new(@conn.request(:get, path).body), "//state").
        map {|s|
          s.text
        }
      self
    end
    
    private
    
    def path
      "#{@conn.rest_path}/admin/customfield/#{kind}/#{URI.escape(name)}"
    end


  end

end