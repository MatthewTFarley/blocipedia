class CollaborationsController < ApplicationController
  def destroy
    @collaborator = Collaboration.find(params[:user_id][:wiki_id])
    if @collaborator.destroy!
      flash[:success] = "Collaborator successfully removed."
      render 'wiki'
    else
      flash[:error] = "Something went wrong. Please try again."
      render 'wiki'
    end
  end

  private

  def collaboration_params
    params.require(:collaboration).permit(:user_id, :wiki_id)
  end
end
