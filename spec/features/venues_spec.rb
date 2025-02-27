# frozen_string_literal: true
require 'rails_helper'

describe 'Venues', :js do
  let!(:a_venue) { create(:venue, :with_shows, name: 'Alpine Valley Music Theater') }
  let(:names) { ['Eagles Ballroom', 'Earlham College', 'Eastbrook Theatre'] }
  let!(:e_venues) do
    names.each_with_object([]) do |name, venues|
      venues << create(:venue, :with_shows, name:)
    end
  end
  let(:venue1) { e_venues.first }
  let(:venue2) { e_venues.second }
  let(:venue3) { e_venues.third }

  before do
    create_list(:show, 2, venue: venue1)
    create_list(:show, 3, venue: venue3)
  end

  it 'visit Venues page' do
    visit venues_path

    within('#title_box') do
      expect_content("'A' Venues", 'Total: 1')
    end

    within('#sub_nav') do
      expect_content('ABCDEFGHIJKLMNOPQRSTUVWXYZ#')
    end

    within('#content_box') do
      expect_content(a_venue.name)
    end

    # Click on 'G'
    within('#sub_nav') do
      click_link('E')
    end

    within('#title_box') do
      expect_content("'E' Venues", "Total: #{e_venues.count}")
    end

    within('#content_box') do
      expect_content(*names)
    end

    # Click on first venue
    first('ul.item_list li h2 a').click
    expect(page).to have_current_path("/#{e_venues.first.slug}")
  end

  it 'Venue sorting' do
    visit venues_path(char: 'E')
    sleep(1)

    expect_content_in_order('Eagles', 'Earlham')

    # Default sort by Name
    within('#title_box') do
      expect_content('Sort by', 'Name')
    end
    expect_content_in_order([venue1, venue2, venue3].map(&:name))

    # Sort by Track Count
    within('#title_box') do
      first('.btn-group').click
      click_link('Show Count')
      expect_content('Sort by', 'Show Count')
    end
    expect_content_in_order([venue3, venue1, venue2].map(&:name))
  end
end
