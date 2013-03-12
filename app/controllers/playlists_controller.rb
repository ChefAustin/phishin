class PlaylistsController < ApplicationController

  def playlist
    session[:playlist] = [] if params[:clear_playlist] == "1"
    @num_tracks = 0
    @duration = 0
    # raise session[:playlist].inspect
    if session[:playlist]
      tracks_by_id = Track.find(session[:playlist]).index_by(&:id)
      @tracks = session[:playlist].collect {|id| tracks_by_id[id] }
      @num_tracks = @tracks.size
      @duration = @tracks.map(&:duration).inject(0, &:+) if @num_tracks > 0
    end
    render layout: false if request.xhr?
  end
  
  def clear_playlist
    session[:playlist] = []
  end
  
  def reset_playlist
    if track = Track.where(id: params[:track_id]).first
      tracks = Track.where(show_id: track.show_id).order(:position).all
      session[:playlist] = tracks.map(&:id)
      render json: { success: true }
    else
      render json: { success: false }
    end
  end
  
  def update_current_playlist
    session[:playlist] = params[:track_ids].map {|id| Integer(id, 10)}
    render json: { success: true, msg: session[:playlist] }
  end
  
  def add_track_to_playlist
    if session[:playlist].include? Integer(params[:track_id], 10)
      render json: { success: false, msg: 'Track already in playlist'}
    else
      if track = Track.find(params[:track_id])
        session[:playlist] << track.id
        render json: { success: true }   
      else
        render json: { success: false, msg: 'Invalid track provided for playlist' }
      end
    end
  end
  
  def next_track_id
    playlist = session[:playlist]
    idx = false
    playlist.each_with_index { |track_id, i| idx = i if track_id.to_s == params[:track_id].to_s }
    if idx
      if session[:randomize]
        render json: { success: true, track_id: playlist.sample }
      else
        if playlist.last.to_s == params[:track_id]
          if session[:loop]
            render json: { success: true, track_id: playlist.first }
          else
            render json: { success: false, msg: 'End of playlist' }
          end
        else
          render json: { success: true, track_id: playlist[idx+1] }
        end
      end
    else
      render json: { success: false, msg: 'track_id not in playlist' }
    end
  end

  def previous_track_id
    playlist = session[:playlist]
    idx = false
    playlist.each_with_index { |track_id, i| idx = i if track_id.to_s == params[:track_id] }
    if idx
      if session[:randomize]
        render json: { success: true, track_id: playlist.sample }
      else
        if playlist.first.to_s == params[:track_id].to_s
          if session[:loop]
            render json: { success: true, track_id: playlist.last }
          else
            render json: { success: false, msg: 'Beginning of playlist' }
          end
        else
          render json: { success: true, track_id: playlist[idx-1] }
        end
      end
    else
      render json: { success: false, msg: 'track_id not in playlist' }
    end
  end
  
  def track_info
    track = Track.where(id: params[:track_id]).includes(:show => :venue).first
    if track
      render json: {
        success: true,
        title: track.title,
        duration: track.duration,
        show: "#{track.show.date}",
        show_url: "#{track.show.date}",
        venue: "#{track.show.venue.name}",
        venue_url: "/#{track.show.venue.slug}",
        city: track.show.venue.location,
        city_url: "/cities"
      }
    else
      render json: { success: false }
    end
  end
  
  def submit_playlist_options
    params.reject! { |k,v| ! %w[randomize loop].include? k.to_s }
    params[:loop] == "true" ? session[:loop] = true : session[:loop] = false
    params[:randomize] == "true" ? session[:randomize] = true : session[:randomize] = false
    render json: { success: true}
  end
  
end