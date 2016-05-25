class User < ActiveRecord::Base
	has_one :location, :dependent => :destroy
	has_many :reviews
	has_many :ratings
	has_many :items
	has_many :requests
	has_many :items_reviewed, through: :reviews, source: :items
	has_many :items_rated, through: :ratings, source: :items
	has_many :referrals
	has_many :referreds

	serialize :stripe_account_status, JSON
	validates :auth_token, uniqueness: true
	accepts_nested_attributes_for :location

	devise :database_authenticatable, :registerable, :confirmable,
       :recoverable, :rememberable, :trackable, :validatable,
			 :omniauthable, :omniauth_providers => [:facebook]

	before_create :ensure_authentication_token

	validates :avatar,
    attachment_content_type: { content_type: /\Aimage\/.*\Z/ },
    attachment_size: { less_than: 5.megabytes }

	has_attached_file :avatar, styles: { small: "40x40", med: "120x120", large: "200x200" },
			:default_url => "/paperclip/default/default_avatar_:style.png"

	def self.from_omniauth(auth)
		where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
			user.email = auth.info.email
			@pass = Devise.friendly_token[0,20]
			user.password = @pass

			name = auth.info.name.split(" ")

			# split name into first name and surname
			user.name = name.first
			user.surname = name.second

			# create user avatar from facebook profile image
			user.photo_url = auth.info.image
			user.update( avatar: process_uri(auth.info.image))

			@user = user
			# Send email reminding user to change their randomly generated password
			ChangePasswordEmailJob.set(wait: 1.seconds).perform_later(@user, @pass)

			# Generate referral code and their location
			@referral = Referral.new()

      loop do
        @code=SecureRandom.hex(8).upcase
        [4,9,14].each do |f|
          @code.insert(f, "-")
        end
  			break @referral.code = @code unless Referral.where(code: @code).first
  		end

      @referral.amount = 5.00
      @referral.user_id = @user.id
      @referral.save

      @location = Location.new(user_id: @user.id, country: "CA", city: "Toronto")
      @location.save
		end
	end

	def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.update( image:process_uri(auth.info.image))
	end

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

	def self.process_uri(uri)
    avatar_url = URI.parse(uri)
    avatar_url.scheme = 'https'
    avatar_url.to_s
	end

	def generate_authentication_token
		loop do
			token = Devise.friendly_token
			break token unless User.where(auth_token: token).first
		end
	end

end
