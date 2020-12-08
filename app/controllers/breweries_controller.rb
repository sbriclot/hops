class BreweriesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]
  before_action :set_brewery, only: %i[show edit update destroy]
  before_action :count_white_list, :count_black_list, :count_wish_list, :count_custom_list, :count_amber_beers,
                :count_black_beers, :count_blond_beers, :count_ruby_beers, :count_white_beers, only: %i[show]

  def index
    @breweries = Brewery.all
  end

  def show
    if @brewery.geocoded?
      @markers = {
        lat: @brewery.latitude,
        lng: @brewery.longitude
      }
    else
      @markers = {
        lat: 50.631198343768695,
        lng: 3.054824203881607
      }
    end
  end

  def new
    @brewery = Brewery.new
    # @countries = Country.all
  end

  def create
    @brewery = Brewery.new(brewery_params)
    @brewery.address = "#{params[:brewery][:street]} #{params[:brewery][:zipcode]} #{params[:brewery][:city].capitalize}"

    if @brewery.save
      redirect_to brewery_path(@brewery), notice: 'Brewery sucessfully created'
    else
      render :new
    end
  end

  def destroy
    @brewery.destroy
    redirect_to breweries_path, notice: 'Brewery sucessfully deleted'
  end

  private

  def brewery_params
    params.require(:brewery).permit(:name, :street, :zipcode, :city, :country_id, :photo)
  end

  def set_brewery
    @brewery = Brewery.includes(:beers, beers: [:color, { contents: [:lists] }]).find(params[:id])
  end

  def count_white_list
    @whitelist_count = 0
    @brewery.beers.each do |beer|
      single_white_count = List.joins(:contents).where("name = 'Whitelist' AND beer_id = ?", beer.id).count
      @whitelist_count += single_white_count
    end
    return @whitelist_count
  end

  def count_black_list
    @blacklist_count = 0
    @brewery.beers.each do |beer|
      single_black_count = List.joins(:contents).where("name = 'Blacklist' AND beer_id = ?", beer.id).count
      @blacklist_count += single_black_count
    end
    return @blacklist_count
  end

  def count_wish_list
    @wishlist_count = 0
    @brewery.beers.each do |beer|
      single_wish_count = List.joins(:contents).where("name = 'Wishlist' AND beer_id = ?", beer.id).count
      @wishlist_count += single_wish_count
    end
    return @wishlist_count
  end

  def count_custom_list
    @customlist_count = 0
    @brewery.beers.each do |beer|
      single_list_count = List.joins(:contents).where("name NOT IN ('Whitelist', 'Blacklist', 'Wishlist') AND beer_id = ?", beer.id).count
      @customlist_count += single_list_count
    end
    return @customlist_count
  end

  def count_amber_beers
    @amber_count = 0
    @brewery.beers.each do |beer|
      @amber_count += 1 if beer.color.name == 'Amber'
    end
  end

  def count_ruby_beers
    @ruby_count = 0
    @brewery.beers.each do |beer|
      @ruby_count += 1 if beer.color.name == 'Ruby'
    end
  end

  def count_black_beers
    @black_count = 0
    @brewery.beers.each do |beer|
      @black_count += 1 if beer.color.name == 'Black'
    end
  end

  def count_blond_beers
    @blond_count = 0
    @brewery.beers.each do |beer|
      @blond_count += 1 if beer.color.name == 'Blond'
    end
  end

  def count_white_beers
    @white_count = 0
    @brewery.beers.each do |beer|
      @white_count += 1 if beer.color.name == 'White'
    end
  end
end
