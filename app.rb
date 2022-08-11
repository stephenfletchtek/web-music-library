require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end

  get '/' do
    erb(:home)
  end

  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all
    erb(:albums)
  end

  get '/albums/new' do
    repo = ArtistRepository.new
    @artists = repo.all
    erb(:albums_new)
  end

  get '/albums/:id' do
    repo = AlbumRepository.new
    artist = ArtistRepository.new
    album = repo.find(params[:id])
    @title = album.title
    @release_year = album.release_year
    @artist = artist.find(album.artist_id).name
    erb(:albums_id)
  end

  post '/albums' do
    if invalid_request_parameters?
      status 400
      return ''
    else
      new_album = Album.new
      new_album.title = params[:title]
      new_album.release_year = params[:release_year]
      new_album.artist_id = params[:artist_id]
      repo = AlbumRepository.new
      repo.create(new_album)
      @confirm = repo.all[-1]
      erb(:album_created)
    end  
  end

  def invalid_request_parameters?
    return params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
  end

  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    erb(:artists)
  end

  get '/artists/new' do
    erb(:artists_new)
  end

  get '/artists/:id' do
    repo = ArtistRepository.new
    @artist = repo.find(params[:id])
    erb(:artists_id)
  end

  post '/artists' do
    if invalid_artist_parameters?
      status 400
      return ''
    else
      new_artist = Artist.new
      new_artist.name = params[:name]
      new_artist.genre = params[:genre]
      repo = ArtistRepository.new
      repo.create(new_artist)
      @new_artist = new_artist
      erb(:artist_created)
    end
  end

  def invalid_artist_parameters?
    return params[:name] == nil || params[:genre] == nil
  end
end