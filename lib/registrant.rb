class Registrant
  attr_reader :name, :age, :permit, :license_data
  attr_writer :license_data
  def initialize(name, age, permit = false)
    @name = name
    @age = age
    @permit = permit
    @license_data = {
      :written => false,
      :license => false,
      :renewed => false
    }
  end

  def permit?
    @permit == true
  end

  def earn_permit
    @permit = true
  end
end