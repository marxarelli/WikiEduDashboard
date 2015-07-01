require 'rails_helper'

def stub_oauth_edit
  # Stub out the posting of content to Wikipedia using the same protocol as
  # wiki_edits_spec.rb
  # rubocop:disable Metrics/LineLength
  fake_tokens = "{\"query\":{\"tokens\":{\"csrftoken\":\"myfaketoken+\\\\\"}}}"
  # rubocop:enable Metrics/LineLength
  stub_request(:get, /.*wikipedia.*/)
    .to_return(status: 200, body: fake_tokens, headers: {})
  stub_request(:post, /.*wikipedia.*/)
    .to_return(status: 200, body: 'success', headers: {})
end

describe 'Admin users', type: :feature, js: true do
  before do
    include Devise::TestHelpers, type: :feature
    Capybara.current_driver = :selenium
  end

  before :each do
    create(:cohort,
           id: 1,
           title: 'Fall 2015')
    create(:course,
           id: 10001,
           title: 'Course',
           school: 'University',
           term: 'Term',
           slug: 'University/Course_(Term)',
           submitted: 1,
           listed: true,
           passcode: 'passcode',
           start: '2015-01-01'.to_date,
           end: '2020-01-01'.to_date)
    create(:user,
           id: 100,
           wiki_id: 'Professor Sage')
    create(:courses_user,
           user_id: 100,
           course_id: 10001,
           role: 1)
    user = create(:admin,
                  id: 200,
                  wiki_token: 'foo',
                  wiki_secret: 'bar')
    login_as(user, scope: :user)
  end

  describe 'adding a course to cohort' do
    it 'should make the course live' do
      stub_oauth_edit

      visit "/courses/#{Course.first.slug}"
      sleep 1

      # Edit details and add cohort
      page.all('.button.dark')[1].click
      page.all('.button.border.plus')[4].click
      first('input').set('Fall 2015')
      find('button', text: 'List').click
      page.driver.browser.switch_to.alert.accept
      page.driver.browser.switch_to.alert.accept
      sleep 1

      expect(page).to have_content 'Your course has been published'
    end
  end

  after do
    logout
    Capybara.use_default_driver
  end
end