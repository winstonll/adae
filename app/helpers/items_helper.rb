module ItemsHelper
	def present_or_rated?(item)
		if current_user.present?
			current_user.rated?(item)
		else
			false
		end
	end
end
