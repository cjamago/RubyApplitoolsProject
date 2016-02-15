require 'selenium-webdriver'
require 'eyes_selenium'

describe 'Login' do

  before(:each) do |example|
    caps = Selenium::WebDriver::Remote::Capabilities.internet_explorer
    caps.version = '8'
    caps.platform = 'Windows XP'
    caps[:name] = example.metadata[:full_description]

    @browser = Selenium::WebDriver.for(
      :remote,
      url: "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub",
      desired_capabilities: caps)

    @eyes = Applitools::Eyes.new
    @eyes.api_key = ENV['APPLITOOLS_API_KEY']
    @driver = @eyes.open(app_name: 'the-internet', test_name: example.full_description, driver: @browser)
  end

  after(:each) do |example|
    begin
      unless example.exception.nil?
        raise "Watch a video of the test at https://saucelabs.com/tests/#{@driver.session_id}"
      end
    ensure
      @eyes.abort_if_not_closed
      @browser.quit
    end
  end

  it 'succeeded' do
    @driver.get 'http://the-internet.herokuapp.com/login'
    @eyes.check_window('Login Page')
    @driver.find_element(id: 'username').send_keys 'tomsmith'
    @driver.find_element(id: 'password').send_keys 'SuperSecretPassword!'
    @driver.find_element(css: 'button').click
    @driver.execute_script('$("#flash").remove()') # to trigger a failure in Applitools
    @eyes.check_window('Logged In')
    @eyes.close
  end

end
