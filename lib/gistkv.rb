require 'faraday'
require 'faraday/net_http'
require 'json'

module GistKV
  GIST_URL = "https://api.github.com/gists"
  KV_FILE = "__gistkv.json"
  GIST_BASE = {
    "description" => "GistKV database",
    "public" => false,
    "files" => { "#{KV_FILE}" => { "content" => "{}" } }
  }

  class Client
    attr_reader :read_only
  
    def initialize(gist_id, auth = nil)
      @gist_id = gist_id
      @auth = auth
      @read_only = @auth.nil?
      headers = GistKV::Client.headers(@auth)
      @conn = GistKV::Client.conn(headers)
    end
  
    def self.create_database(auth)
      return if auth.nil?
      headers = GistKV::Client.headers(auth)
      res = GistKV::Client.conn(headers).post(nil, GIST_BASE)
      res.body["id"] if res.body
    end
  
    def keys
      get_gist.keys
    end
  
    def get(key)
      get_gist[key.to_s]
    end
  
    alias_method :[], :get
  
    def set(key, value)
      return if @auth.nil?
      gist = get_gist
      gist[key.to_s] = value
      patch_gist(gist)
      value
    end
  
    alias_method :[]=, :set
  
    def update(changes)
      gist = get_gist
      changes.each {|key,val| gist[key.to_s] = val }
      patch_gist(gist)
      changes
    end
  
    private
  
    def get_gist
      res = @conn.get("#{GIST_URL}/#{@gist_id}")
      content = res.body.dig("files", KV_FILE, "content")
      JSON.parse(content) if content
    end
  
    def patch_gist(content)
      payload = { "files" => { "#{KV_FILE}" => { "content" => content.to_json } } }
      @conn.patch("#{GIST_URL}/#{@gist_id}", payload)
      nil
    end
  
    def self.headers(auth = nil)
      headers = { "Accept" => "application/vnd.github+json" }
      headers["Authorization"] = "token #{auth}" if auth
      headers
    end

    def self.conn(headers)
      Faraday.new(url: GIST_URL, headers: headers) do |f|
        f.request :json
        f.response :json
        f.response :raise_error
      end
    end
  end
end
