module NightWatch
  class RefRange
    attr_reader :from, :to

    def initialize(from, to)
      @from = from
      @to = to
      freeze
    end

    def to_s
      from == to ? from : "#{from}..#{to}"
    end

    def self.parse(ref_range_string)
      if match_data = /^(?<from>.+)\.\.(?<to>.+)$/.match(ref_range_string)
        new(match_data[:from], match_data[:to])
      else
        new(ref_range_string, ref_range_string)
      end
    end
  end
end
