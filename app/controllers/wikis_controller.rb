class WikisController < ApplicationController
  require 'will_paginate/array'
  before_action :set_wiki, except: [:new, :create, :index]
  before_action :authenticate_user, except: [:index, :show]
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
    @index = 1 # for table layout
    return @wikis = Wiki.public_wikis.paginate(page: params[:page], per_page: 10) if current_user.blank?
    @wikis = current_user.viewable_wikis.paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def edit
  end

  def update
    if @wiki.update_attributes(wiki_params)
      return head :unauthorized unless current_user.owns? @wiki
      @wiki.add_collaborators params[:wiki][:collaborators]
      @wiki.save!
      flash[:notice] = "Wiki successfully updated!"
      redirect_to @wiki
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
    @wiki = Wiki.friendly.find(params[:id])
  end

  def wiki_params
    params.require(:wiki).permit(:title, :body, :private)
  end

  def authorize
    return if current_user && current_user.view?(@wiki)
    if @wiki.private
      redirect_to wikis_path, notice: "You are not authorized to view that resource."
    end
  end 
end