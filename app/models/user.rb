class User < ApplicationRecord
	has_secure_password
	has_many :devices

	validates :email, presence: true, uniqueness: true

	def filtered_devices
		self.devices.map { |device| OpenStruct.new({id: device.id, name: device.name}) }
	end
end
