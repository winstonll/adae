class SearchController < ApplicationController

  def search

    data = params[:search_text].nil? ? "" : params[:search_text].downcase

    stripped= data.split(" ")
    stripped -= %w{for and nor but or yet so either not only may neither both whether just as much rather why the is a this then than them their}
    stripped = stripped.join(" ")

    @query = Array.new()
    r = Regexp.new(Regexp.escape(data.downcase))

    unless(stripped.empty?)
      Item.find_each do |item|
        unless (r.match(item.title.downcase).to_s.empty?) &&
        (r.match(item.description.downcase).to_s.empty?) &&
        (r.match(item.tags.downcase).to_s.empty?)
          @query << item
        end
      end
      Request.find_each do |request|
        unless (r.match(request.title.downcase).to_s.empty?) &&
        (r.match(request.description.downcase).to_s.empty?) &&
        (r.match(request.tags.downcase).to_s.empty?)
          @query << request
        end
      end
    end

    if(@query.empty?)
      flash[:notice] = "Nothing matched your search."
    end

  end

end
