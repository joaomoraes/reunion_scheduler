# frozen_string_literal: true
class Reunion < ApplicationRecord

  include Discard::Model
  enum state: { published: "published", draft: "draft" }, _suffix: true

  validate :end_date_earlier_than_start_date
  validates_presence_of :name, :description, :location, :start_date, :end_date, if: :published_state?

  def duration
    return unless start_date && end_date
    (end_date - start_date).to_i + 1
  end

  def publish
    self.state = :published
    save
  end

  private

  def end_date_earlier_than_start_date
    if start_date && end_date && end_date < start_date
      errors.add(:end_date, "can't be earlier than start_date")
    end
  end

end
