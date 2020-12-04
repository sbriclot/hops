class ListsController < ApplicationController
  before_action :set_lists, only: %i[show destroy]

  def index
    @lists = List.where(user_id: current_user.id)
    @white_count = List.joins(:contents).where("name = 'Whitelist' AND user_id = ?", current_user.id).count
    @black_count = List.joins(:contents).where("name = 'Blacklist' AND user_id = ?", current_user.id).count
    @wish_count = List.joins(:contents).where("name = 'Wishlist' AND user_id = ?", current_user.id).count
    @list_count = List.joins(:contents).where("name NOT IN ('Whitelist', 'Blacklist', 'Wishlist') AND user_id = ?", current_user.id).count
    @whitelist = Beer.joins(:lists).where("lists.name = 'Whitelist' AND lists.user_id = ?", current_user.id)
    @blacklist = Beer.joins(:lists).where("lists.name = 'Blacklist' AND lists.user_id = ?", current_user.id)
    @wishlist = Beer.joins(:lists).where("lists.name = 'Wishlist' AND lists.user_id = ?", current_user.id)
    @custom_lists = Beer.joins(:lists).where("lists.name NOT IN ('Whitelist', 'Blacklist', 'Wishlist') AND lists.user_id = ?", current_user.id)
  end

  def new
    @list = List.new
  end

  def create
    @list = List.new(lists_params)
    @list.deletable = true
    @list.user = current_user

    if @list.save
      redirect_to list_path(@list)
    else
      render :new
    end
  end

  def show
    @contents = @list.contents
  end

  def destroy
    @list.destroy
    redirect_to lists_path
  end

  private

  def lists_params
    params.require(:list).permit(:name)
  end

  def set_lists
    @list = List.find(params[:id])
  end
end
