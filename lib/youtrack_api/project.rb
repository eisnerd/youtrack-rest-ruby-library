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
      project = REXML::XPath.first(REXML::Document.new(@conn.request(:get, path).body), "//project")
      [:name, :id, :lead].each{|elem| instance_variable_set("@#{elem}", project.attributes[elem.to_s])}
      self
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
      
      newIssue = Issue.new(@conn, issueId)
      opts.each do |name,value|
        newIssue.send("#{name}=".to_sym,value)
      end
      
      newIssue
    end
    
    def find(filter,opts={})
      params = opts.merge(:filter => filter)
      @conn.request(:get, "#{@conn.rest_path}/issue/byproject/#{id}", params).body
    end
    
    def issue(id)
      YouTrackAPI::Issue.new(@conn, id, @id)
    end
    
    def states
     @conn.bundle("stateBundle", 
      REXML::XPath.first(REXML::Document.new(@conn.request(:get, "#{path}/customfield/State").body), "//param").
        attributes.get_attribute("value").value
     )
    end
    
    def versions
     @conn.bundle("versionBundle", 
      REXML::XPath.first(REXML::Document.new(@conn.request(:get, "#{path}/customfield/Fix%20versions").body), "//param").
        attributes.get_attribute("value").value
     )
    end

    def builds
     @conn.bundle("buildBundle",
      REXML::XPath.first(REXML::Document.new(@conn.request(:get, "#{path}/customfield/Fixed%20in%20build").body), "//param").
        attributes.get_attribute("value").value
     )
    end

    private
    
    def path
      "#{@conn.rest_path}/admin/project/#{id}"
    end

  end
  
end
