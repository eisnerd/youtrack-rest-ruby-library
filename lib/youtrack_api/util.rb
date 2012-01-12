require "rexml/xpath"
require "rexml/document"

require_relative "user"

module YouTrackAPI

  module Util
    module_function
    
    # Gets all users that match search params
    # then applies accept method to each of them
    # if accept returns true to only one of that users
    # return such user
    # If there is no such user, returns nil
    # if there are several users raises exception
    def find_user(conn, search_params, accept = lambda { |user| true} )
      current_position = 0
      go_on = true
      result = nil
      while go_on
        search_params[:start] = current_position.to_s
        go_on = false
        resp = REXML::Document.new(conn.request(:get, "#{conn.rest_path}/admin/user", search_params).body)
        REXML::XPath.each(resp, "//user") { |elem|
          go_on = true
          user = User.new(conn, elem.attributes[:login]).get
          if accept.call(user)
            if result.nil?
              result = user
            else
              raise ArgumentError
            end
          end
          current_position += 1
        }
      end
      result
    end

    def parse_command(vcs_comment)
      issue_id = vcs_comment[/( |^)#(\w+-\d+) /, 2]
      return false if issue_id.nil?

      command = vcs_comment[/( |^)#\w+-\d+ (.+)/, 2].strip
    end


  end
  
end
