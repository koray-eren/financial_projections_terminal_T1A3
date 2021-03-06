require_relative("Cashflow")

class Income < Cashflow
    attr_reader :taxable
    def initialize(name, value, first_year, last_year, taxable=true)
        super(name, value, first_year, last_year)
        @taxable = taxable
    end

    def taxable_income(year)
        @taxable ? future_value(year) : 0
    end

    def to_array
        [@name, @value, @first_year, @last_year, @taxable]
    end

    def to_hash
        {   'name' => @name,
            'value' => @value,
            'first_year' => @first_year,
            'last_year' => @last_year,
            'taxable' => @taxable }
    end

    def self.from_hash(hash)
        self.new(hash['name'], hash['value'], hash['first_year'], hash['last_year'], hash['taxable'] )
    end

end