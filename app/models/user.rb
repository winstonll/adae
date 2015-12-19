class User < ActiveRecord::Base
	has_many :reviews
	has_many :ratings
	has_many :items
	has_many :items_reviewed, through: :reviews, source: :items
	has_many :items_rated, through: :ratings, source: :items

	validates :auth_token, uniqueness: true

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable#,
          #:confirmable, :omniauthable

	before_create :ensure_authentication_token # :generate_authentication_token

  #include DeviseTokenAuth::Concerns::User

	def ensure_authentication_token
		if auth_token.blank?
			self.auth_token = generate_authentication_token
		end
	end

	private

	def generate_authentication_token
		loop do
			token = Devise.friendly_token
			break token unless User.where(auth_token: token).first
		end
		#begin
		#	self.auth_token = Devise.friendly_token
		#end while self.class.exists?(auth_token: self.auth_token)
	end

	def full_name
		"#{name} #{surname}"
	end

	def rated?(item)
		ratings.find_by(item: item)
	end
end
