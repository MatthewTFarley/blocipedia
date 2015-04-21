class WikisController < ApplicationController
  before_action :authorize, except: [:index, :show]
  
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
    @wiki = Wiki.find(params[:id])
  end

  def edit
    @wiki = Wiki.find(params[:id])
  end

  def update
    @wiki = Wiki.find(params[:id])    
    if @wiki.update_attributes(wiki_params)
      flash[:notice] = "Wiki successfully updated!"
      redirect_to @wiki
    else
      flash[:error] = "There was a problem while updating this wiki. Please try again."
      render 'edit'
    end
  end

  def delete
    @wiki = Wiki.find(params[:id])
  end

  def destroy
    @wiki = Wiki.find(params[:id])
    if @wiki.destroy
      flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
      redirect_to wikis_path
    else
      flash[:error] = "There was a problem while deleting this wiki. Please try again."
      render :show
    end
  end
  
  private
  
  def wiki_params
    params.require(:wiki).permit(:title, :body, :private)
  end
  
end