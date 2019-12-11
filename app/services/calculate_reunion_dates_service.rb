class CalculateReunionDatesService

  class << self
    def calculate_from(reunion:, start_date: nil, end_date: nil, duration: nil)
      if (start_date && end_date)
        reunion.start_date = start_date
        reunion.end_date = end_date
        true
      elsif(duration > 0 && start_date)
        reunion.start_date = start_date
        reunion.end_date = reunion.start_date + duration - 1
        true
      elsif(duration > 0 && end_date)
        reunion.end_date = end_date
        reunion.start_date = reunion.end_date - duration + 1
        true
      end
      false
    end

  end

end