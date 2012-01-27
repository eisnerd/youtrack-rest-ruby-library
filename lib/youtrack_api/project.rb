require "rexml/xpath"
require "rexml/document"

module YouTrackAPI

  class Project

    attr_accessor :lead, :name, :id

    def initialize(connection, project_name, project_id = nil, owner = nil)
      @conn = connection
      @id = project_id
      @name = project_name
      @lead = owner
    end

    def get
      project = REXML::XPath.first(REXML::Document.new(@conn.request(:get, self.path).body), "//project")
      [:name, :id, :lead].each{|elem| instance_variable_set("@#{elem}", project.attributes[elem.to_s])}
    end

    def put

    end

    def post

    end

    private

    def path
      "#{@conn.rest_path}/admin/project/#{id}"
    end

    def find(filter,opts={})
      params = opts.merge(:filter => filter)
      @conn.request(:get, "#{@conn.rest_path}/issue/byproject/#{id}", params).body
    end
    
  end
  
end