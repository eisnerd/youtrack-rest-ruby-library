require "rexml/xpath"
require "rexml/document"

module YouTrackAPI

  class Issue

    attr_reader :project_id, :issue_id
    attr_reader :attachments, :voters, :links

    def initialize(conn, issue_id, project_id = nil)
      @conn = conn
      if project_id.nil?
        @issue_id = issue_id[/(\w+)-(\d+)/, 2]
        @project_id = issue_id[/(\w+)-(\d+)/, 1]
      else
        @issue_id = issue_id
        @project_id = project_id
      end
      @comments_loaded = false
      @issue_params = {}
      @comments = {}
      @attachments = {}
      @links = {}
    end

    def get_param_names
      @issue_params.keys
    end

    def get_param(param_name)
      @issue_params[param_name]
    end

    def set_param(param_name, param_value)
      @issue_params[param_name] = param_value
    end

    def full_id
      "#{self.project_id}-#{self.issue_id}"
    end

    def url
      "#{@conn.url}/issue/#{self.full_id}"
    end

    def apply_command(command, comment = nil, group = nil, disable_notifications = nil, run_as = nil)
      @comments_loaded = false
      params = {:command => CGI.escape(command),
                :comment => comment,
                :group => group,
                :disableNotifications => disable_notifications,
                :runAs => run_as}
      @conn.request(:post, "#{path}/execute", params)
    end

    def get
      body = REXML::Document.new(@conn.request(:get, path).body)
      REXML::XPath.each(body, "//issue/field"){ |field|
        values = []
        REXML::XPath.each(body, field.xpath + "/value") { |value|
          values << value.text
        }
        create_getter_and_setter_and_set_value(field.attributes["name"], values)
      }
      self
    end

    class Hashit
      def initialize(hash)
        hash.each do |k,v|
          self.instance_variable_set("@#{k}", v)
          self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
          self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
        end
      end

      def save
        hash_to_return = {}
        self.instance_variables.each do |var|
          hash_to_return[var.gsub("@","")] = self.instance_variable_get(var)
        end
        return hash_to_return
      end
    end

    def comments
      if not @comments_loaded
        @comments_loaded = true
        @comments = REXML::XPath.each(REXML::Document.new(@conn.request(:get, "#{path}/comment").body), "//comment").
          map {|comment|
            Hashit.new(
              comment.
                attributes.map{|a|a}.
                push(["replies", REXML::XPath.each(comment, "//replies//*").map {|a|a}])
            )
          }
      else
        @comments
      end
    end
    
    def assign_to(person)
      self.assignee = person
    end
    
    def assign_to_me
      assign_to 'me'
    end

    def method_missing(m, *args)
      if (m[-1, 1] == "=") and (args.length > 0)
        name = m[0...-1]
        vals = args
        update_remote_param(name, *vals)
        create_getter_and_setter_and_set_value(name,*vals)
      elsif m.to_s == "state"
        ""
      else
        super
      end
    end

    private

    def metaclass
      class << self;
        self
      end
    end

    def create_getter_and_setter_and_set_value(param_name, params = {})
      param_name = param_name.downcase
      metaclass.send(:define_method, param_name) do
        self.get_param(param_name)
      end
      metaclass.send(:define_method, param_name + "=") do |values|
        update_remote_param(param_name,values)
        self.set_param(param_name, values)
      end
      self.set_param(param_name, params)
    end

    def update_remote_param(param,values)
      cmd = case values
        when Array
          values.map {|val| "add #{param} #{val}"}.join(' ')
        else
          "#{param} #{values}"
      end
          
      apply_command(cmd)
    end

    def path
      "#{@conn.rest_path}/issue/#{self.full_id}"
    end

    def self.find(conn, filter, opts={})
      params = opts.merge(:filter => CGI.escape(filter))
      conn.request(:get, "#{conn.rest_path}/project/issues", params).body
    end


  end

end
      
