require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]

require 'minitest/autorun'
require 'webmock/minitest'
require 'faraday'

require_relative '../lib/gistkv'

def gist_payload(content)
  {
    "files" => {
      "#{GistKV::KV_FILE}" => {
        "content" => content.to_json
      }
    }
  }.to_json
end

class GistKVClientTest < Minitest::Test
  RESPONSE_HEADERS = {
    "Content-Type" => "application/json; charset=utf-8"
  }

  def setup
    @gist_id = "abc123"
    @client = GistKV::Client.new(@gist_id, "xyz987")
  end

  def test_read_only_client
    client = GistKV::Client.new("abc123")

    assert_equal client.read_only, true
  end

  def test_create_database
    stub_request(:post, GistKV::GIST_URL)
      .to_return(
        headers: RESPONSE_HEADERS,
        body: { "id" => "abc123" }.to_json
      )
    res = GistKV::Client.create_database("")

    assert_equal res, "abc123"
  end

  def test_keys
    stub_request(:get, "#{GistKV::GIST_URL}/#{@gist_id}")
      .to_return(
        headers: RESPONSE_HEADERS,
        body: gist_payload(a: 1, b: 2)
      )

    assert_equal @client.keys, ["a", "b"]
  end

  def test_get
    stub_request(:get, "#{GistKV::GIST_URL}/#{@gist_id}")
      .to_return(
        headers: RESPONSE_HEADERS,
        body: gist_payload(a: 1, b:2)
      )

    assert_equal @client.get("a"), 1
  end

  def test_get_alias
    assert_equal @client.method(:get), @client.method(:[])
  end

  def test_set
    stub_request(:get, "#{GistKV::GIST_URL}/#{@gist_id}")
      .to_return(
        headers: RESPONSE_HEADERS,
        body: gist_payload(a:1, b:2)
      )
    stub_request(:patch, "#{GistKV::GIST_URL}/#{@gist_id}")
    res = @client.set("c", 3)

    assert_equal res, 3
  end

  def test_set_alias
    assert_equal @client.method(:set), @client.method(:[]=)
  end

  def test_update
    stub_request(:get, "#{GistKV::GIST_URL}/#{@gist_id}")
      .to_return(
        headers: RESPONSE_HEADERS,
        body: gist_payload(a:1, b:2)
      )
    stub_request(:patch, "#{GistKV::GIST_URL}/#{@gist_id}")
    res = @client.update(c: 3, d: 4)

    assert_equal res, { c: 3, d: 4 }
  end

  def test_raises_exception_on_http_errors
    stub_request(:get, "#{GistKV::GIST_URL}/#{@gist_id}")
      .to_return(status: 500)
    assert_raises (Faraday::ServerError) { @client.get("abc") }

    stub_request(:get, "#{GistKV::GIST_URL}/#{@gist_id}")
      .to_return(status: 400)
    assert_raises (Faraday::BadRequestError) { @client.get("abc") }

    stub_request(:get, "#{GistKV::GIST_URL}/#{@gist_id}")
      .to_return(status: 404)
    assert_raises (Faraday::ResourceNotFound) { @client.get("abc") }
  end
end
