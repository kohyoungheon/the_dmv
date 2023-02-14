class FacilityFactory
  attr_reader :facilities

  def initialize
    @facilities = []
  end

  def create_facilities(facility_hash)
    facility_hash.each do |facility|
      new_hash = Hash.new
      facility.each do |key, value|
        if key == :title
          new_hash[:name] = value
        end
        if key == :phone_number
          new_hash[:phone] = value
        end
        if key == :location_1
          new_hash[:address] = facility[:location_1][:human_address]
        end
        if key == :office_name
          new_hash[:name] = "#{value} #{facility[:office_type]}"
        end
        if key == :public_phone_number
          new_hash[:phone] = value
        end
        if key == :street_address_line_1
          new_hash[:address] = "#{value} #{facility[:city]} #{facility[:state]} #{facility[:zip_code]}"
        end
        if key == :address1
          new_hash[:address] = "#{value} #{facility[:state]} #{facility[:zipcode]}"
        end
        if key == :name
          new_hash[:name] = value
        end
        if key == :phone
          new_hash[:phone] = value
        end
      end
      @facilities << new_hash
    end
    @facilities
  end
end