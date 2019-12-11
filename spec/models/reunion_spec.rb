# frozen_string_literal: true
require 'rails_helper'
RSpec::Matchers.define_negated_matcher :avoid_changing, :change

RSpec.describe Reunion, type: :model do
  let(:reunion) { build(:reunion) }

  describe "#state" do
    it { expect(described_class.states).to eq( { 'published' => "published", 'draft' => "draft" } ) }

    context "when reunion is created" do
      it { expect(reunion.state).to eq('draft') }
    end

    context "when with invalid value" do
      it { expect{ reunion.state = 'invalid_state' }.to raise_error(ArgumentError, "'invalid_state' is not a valid state") }
    end
  end

  describe "#duration" do
    let(:duration) { reunion.duration }
    context "when start_date and end_date are nil" do 
      it { expect(duration).to be_nil }
    end

    context "when start_date is nil" do
      let(:reunion) { build(:reunion, end_date: 2.days.from_now) }
      it { expect(duration).to be_nil }
    end

    context "when end_date is nil" do
      let(:reunion) { build(:reunion, start_date: 2.days.from_now) }
      it { expect(duration).to be_nil }
    end

    context "when both start_date and end_date are present" do
      let(:reunion) { build(:reunion, start_date: 2.days.from_now, end_date: 4.days.from_now) }
      it { expect(reunion.duration).to eq(3) }
    end

    context "when both start_date and end_date are the same" do
      let(:reunion) { build(:reunion, start_date: 2.days.from_now, end_date: 2.days.from_now) }
      it { expect(reunion.duration).to eq(1) }
    end
  end

  describe "#publish" do
    before { reunion.publish }

    context "when name, description, location, start_date and end_date are filled" do
      let(:reunion) { build(:reunion, :publishable) }

      
      it { expect(Reunion.published_state.count).to be(1) }
      it { expect(reunion).to be_valid }
      it { expect(reunion.errors).to be_empty }
    end
    context "when name is not filled" do
      let(:reunion) { build(:reunion, :published, name: nil) }

      it { expect(Reunion.published_state.count).to be(0) }
      it { expect(reunion).to be_invalid }
      it { expect(reunion.errors).to_not be_empty }
    end
    context "when description is not filled" do
      let(:reunion) { build(:reunion, :published, description: nil) }

      it { expect(Reunion.published_state.count).to be(0) }
      it { expect(reunion).to be_invalid }
      it { expect(reunion.errors).to_not be_empty }
    end
    context "when location is not filled" do
      let(:reunion) { build(:reunion, :published, location: nil) }

      it { expect(Reunion.published_state.count).to be(0) }
      it { expect(reunion).to be_invalid }
      it { expect(reunion.errors).to_not be_empty }
    end
    context "when start_date is not filled" do
      let(:reunion) { build(:reunion, :published, start_date: nil) }

      it { expect(Reunion.published_state.count).to be(0) }
      it { expect(reunion).to be_invalid }
      it { expect(reunion.errors).to_not be_empty }
    end
    context "when end_date is not filled" do
      let(:reunion) { build(:reunion, :published, end_date: nil) }

      it { expect(Reunion.published_state.count).to be(0) }
      it { expect(reunion).to be_invalid }
      it { expect(reunion.errors).to_not be_empty }
    end
  end

  describe "validations" do
    let(:error_messages) { reunion.errors.messages }
    before { reunion.valid? }

    describe "#end_date_earlier_than_start_date" do
      let(:end_date_error_message) { error_messages[:end_date] }

      context "when end_date is earlier than start_date" do
        let(:reunion) { build(:reunion, start_date: 2.days.from_now, end_date: 1.day.from_now) }

        it { expect(reunion).to_not be_valid }
        it { expect(end_date_error_message).to_not be_empty }
      end

      context "when end_date is older than start_date" do
        let(:reunion) { build(:reunion, start_date: 2.days.from_now, end_date: 4.day.from_now) }

        it { expect(reunion).to be_valid }
        it { expect(end_date_error_message).to be_empty }
      end
    end

    describe "with published state " do
      context "when name, description, location, start_date and end_date are filled" do
        let(:reunion) { build(:reunion, :published) }

        it { expect(reunion).to be_valid }
        it { expect(error_messages).to be_empty }
      end
      context "when name is not filled" do
        let(:reunion) { build(:reunion, :published, name: nil) }

        it { expect(reunion).to be_invalid }
        it { expect(error_messages[:name]).to_not be_empty }
      end
      context "when description is not filled" do
        let(:reunion) { build(:reunion, :published, description: nil) }

        it { expect(reunion).to be_invalid }
        it { expect(error_messages[:description]).to_not be_empty }
      end
      context "when location is not filled" do
        let(:reunion) { build(:reunion, :published, location: nil) }

        it { expect(reunion).to be_invalid }
        it { expect(error_messages[:location]).to_not be_empty }
      end
      context "when start_date is not filled" do
        let(:reunion) { build(:reunion, :published, start_date: nil) }

        it { expect(reunion).to be_invalid }
        it { expect(error_messages[:start_date]).to_not be_empty }
      end
      context "when end_date is not filled" do
        let(:reunion) { build(:reunion, :published, end_date: nil) }

        it { expect(reunion).to be_invalid }
        it { expect(error_messages[:end_date]).to_not be_empty }
      end
    end
  end

end
