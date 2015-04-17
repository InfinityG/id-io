require 'rest_client'

class RestUtil

  def execute_get(api_uri, auth_header)

    client = RestClient::Resource.new api_uri
    response = client.get(:content_type => 'application/json;charset=UTF-8', :verify_ssl => false, :Authorization => auth_header)

    build_response(response)
  end

  def execute_post(api_uri, auth_header, json = '')

    # client = get_client api_uri, true
    client = RestClient::Resource.new api_uri

    response = begin
      client.post(json, :content_type => 'application/json;charset=UTF-8', :verify_ssl => false,  :Authorization => auth_header)
    rescue => e
        return build_response e.response
    end

    build_response(response)
  end

  def build_response(response)
    rest_response = RestResponse.new
    rest_response.response_code = response.code
    rest_response.response_body = response.body

    rest_response
  end

  def get_client(uri, auth_token)
    if auth_token != nil
      RestClient::Resource.new(uri, :user => GATEWAYD_ADMIN_USER, :password => GATEWAYD_KEY, :timeout => 60)
    else
      RestClient::Resource.new(uri, :timeout => 60)
    end
  end

end

class RestResponse
  attr_accessor :response_code
  attr_accessor :response_body
end