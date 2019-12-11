# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CalculateReunionDatesService do
  describe ".calculate_from" do
    let(:reunion) { build(:reunion) }
    let(:start_date)  { '2019/05/01'.to_date }
    let(:end_date)    { '2019/05/10'.to_date }
    let(:duration)    { 10 }

    context "receives all parameters" do
      before { described_class.calculate_from({ reunion: reunion, start_date: start_date, end_date: end_date, duration: duration }) }

      it { expect(reunion.start_date).to eq(start_date) }
      it { expect(reunion.end_date).to eq(end_date) }
    end

    context "receives only start_date and end_date" do
      before { described_class.calculate_from({ reunion: reunion, start_date: start_date, end_date: end_date }) }

      it { expect(reunion.start_date).to eq(start_date) }
      it { expect(reunion.end_date).to eq(end_date) }
    end

    context "receives only start_date and duration" do
      before { described_class.calculate_from({ reunion: reunion, start_date: start_date, duration: duration }) }
      
      context "when duration equals 10" do
        it { expect(reunion.start_date).to eq(start_date) }
        it { expect(reunion.end_date).to eq(end_date) }
      end

      context "when duration equals 1" do
        let(:duration) { 1 }
        it { expect(reunion.start_date).to eq(start_date) }
        it { expect(reunion.end_date).to eq(start_date) }
      end
    end

    context "when receives only end_date and duration" do
      before { described_class.calculate_from({ reunion: reunion, end_date: end_date, duration: duration }) }

      context "when duration equals 10" do
        it { expect(reunion.start_date).to eq(start_date) }
        it { expect(reunion.end_date).to eq(end_date) }
      end

      context "when duration equals 1" do
        let(:duration) { 1 }
        it { expect(reunion.start_date).to eq(end_date) }
        it { expect(reunion.end_date).to eq(end_date) }
      end

    end
  end
end