require 'rails_helper'

RSpec.describe 'Creates an RFP', type: :system do
  let!(:buyer) { create(:buyer, :confirmed) }

  before do
    create(:score_category, name: 'Item Prices', description: 'price description', position: 1)
    create(:score_category, name: 'Cat 2', description: 'cat 2 description', position: 2)
    create(:score_category, name: 'Cat 3', description: 'cat 3 description', position: 3)
    create(:score_category, name: 'Cat 4', description: 'cat 4 description', position: 4)
  end

  it 'allows the buyer to create their district profile', :js do
    login_as buyer, scope: :buyer

    visit buyers_root_path
    expect(page).to have_content('must complete your District Profile')

    click_on 'District Profile'
    expect(page).to have_content('District Profile')

    fill_in 'District Name', with: 'The District'
    fill_in 'City', with: 'DistrictCity'
    fill_in 'County', with: 'DistrictCounty'
    click_on 'Save and exit'

    expect(page).to have_selector('.form-errors__error', count: 4)
    click_on 'Edit contact information'

    expect(page).to have_content('Contact Information')
    fill_in 'Full name', with: 'FS Director'
    fill_in 'Department name', with: 'School Meals R Us'
    fill_in 'Title', with: 'FS Director'
    fill_in 'Phone number', with: '5551234567'
    fill_in 'Mailing address', with: '123 Edu Lane'
    fill_in 'City', with: 'Cityname'
    fill_in 'State', with: 'California'
    fill_in 'ZIP code', with: '123456'

    click_on 'Next'

    select '35%', from: 'district_profile_local_percentage'
    choose 'Do not verify pricing'
    choose 'Do not add a piggyback clause'
    fill_in 'Per-incident liability limit', with: '1_000_000'
    fill_in 'Aggregate liability limit', with: '2_000_000'
    fill_in 'Automobile liability limit', with: '500_000'
    click_on 'Next'

    click_on '+ New Location'
    fill_in 'Location name', with: 'Deliver here'
    fill_in 'Street address', with: '123 Main'
    fill_in 'City', with: 'OKGO'
    fill_in 'State', with: 'California'
    fill_in 'ZIP code', with: '12345'

    click_on 'Save'
    expect(page).to have_content(/Deliver here/i)
    expect(page).to have_content(/123 main, okgo, california 12345/i)

    click_on 'Review Profile'
    expect(page).not_to have_selector('.form-errors__error')

    expect(page).to have_content(/the district/i)
    expect(page).to have_content(/fs director/i)
    expect(page).to have_content(/school meals r us/i)
    expect(page).to have_content(/fs director/i)
    expect(page).to have_content(/5551234567/i)
    expect(page).to have_content(/123 edu lane/i)
    expect(page).to have_content(/cityname/i)
    expect(page).to have_content(/ca/i)
    expect(page).to have_content(/123456/i)

    expect(page).to have_content(/35%/i)
    expect(page).to have_content('$1,000,000')
    expect(page).to have_content('$2,000,000')
    expect(page).to have_content('$500,000')

    click_on('Documents')

    click_on('New RFP')
    select '2021 - 2022', from: 'rfp_start_year'
    click_on('Save and exit')
    expect(page).to have_selector('.form-errors__error', count: 2)
    click_on 'Edit scores'

    expect(page).to have_content(/score/i)

    fill_in 'Item Prices', with: '40'
    expect(page.find('#rfp_total_score')).to have_content('40')
    fill_in 'Cat 2', with: '20'
    expect(page.find('#rfp_total_score')).to have_content('60')
    fill_in 'Cat 3', with: '20'
    expect(page.find('#rfp_total_score')).to have_content('80')
    fill_in 'Cat 4', with: '30'
    expect(page.find('#rfp_total_score')).to have_content('110')
    expect(page.find('.form-errors__error')).to have_content('Total must equal 100')

    fill_in 'Cat 4', with: '20'
    expect(page).not_to have_selector('.form-errors__error')
    expect(page.find('#rfp_total_score')).to have_content('100')

    click_on 'Next'
    expect(page).to have_content(/delivery schedule/i)
    click_on '+ New delivery'
    select 'Deliver here', from: 'Location'
    check 'Monday'
    check 'Wednesday'
    select '2', from: 'Deliveries per week'
    select '6:00 am', from: 'Start time'
    select '8:00 am', from: 'End time'
    click_on 'Save'

    expect(page).to have_content('Deliver here')
    expect(page).to have_content('2x per week')
    expect(page).to have_content('Monday, Wednesday')
    expect(page).to have_content('6:00 am - 8:00 am')

    click_on 'Next'
    page.attach_file('rfp_item_list', 'spec/fixtures/files/item_list.txt')

    click_on 'Upload Item List'
    expect(page).to have_content('item_list.txt')
    click_on 'Documents'

    expect(page.find('main')).to have_content('Produce (2021 - 2022)')
    expect(page.find('main')).to have_content('Complete')

    click_on 'edit'
    select '2022 - 2023', from: 'rfp_start_year'
    click_on 'Save and exit'
    expect(page.find('main')).to have_content('2022 - 2023')

    click_on 'Create Draft RFP'
    expect(page.find('main')).to have_link(Rfp.last.draft.filename)

    expect(page).to have_field('rfp[reviewed]')
    page.attach_file('rfp[reviewed]', 'spec/fixtures/files/reviewed_rfp.txt')

    click_on 'Upload reviewed RFP'
    # expect(page).to have_content('reviewed_rfp.txt', wait: 30)

    expect(page).to have_field('rfp[final]')
    page.attach_file('rfp[final]', 'spec/fixtures/files/final_rfp.txt')

    click_on 'Upload final RFP'
    # expect(page).to have_content('final_rfp.txt', wait: 30)
    click_on 'Documents'
    expect(page).to have_content('Final')
  end
end
