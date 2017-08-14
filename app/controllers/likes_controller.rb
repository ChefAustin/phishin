class LikesController < ApplicationController
  before_filter :authorize_user!
  before_filter :require_xhr!

  def toggle_like
    if (likable = find_likable)
      if (like = likable.likes.where(user_id: current_user.id).first)
        like.destroy
        liked = false
        likes_count = likable.likes_count - 1
      else
        likable.likes.build(user_id: current_user.id).save!
        liked = true
        likes_count = likable.likes_count + 1
      end
      msg = "#{(liked ? 'Like' : 'Unlike')} acknowledged"
      render json: { success: true, msg: msg, liked: liked, likes_count: likes_count }
    else
      render json: { success: false, msg: "Invalid likable object specified (#{params[:likable_type]})" }
    end
  rescue
    render json: { success: false, msg: 'Error while acknowledging like' }
  end

  private

  def authorize_user!
    return if current_user
    render json: { success: false, msg: 'You must be signed in to submit Likes' }
  end

  def find_likable
    return unless params[:likable_type] && params[:likable_id]
    params[:likable_type].classify.constantize.where(id: params[:likable_id]).first
  end
end
