require "test_helper"

class Webhooks::Incoming::PaddleWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get webhooks_incoming_paddle_webhooks_create_url
    assert_response :success
  end
end
