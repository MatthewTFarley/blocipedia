class WelcomeController < ApplicationController
  def index
    redirect_to wikis_path if current_user
  end

  def about
  end
end
