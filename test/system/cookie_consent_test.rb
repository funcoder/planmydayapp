require "application_system_test_case"

class CookieConsentTest < ApplicationSystemTestCase
  test "shows cookie consent banner on first visit" do
    visit root_url
    
    # Banner should be visible on first visit
    assert_selector "[data-cookie-consent-target='banner']", visible: true
    assert_text "Cookie Notice"
    assert_text "We use cookies to improve your experience"
    
    # Should have Accept and Decline buttons
    assert_button "Accept All"
    assert_button "Decline"
  end
  
  test "accepting cookies hides the banner" do
    visit root_url
    
    # Click Accept All
    click_button "Accept All"
    
    # Banner should be hidden
    assert_no_selector "[data-cookie-consent-target='banner']", visible: true
    
    # Refresh the page - banner should stay hidden
    visit root_url
    assert_no_selector "[data-cookie-consent-target='banner']", visible: true
  end
  
  test "declining cookies hides the banner" do
    visit root_url
    
    # Click Decline
    click_button "Decline"
    
    # Banner should be hidden
    assert_no_selector "[data-cookie-consent-target='banner']", visible: true
    
    # Refresh the page - banner should stay hidden
    visit root_url
    assert_no_selector "[data-cookie-consent-target='banner']", visible: true
  end
end