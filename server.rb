require 'sinatra'
require_relative 'movie_methods'
require 'pry'




get '/' do

  erb :index
end


get '/movies' do
  @page_number = params[:page] || 1
  start = (@page_number.to_i - 1) * 20
  @return_page = return_page(@page_number)
  @movies = all_movies(start)
  @page_number = @page_number.to_i + 1

  erb :'movies/index'
end

get '/movies/:id' do
  @actors = movie_cast(params[:id])
  @movies = single_movie(params[:id])
  @movies.find do |each_hash|
    each_hash[:title] == params[:title]
    each_hash[:id] == params[:id]
  end

  erb :'movies/show'
end

get '/actors' do
  @page_number = params[:page] || 1
  start = (@page_number.to_i - 1) * 20
  @return_page = return_page(@page_number)
  @actors = all_actors(start)
  @page_number = @page_number.to_i + 1

  erb :'actors/index'
end

get '/actors/:id' do
    @actor = single_actor(params[:id])
    @actor.find do |each_hash|
      each_hash['id'] == params[:id]
    end
  erb :'actors/show'
end

get '/search/movies' do
  @page_number = params[:page] || 1
    start = (@page_number.to_i - 1) * 20
    @return_page = return_page(@page_number)
    search_movies = params[:query_m]
    @movies = movie_search(search_movies, start)
    @page_number = @page_number.to_i + 1
  erb :'movies/search'
end

get '/search/actors' do
  @page_number = params[:page] || 1
    start = (@page_number.to_i - 1) * 20
  @return_page = return_page(@page_number)
    search_actors = params[:query_a]
    @actors = actor_search(search_actors, start)
    @page_number = @page_number.to_i + 1
  erb :'actors/search'
end


