require "uri"
require "net/http"
require "net/https"
require "cgi"

module YouTrackAPI

  class Connection

    attr_reader :url, :rest_path, :connection

    def initialize(yt_base_url)
      correct_uri = yt_base_url.gsub(/\/$/, '')
      uri = URI.parse(correct_uri)
      @url = uri.path
      @rest_path = url + "/rest"
      @connection = Net::HTTP.new(uri.host, uri.port)
      @connection.use_ssl = true if uri.scheme == 'https'
      @headers = {}
    end

    def login(login, password)
      resp = request(:post, "#{@rest_path}/user/login", {'login' => login,
                                                    'password' => password})
      @headers = {"Cookie" => resp["set-cookie"], "Cache-Control" => "no-cache"}
    end

    def set_logger(logger)
      @logger = case
        when logger.nil?
          nil
        when logger.respond_to?(:puts)
          lambda {|method, path, headers|
            logger.puts "#{method.to_s.upcase} #{path}"
          }
        when logger.respond_to?(:call)
          logger
        else
          raise "Unknown object type, #{logger.class}, for logger. Expecting either an IO or Proc object"
      end
    end
    
    def request(method_name, url, params = {}, body = nil)
      path = url
      unless params.empty?
        path = "#{url}?#{url_encode(params)}"
      end
      
      @logger.call(method_name, path, @headers) if @logger
      
      req = nil
      case method_name
        when :get
          req = Net::HTTP::Get.new(path, @headers)
        when :post
          req = Net::HTTP::Post.new(path, @headers)
        when :put
          req = Net::HTTP::Put.new(path, @headers)
        else
          raise ArgumentError.new("#{method_name.inspect} not supported")
      end
      @connection.start do |http|
        resp = http.request(req)
        resp.value
        resp
      end
    end

    def url_encode(params)
      params.map{|key, value|"#{URI.escape(key.to_s)}=#{URI.escape(value.to_s)}"}.join("&")
    end
    
    def project(id)
      YouTrackAPI::Project.new(self, nil, id)
    end
    
    def projects()
      REXML::XPath.each(REXML::Document.new(request(:get, "#{@rest_path}/admin/project").body), "//project").
        map {|p|
          project(p.attributes.get_attribute('id').value())
        }
    end
    
    def bundle(kind, name)
      YouTrackAPI::Bundle.new(self, kind, name)
    end
    
    def states()
      REXML::XPath.each(REXML::Document.new(request(:get, "#{@rest_path}/admin/customfield/stateBundle").body), "//stateBundle").
        map {|p|
          bundle("stateBundle", p.attributes.get_attribute('name').value())
        }
    end

  end
  
end
