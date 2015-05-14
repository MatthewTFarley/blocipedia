class CollaborationsController < ApplicationController
  def destroy
    @collaboration = Collaboration.find(params[:id])
    if @collaboration.destroy
      flash[:notice] = "Collaborator successfully removed."
      redirect_to @collaboration.wiki
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
