class ListsController < ApplicationController
  before_action :set_lists, only: %i[show destroy edit update]

  def index
    @list = List.new
    # Get all the lists of the user and the custom lists
    @lists = List.where(user_id: current_user.id)
    @whitelist_instance = @lists.where(name: 'Whitelist').take
    @blacklist_instance = @lists.where(name: 'Blacklist').take
    @wishlist_instance = @lists.where(name: 'Wishlist').take
    @custom_list = @lists - List.where("name IN ('Whitelist', 'Blacklist', 'Wishlist')")

    # Count all the rows of each core list
    @white_count = List.joins(:contents).where("name = 'Whitelist' AND user_id = ?", current_user.id).count
    @black_count = List.joins(:contents).where("name = 'Blacklist' AND user_id = ?", current_user.id).count
    @wish_count = List.joins(:contents).where("name = 'Wishlist' AND user_id = ?", current_user.id).count
    @list_count = List.joins(:contents).where("name NOT IN ('Whitelist', 'Blacklist', 'Wishlist') AND user_id = ?", current_user.id).count

    # Get the content of each core list
    @whitelist = Beer.joins(:lists).where("lists.name = 'Whitelist' AND lists.user_id = ?", current_user.id)
    @blacklist = Beer.joins(:lists).where("lists.name = 'Blacklist' AND lists.user_id = ?", current_user.id)
    @wishlist = Beer.joins(:lists).where("lists.name = 'Wishlist' AND lists.user_id = ?", current_user.id)
    @custom_lists = Beer.joins(:lists).where("lists.name NOT IN ('Whitelist', 'Blacklist', 'Wishlist') AND lists.user_id = ?", current_user.id)

    # Initialize arrays to store beer_id of each core list
    # Inclusion of beer.id in the list displays the icon or not on the card-lg
    @blacklist_ids = []
    @whitelist_ids = []
    @wishlist_ids = []
    @customlists_ids = []
    @blacklist.each {|x| @blacklist_ids << x.id} if
    @whitelist.each {|x| @whitelist_ids << x.id}
    @wishlist.each {|x| @wishlist_ids << x.id}
    @custom_lists.each {|x| @customlists_ids << x.id}
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(lists_params)
    @list.deletable = true
    @list.user = current_user
    @list.save
    redirect_to lists_path
  end

  def show
    @contents = @list.contents
    # Initialize content in case we add a beer to the list
    @content = Content.new
    # Get the content of each core list
    @whitelist = Beer.joins(:lists).where("lists.name = 'Whitelist' AND lists.user_id = ?", current_user.id)
    @blacklist = Beer.joins(:lists).where("lists.name = 'Blacklist' AND lists.user_id = ?", current_user.id)
    @wishlist = Beer.joins(:lists).where("lists.name = 'Wishlist' AND lists.user_id = ?", current_user.id)
    @custom_lists = Beer.joins(:lists).where("lists.name NOT IN ('Whitelist', 'Blacklist', 'Wishlist') AND lists.user_id = ?", current_user.id)

    # Initialize arrays to store beer_id of each core list
    # Inclusion of beer.id in the list displays the icon or not on the card-lg
    @blacklist_ids = []
    @whitelist_ids = []
    @wishlist_ids = []
    @customlists_ids = []
    @blacklist.each {|x| @blacklist_ids << x.id} if
    @whitelist.each {|x| @whitelist_ids << x.id}
    @wishlist.each {|x| @wishlist_ids << x.id}
    @custom_lists.each {|x| @customlists_ids << x.id}
  end

  def edit
  end

  def update
    if @list.update(lists_params)
      redirect_to lists_path
    else
      render :edit
    end
  end

  def destroy
    list_name = @list.name
    if @list.deletable
      @list.destroy
      redirect_to lists_path + '#custom' , notice: "#{list_name} successfully destroyed"
    else
      redirect_to lists_path(tab: "#custom-tab") + '#custom', notice: "#{list_name} cannot be deleted. This is a core list"
    end
  end

  private

  def lists_params
    params.require(:list).permit(:name)
  end

  def set_lists
    @list = List.find(params[:id])
  end
end
