require "rexml/xpath"
require "rexml/document"

require_relative 'issue'

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

    def create(opts)
      summary = opts.delete(:summary) or raise ":summary not given in create() options"
      description = opts.delete(:description) or raise ":description not given in create() options"
      
      params = {
        :project => CGI.escape(self.name),
        :summary => CGI.escape(summary),
        :description => CGI.escape(description),
      }
      
      issuePath = "#{@conn.rest_path}/issue"
      ret = @conn.request(:put,issuePath,params)
      
      # New ID of the issue is located in the 'location' field in the header
      issueId = ret.header['location'].sub(/^.*#{Regexp.escape issuePath}\/?/i,'')
      
      Issue.new(@conn, issueId)
    end
    
    def find(filter,opts={})
      params = opts.merge(:filter => filter)
      @conn.request(:get, "#{@conn.rest_path}/issue/byproject/#{id}", params).body
    end
    
    private

    def path
      "#{@conn.rest_path}/admin/project/#{id}"
    end

  end
  
end