# frozen_string_literal: true
class SerializableReunion < JSONAPI::Serializable::Resource
  type 'reunions'

  attributes :name, :description, :location, :state, :start_date, :end_date, :duration
end