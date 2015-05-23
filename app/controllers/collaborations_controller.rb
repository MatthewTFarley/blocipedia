class CollaborationsController < ApplicationController
  respond_to :html, :js
  def destroy
    @collaboration = Collaboration.find(params[:id])
    @wiki = @collaboration.wiki
    if !@collaboration.destroy
      flash[:error] = "Something went wrong. Please try again."
      render 'wiki'
    end

    respond_with(@collaboration) do |format|
      format.html { redirect_to @wiki}
      format.js
    end
  end

  private

  def collaboration_params
    params.require(:collaboration).permit(:user_id, :wiki_id)
  end
end
