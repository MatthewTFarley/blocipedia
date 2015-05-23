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
    return @wikis = Wiki.public_wikis.order(updated_at: :desc).paginate(page: params[:page], per_page: 10) if current_user.blank?
    @wikis = current_user.viewable_wikis.sort_by{ |wiki| wiki.updated_at}.reverse.paginate(page: params[:page], per_page: 10)
  end

  def show
  end

  def edit
  end

  def update
    if @wiki.update_attributes(wiki_params)
      @wiki.collaborators = Collaboration.add_collaborators @wiki, params
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
    @wiki = Wiki.find(params[:id])
  end

  def wiki_params
    params.require(:wiki).permit(:title, :body, :private)
  end

  def authorize
    redirect_to wikis_path, flash: "You are not authorized to view that resource." unless @wiki.private == false || current_user.view?(@wiki)
  end 
end