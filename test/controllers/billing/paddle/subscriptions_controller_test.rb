require "test_helper"

class Billing::Paddle::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @billing_paddle_subscription = billing_paddle_subscriptions(:one)
  end

  test "should get index" do
    get billing_paddle_subscriptions_url
    assert_response :success
  end

  test "should get new" do
    get new_billing_paddle_subscription_url
    assert_response :success
  end

  test "should create billing_paddle_subscription" do
    assert_difference("Billing::Paddle::Subscription.count") do
      post billing_paddle_subscriptions_url, params: { billing_paddle_subscription: { paddle_subscription_id: @billing_paddle_subscription.paddle_subscription_id, team_id: @billing_paddle_subscription.team_id } }
    end

    assert_redirected_to billing_paddle_subscription_url(Billing::Paddle::Subscription.last)
  end

  test "should show billing_paddle_subscription" do
    get billing_paddle_subscription_url(@billing_paddle_subscription)
    assert_response :success
  end

  test "should get edit" do
    get edit_billing_paddle_subscription_url(@billing_paddle_subscription)
    assert_response :success
  end

  test "should update billing_paddle_subscription" do
    patch billing_paddle_subscription_url(@billing_paddle_subscription), params: { billing_paddle_subscription: { paddle_subscription_id: @billing_paddle_subscription.paddle_subscription_id, team_id: @billing_paddle_subscription.team_id } }
    assert_redirected_to billing_paddle_subscription_url(@billing_paddle_subscription)
  end

  test "should destroy billing_paddle_subscription" do
    assert_difference("Billing::Paddle::Subscription.count", -1) do
      delete billing_paddle_subscription_url(@billing_paddle_subscription)
    end

    assert_redirected_to billing_paddle_subscriptions_url
  end
end
