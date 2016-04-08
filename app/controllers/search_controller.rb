class SearchController < ApplicationController

  def search

    data = params[:search_text].nil? ? "" : params[:search_text].downcase

    stripped= data.split(" ")
    stripped -= %w{for and nor but or yet so either not only may neither both whether just as much rather why the is a this then than them their}
    stripped = stripped.join(" ")

    @itemquery = Array.new()
    @requestquery = Array.new()
    r = Regexp.new(Regexp.escape(data.downcase))

    unless(stripped.empty?)
      Item.where(status: "Listed").find_each do |item|
        unless (r.match(item.title.downcase).to_s.empty?) &&
        (r.match(item.description.downcase).to_s.empty?) &&
        (r.match(item.tags.downcase).to_s.empty?) &&
        (r.match(item.postal_code.downcase).to_s.empty?)
          @itemquery << item
        end
      end
      Request.find_each do |request|
        unless (r.match(request.title.downcase).to_s.empty?) &&
        (r.match(request.description.downcase).to_s.empty?) &&
        (r.match(request.tags.downcase).to_s.empty?) &&
        (r.match(request.postal_code.downcase).to_s.empty?)
          @requestquery << request
        end
      end
    end

    if (@itemquery.empty?)
      flash.now[:warning] = "Nothing matched your search in Listings."
    elsif (@requestquery.empty?)
      flash.now[:warning] = "Nothing matched your search in Shoutouts."
    end

  end

end
