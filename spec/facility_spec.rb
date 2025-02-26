require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
  end
  describe '#initialize' do
    it 'can initialize' do
      expect(@facility).to be_an_instance_of(Facility)
      expect(@facility.name).to eq('Albany DMV Office')
      expect(@facility.address).to eq('2242 Santiam Hwy SE Albany OR 97321')
      expect(@facility.phone).to eq('541-967-2014')
      expect(@facility.services).to eq([])
      expect(@facility.registered_vehicles).to eq([])
      expect(@facility.collected_fees).to eq(0)
    end
  end

  describe '#add service' do
    it 'can add available services' do
      expect(@facility.services).to eq([])
      @facility.add_service('New Drivers License')
      @facility.add_service('Renew Drivers License')
      @facility.add_service('Vehicle Registration')
      expect(@facility.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end
  end

  describe '#register_vehicle' do
    it 'can register a vehicle' do
      camaro = Vehicle.new({vin_1_10: '1a2b3c4d5e6f', model_year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice})
      bolt = Vehicle.new({vin_1_10: '987654321abcdefgh', model_year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev})
      cruz = Vehicle.new({vin_1_10: '123456789abcdefgh', model_year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice})
      
      expect(@facility.register_vehicle(cruz)).to eq('This facility does not perform vehicle registration')
      expect(@facility.register_vehicle(bolt)).to eq('This facility does not perform vehicle registration')
      expect(@facility.register_vehicle(camaro)).to eq('This facility does not perform vehicle registration')

      @facility.add_service('Vehicle Registration')

      expect(cruz.registration_date).to eq(nil)
      @facility.register_vehicle(cruz)
      expect(cruz.registration_date).to eq(Date.today)
      expect(cruz.plate_type).to eq(:regular)
      expect(@facility.collected_fees).to eq(100)
      
      expect(bolt.registration_date).to eq(nil)
      expect(bolt.plate_type).to eq(nil)
      expect(@facility.collected_fees).to eq(100)
      @facility.register_vehicle(bolt)
      expect(bolt.registration_date).to eq(Date.today)
      expect(bolt.plate_type).to eq(:ev)
      expect(@facility.collected_fees).to eq(300)

      expect(camaro.plate_type).to eq(nil)
      expect(camaro.registration_date).to eq(nil)
      expect(@facility.collected_fees).to eq(300)
      @facility.register_vehicle(camaro)
      expect(camaro.plate_type).to eq(:antique)
      expect(camaro.registration_date).to eq(Date.today)
      expect(@facility.collected_fees).to eq(325)
    end
  end

  describe "#administer_written_test" do
    it 'administers test if registrant is over 16 and has permit' do
      registrant_1 = Registrant.new('Bruce', 18, true )
      
      expect(@facility.administer_written_test(registrant_1)).to eq(false)
      @facility.add_service('Written Test')
      expect(@facility.administer_written_test(registrant_1)).to eq(true)
      expect(registrant_1.license_data).to eq({:written=> true, :license=> false, :renewed=> false})
    end

    it 'returns false if registrant is under 16 and has no permit' do
      registrant_2 = Registrant.new('Tucker', 15, true )
      registrant_3 = Registrant.new('Bruce', 25, false )
      @facility.add_service('Written Test')
      expect(@facility.administer_written_test(registrant_2)).to eq(false)
      expect(@facility.administer_written_test(registrant_3)).to eq(false)
      
      registrant_3.earn_permit
      expect(@facility.administer_written_test(registrant_3)).to eq(true)
      expect(registrant_3.license_data).to eq({:written=> true, :license=> false, :renewed=> false})
    end
  end

  describe '#administer_road_test' do
    it 'administers test if registrant passed written test' do
      @facility.add_service('Written Test')
      @facility.add_service('Road Test')
      registrant_1 = Registrant.new('Bruce', 18, true )
      registrant_2 = Registrant.new('Tucker', 15, true )
      registrant_3 = Registrant.new('Bruce', 25, false )

      expect(@facility.administer_road_test(registrant_1)).to eq(false)
      expect(registrant_1.license_data[:license]).to eq(false)

      @facility.administer_written_test(registrant_1)

      expect(@facility.administer_road_test(registrant_1)).to eq(true)
      expect(registrant_1.license_data[:license]).to eq(true)

      @facility.administer_written_test(registrant_2)
      @facility.administer_written_test(registrant_3)

      expect(registrant_2.license_data[:written]).to eq(false)
      expect(registrant_3.license_data[:written]).to eq(false)
      expect(@facility.administer_road_test(registrant_2)).to eq(false)
      expect(@facility.administer_road_test(registrant_3)).to eq(false)
    end
  end
  
  describe '#renew_drivers_license' do
    it 'renews license if registrant has license' do
      @facility.add_service('Written Test')
      @facility.add_service('Road Test')
      @facility.add_service('Renew License')
      registrant_1 = Registrant.new('Bruce', 18, true )

      expect(registrant_1.license_data).to eq({:written=> false, :license=> false, :renewed=> false})
      @facility.administer_written_test(registrant_1)
      expect(@facility.renew_drivers_license(registrant_1)).to eq(false)
      @facility.administer_road_test(registrant_1)
      expect(registrant_1.license_data).to eq({:written=> true, :license=> true, :renewed=> false})
      expect(@facility.renew_drivers_license(registrant_1)).to eq(true)
      expect(registrant_1.license_data).to eq({:written=> true, :license=> true, :renewed=> true})
    end
  end
end
