# frozen_string_literal: true
class Playlist < ApplicationRecord
  has_many :playlist_tracks, dependent: :destroy
  has_many :tracks, through: :playlist_tracks
  has_many :playlist_bookmarks, dependent: :destroy
  belongs_to :user

  validates :name,
            presence: true,
            format: { with: /\A.{5,50}\z/ },
            uniqueness: true
  validates :slug,
            presence: true,
            format: {
              with: /\A[a-z0-9\-]{5,50}\z/,
              message: 'must be between 5 and 50 lowercase letters, numbers, or dashes'
            },
            uniqueness: true

  def as_json_api
    {
      slug:,
      name:,
      duration:,
      tracks: playlist_tracks.order(:position).map(&:track).map(&:as_json_api),
      updated_at: updated_at.iso8601
    }
  end

  def as_json_api_basic
    {
      slug:,
      name:,
      duration:,
      track_count: playlist_tracks.size,
      updated_at: updated_at.iso8601
    }
  end
end
