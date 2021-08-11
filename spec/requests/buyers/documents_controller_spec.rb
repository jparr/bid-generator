require 'rails_helper'

RSpec.describe Buyers::DocumentsController, type: :request do
  describe 'GET /index' do
    def make_request
      get buyers_documents_path
    end

    context 'when a buyer is not signed in' do
      it 'redirects' do
        make_request
        expect(response).to redirect_to(new_buyer_session_path)
      end
    end

    context 'when a buyer is signed in' do
      let(:buyer) { create(:buyer, :confirmed) }

      before do
        sign_in buyer, scope: :buyer
      end

      it 'is successful' do
        make_request
        expect(response).to be_successful
      end
    end
  end
end
