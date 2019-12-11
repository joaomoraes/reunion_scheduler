# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ReunionsController, type: :controller do
  let(:response_array) { JSON response.body }
  let(:response_data) { response_array.dig('data') }
  let(:discarded_reunion) { create(:reunion, :discarded) }
  before { create_list(:reunion, 4) }

  describe "GET #index" do
    let(:response_data_size) { response_data.size }
    before do
      create_list(:reunion, 6, :published) 
      create_list(:reunion, 2)
      create_list(:reunion, 6, :discarded)
      get :index
    end

    it { expect(response).to have_http_status(:ok) }
    it "renders kept Reunions collection" do
      expect(response_data_size).to eq(12)
    end

    it "limits to 20 instances " do
      create_list(:reunion, 12, :published) 
      get :index
      expect(response_data_size).to eq(20)
    end
  end

  describe "GET #with_soft_delete" do
    let(:response_data_size) { response_data.size }
    before do
      create_list(:reunion, 6, :published) 
      create_list(:reunion, 2)
      create_list(:reunion, 6, :discarded)
      get :with_soft_delete
    end

    it { expect(response).to have_http_status(:ok) }
    it "renders all Reunions collection" do
      expect(response_data_size).to eq(18)
    end

    it "limits to 20 instances " do
      create_list(:reunion, 12, :published) 
      get :with_soft_delete
      expect(response_data_size).to eq(20)
    end
  end

  describe "GET #show" do
    context "when showing a valid reunion" do
      before { get :show, params: { id: Reunion.last } }

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.last).to have_attributes response_data.dig('attributes') }
    end

    context "when showing a discarded reunion" do
      before do
        get :show, params: { id: discarded_reunion }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response.body).to eq(' ') }
    end

    context "when showing a non existant reunion" do
      before do
        invalid_id = Reunion.maximum(:id) + 1
        get :show, params: { id: invalid_id }
      end

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe "POST #create" do
    let(:reunion_attributes) { build(:reunion, :publishable).attributes.except('created_at', 'updated_at', 'id').merge({duration: 3}) }
    let(:params) { { data: { type: 'reunion', attributes: reunion_attributes } } }
    before { post :create, params: params }

    context "with all params" do
      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.all.count).to eq(5) }
      it { expect(Reunion.last).to have_attributes reunion_attributes }
    end

    context "without start_date but with duration and end_date" do
      let(:params) { { data: { type: 'reunion', attributes: reunion_attributes.except('start_date') } } }

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.all.count).to eq(5) }
      it { expect(Reunion.last).to have_attributes reunion_attributes }
    end

    context "without end_date but with duration and start_date" do
      let(:params) { { data: { type: 'reunion', attributes: reunion_attributes.except('end_date') } } }

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.all.count).to eq(5) }
      it { expect(Reunion.last).to have_attributes reunion_attributes }
    end

  end

  describe "PATCH #update" do
    let(:update_reunion_attributes) { {
        name: 'Changed Name',
        description: "<br> Changed Description",
        start_date: (last_reunion.start_date + 10.days),
        end_date: (last_reunion.end_date + 10.days),
        location: "Changed Location",
        duration: 3
      } }

    let(:last_reunion) { Reunion.last }
    before { create_list(:reunion, 2, :publishable) }

    context "when updating a valid reunion" do
      before do
        patch :update, params: { id: last_reunion, data: { type: 'reunion', attributes: update_reunion_attributes } }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.all.count).to eq(6) }
      it { expect(Reunion.last).to have_attributes update_reunion_attributes }
    end

    context "without start_date but with duration and end_date" do
      before do
        patch :update, params: { id: last_reunion, data: { type: 'reunion', attributes: update_reunion_attributes.except(:start_date) } }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.all.count).to eq(6) }
      it { expect(Reunion.last).to have_attributes update_reunion_attributes }
    end

    context "without end_date but with duration and start_date" do
      before do
        patch :update, params: { id: last_reunion, data: { type: 'reunion', attributes: update_reunion_attributes.except(:end_date) } }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.all.count).to eq(6) }
      it { expect(Reunion.last).to have_attributes update_reunion_attributes }
    end

    context "when updating a discarded reunion" do
      before do
        last_reunion.discard
        patch :update, params: { id: last_reunion, data: { type: 'reunion', attributes: update_reunion_attributes } }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response.body).to eq(' ') }
    end
    
    context "when updating a non existant reunion" do
      before do
        invalid_id = Reunion.maximum(:id) + 1
        patch :update, params: { id: invalid_id , data: { type: 'reunion', attributes: update_reunion_attributes } }
      end

      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe "DELETE #destroy" do
    context "when destroying a valid reunion" do
      before { delete :destroy, params: { id: Reunion.last } }

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.all.count).to eq(4) }
      it { expect(Reunion.last.discarded?).to be(true) }
      it { expect(Reunion.kept.count).to eq(3) }
      it { expect(Reunion.discarded.count).to eq(1) }
    end

    context "when destroying a discarded reunion" do
      before do
        last_reunion = Reunion.last
        last_reunion.discard
        delete :destroy, params: { id: last_reunion }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response.body).to eq(' ') }
      it { expect(Reunion.all.count).to eq(4) }
      it { expect(Reunion.kept.count).to eq(3) }
      it { expect(Reunion.discarded.count).to eq(1) }
    end

    context "when destroying a non existant reunion" do
      before do
        invalid_id = Reunion.maximum(:id) + 1
        delete :destroy, params: { id: invalid_id }
      end

      it { expect(response).to have_http_status(:not_found) }
      it { expect(Reunion.all.count).to eq(4) }
      it { expect(Reunion.kept.count).to eq(4) }
      it { expect(Reunion.discarded.count).to eq(0) }
    end
  end

  describe "POST #publish" do
    let(:error_message) { (JSON response.body).dig('errors') }
    context "when publishing a valid reunion" do
      before do
        create(:reunion, :publishable)
        post :publish, params: { id: Reunion.last }
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(Reunion.published_state.count).to eq(1) }
    end

    context "when publishing a reunion without name" do
      before do
        create(:reunion, :publishable, name: nil)
        post :publish, params: { id: Reunion.last }
      end

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(Reunion.published_state.count).to eq(0) }
      it { expect(error_message).to be_present}
    end

    context "when publishing a reunion without description" do
      before do
        create(:reunion, :publishable, description: nil)
        post :publish, params: { id: Reunion.last }
      end

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(Reunion.published_state.count).to eq(0) }
      it { expect(error_message).to be_present}
    end

    context "when publishing a reunion without location" do
      before do
        create(:reunion, :publishable, location: nil)
        post :publish, params: { id: Reunion.last }
      end

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(Reunion.published_state.count).to eq(0) }
      it { expect(error_message).to be_present}
    end

    context "when publishing a reunion without start_date" do
      before do
        create(:reunion, :publishable, start_date: nil)
        post :publish, params: { id: Reunion.last }
      end

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(Reunion.published_state.count).to eq(0) }
      it { expect(error_message).to be_present}
    end

    context "when publishing a reunion without end_date" do
      before do
        create(:reunion, :publishable, end_date: nil)
        post :publish, params: { id: Reunion.last }
      end

      it { expect(response).to have_http_status(:bad_request) }
      it { expect(Reunion.published_state.count).to eq(0) }
      it { expect(error_message).to be_present}
    end

    context "when publishing a discarded reunion" do
      before do
        last_reunion = Reunion.last
        last_reunion.discard
        post :publish, params: { id: last_reunion }
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(Reunion.published_state.count).to eq(0) }
    end

    context "when publishing a non existant reunion" do
      before { post :publish, params: { id: Reunion.maximum(:id) + 1 } }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(Reunion.published_state.count).to eq(0) }
    end
  end
end
