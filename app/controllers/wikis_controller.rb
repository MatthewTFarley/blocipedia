class WikisController < ApplicationController
  before_action :set_wiki, except: [:new, :create, :index]
  before_action :authenticate_user, except: [:index]
  before_action :authorize, only: [:show]
  
  def new
    @wiki = Wiki.new
  end

  def create
    @wiki = Wiki.new(wiki_params)
    @wiki.user = current_user
    if @wiki.save
      redirect_to @wiki, notice: "Wiki was successfully saved!"
    else
      flash[:error] = "Error creating wiki. Please try again."
      render 'new'
    end
  end

  def index
    @wikis = Wiki.available_wikis_for current_user
  end

  def show
  end

  def edit
  end

  def update
    if @wiki.update_attributes(wiki_params)
      user = params[:wiki][:users]
      if params[:method] == "delete"
        @wiki.users.delete(user)
      elsif !(@wiki.users.each {|user| user.name == user} == [])
        flash[:notice] = "That user is already a collaborator for this wiki."
        render 'edit'
      elsif user == ""|| @wiki.users << User.find_by(name: user)
        @wiki.save!
        flash[:notice] = "Wiki successfully updated!"
        redirect_to @wiki
      end
    else
      flash[:error] = "There was a problem while updating this wiki. Please try again."
      render 'edit'
    end
  end

  def destroy
    if @wiki.destroy
      flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
      redirect_to wikis_path
    else
      flash[:error] = "There was a problem while deleting this wiki. Please try again."
      render :show
    end
  end
  
  private
  
  def set_wiki
    @wiki = Wiki.find(params[:id])
  end

  def wiki_params
    params.require(:wiki).permit(:title, :body, :private)
  end

  def authorize
    redirect_to wikis_path, notice: "You are not authorized to view that resource." unless current_user.view? @wiki
  end
  
end