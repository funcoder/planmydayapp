require "test_helper"

class PricingControllerTest < ActionDispatch::IntegrationTest
  test "shows free plan as current for free users" do
    sign_in(users(:two))

    get pricing_url

    assert_response :success
    assert_select "a", text: "Back to Dashboard"
    assert_select "h2", text: "Free"
    assert_select "span", text: "Up to 5 active tasks per day"
    assert_includes @response.body, "Current Plan"
  end

  test "shows free signup call to action for guests" do
    get pricing_url

    assert_response :success
    assert_select "a", text: "Back to Home"
    assert_select "a", text: "Sign In"
    assert_select "a", text: "Create Free Account"
  end
end
