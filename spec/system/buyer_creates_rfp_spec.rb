require 'rails_helper'

RSpec.describe 'Creates an RFP', type: :system do
  let!(:buyer) { create(:buyer) }

  it 'allows the buyer to create their district profile', :js do
    login_as buyer, scope: :buyer

    visit buyers_root_path

    click_on 'District Profile'
    expect(page).to have_content('District Profile')

    fill_in 'District Name', with: 'The District'
    click_on 'Save and exit'

    expect(page.find('main')).to have_content(/success/i)
  end

  #code below only for custom cop manual testing
  context "test 1" do
    describe "test too" do
    end
  end

  describe "test 2" do
    context "test too too" do
    end
  end
end
