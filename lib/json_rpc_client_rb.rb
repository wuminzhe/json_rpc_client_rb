# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

require_relative "json_rpc_client_rb/version"
require_relative "json_rpc_client_rb/eth"

module JsonRpcClientRb
  class HttpError < StandardError; end
  class JSONRpcError < StandardError; end

  def json_rpc_request(url, method, params)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = { jsonrpc: "2.0", method: method, params: params, id: 1 }.to_json

    # https://docs.ruby-lang.org/en/master/Net/HTTPResponse.html
    response = http.request(request)
    raise HttpError, response unless response.is_a?(Net::HTTPOK)

    body = JSON.parse(response.body)
    raise JSONRpcError, body["error"] if body["error"]

    body["result"]
  end
end
