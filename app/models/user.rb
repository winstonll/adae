class User < ActiveRecord::Base
	has_one :location, :dependent => :destroy
	has_many :reviews
	has_many :ratings
	has_many :items
	has_many :items_reviewed, through: :reviews, source: :items
	has_many :items_rated, through: :ratings, source: :items
	serialize :stripe_account_status, JSON
	validates :auth_token, uniqueness: true
	accepts_nested_attributes_for :location

 	# Include default devise modules. Others available are:
 	# , :lockable, :timeoutable and :omniauthable
  	devise :database_authenticatable, :registerable, #:confirmable,
         :recoverable, :rememberable, :trackable, :validatable

	before_create :ensure_authentication_token # :generate_authentication_token

	validates :avatar,
    attachment_content_type: { content_type: /\Aimage\/.*\Z/ },
    attachment_size: { less_than: 5.megabytes }

	has_attached_file :avatar, styles: { small: "40x40", med: "120x120", large: "200x200" },
			:default_url => "/paperclip/default/default_avatar_:style.png"

  #include DeviseTokenAuth::Concerns::User

	def ensure_authentication_token
		if auth_token.blank?
			self.auth_token = generate_authentication_token
		end
	end

	def full_name
		"#{name} #{surname}"
	end

	def rated?(item)
		ratings.find_by(item: item)
	end

	# General 'has a Stripe account' check
	def connected?; !stripe_user_id.nil?; end

	# Stripe account type checks
	def managed?; stripe_account_type == 'managed'; end
	# def standalone?; stripe_account_type == 'standalone'; end
  	# def oauth?; stripe_account_type == 'oauth'; end

  	def manager
		case stripe_account_type
		when 'managed' then StripeManaged.new(self)
		# when 'standalone' then StripeStandalone.new(self)
		# when 'oauth' then StripeOauth.new(self)
		end
  	end

	def can_accept_charges
		# return true if oauth?
		return true if managed? && stripe_account_status['charges_enabled']
		# return true if standalone? && stripe_account_status['charges_enabled']
		return false
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

end
