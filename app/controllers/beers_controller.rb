class BeersController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_beers, only: %i[show destroy edit update validate! decline!]

  def index
    @beers = Beer.where(:validated == true || current_user == :user_id)
                 .includes(:brewery, :color, :style)
                 .order(:name)
  end

  def show
    # Initialize content to enable content create via action buttons
    @content = Content.new

    # Get the non-deletable lists of current_user
    @whitelist = List.where(user_id: current_user.id, name: 'Whitelist').first
    @blacklist = List.where(user_id: current_user.id, name: 'Blacklist').first
    @wishlist = List.where(user_id: current_user.id, name: 'Wishlist').first
    @user_core_lists = [@whitelist, @blacklist, @wishlist]

    # Get the active non-deletable list (if any)
    @active_core_list = @user_core_lists.reject { |list| @beer.contents.where(list_id: list.id).empty? }.first
    unless @active_core_list.nil?
    @active_core_content = @active_core_list.contents.where(beer_id: @beer.id, list_id: @active_core_list.id).take
    end

    # Display review if it exists, create empty review otherwise
    @beer_user_review = Review.where(beer_id: @beer.id, user_id: current_user.id).first
    if @beer_user_review
      @review = @beer_user_review
    else
      @review = Review.new
    end

    # WIP : Automate tag creation if nil?
    beer_tags = %i[alcohol_strength ibu]
    beer_attr = %i[brewery color style]

    # Count beers in each list
    @white_count = List.joins(:contents).where("name = 'Whitelist' AND beer_id = ?", @beer.id).count
    @black_count = List.joins(:contents).where("name = 'Blacklist' AND beer_id = ?", @beer.id).count
    @wish_count = List.joins(:contents).where("name = 'Wishlist' AND beer_id = ?", @beer.id).count
    @list_count = List.joins(:contents).where("name NOT IN ('Whitelist', 'Blacklist', 'Wishlist') AND beer_id = ?", @beer.id).count
  end

  def new
    @beer = Beer.new
  end

  def create
    @beer = Beer.new(beers_params)
    @beer.user = current_user
    @beer.validated = false unless current_user.admin

    if @beer.save
      redirect_to beer_path(@beer), notice: "#{@beer.name} successfully created"
    else
      render :new
    end
  end

  def edit
    fail
  end

  def update
    @beer.update(beers_params)
    redirect_to beer_path(@beer), notice: "#{@beer.name} successfully updated"
  end

  def destroy
    beer_name = @beer.name
    @beer.destroy
    redirect_to root_path, alert: "#{beer_name} successfully deleted"
  end

  def validation
    @pending_validations = Beer.where(validated: false)
  end

  def validate
    @beer.validated = true
    @beer.save
    redirect_to beer_path(@beer), notice: 'Beer sucessfully validated'
  end

  def decline
    @beer.validated = false
    @beer.save
    redirect_to beer_path(@beer), notice: 'Beer sucessfully declined'
  end

  private

  def beers_params
    params.require(:beer).permit(:name, :description, :alcohol_strength, :ibu, :barcode, :brewery_id, :color_id, :style_id, :photo)
  end


  def set_beers
    @beer = Beer.find(params[:id])
  end
end
