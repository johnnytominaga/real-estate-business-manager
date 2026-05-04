class DateConverter
  def self.convert(value)
    Date.strptime( value, "%d/%m/%Y") # parses custom date format into Date instance
  end
end
