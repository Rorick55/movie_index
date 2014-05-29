require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

def get_20_movies (page_number, all_movies)
  index = (page_number -1) * 20
  all_movies[index..index + 19]
end

get '/' do

  erb :index
end

get '/movies' do
  @page_number = params[:page] || 1
  if @page_number.to_i <= 1
    @return_page = 1
  else
    @return_page = @page_number.to_i - 1
  end
  movies = db_connection do |conn|
    conn.exec("SELECT movies.title, movies.id, movies.year, movies.rating, genres.name AS genre,
      studios.name AS studio, movies.synopsis FROM movies LEFT OUTER JOIN genres ON genres.id = movies.genre_id
      JOIN studios ON studios.id = movies.studio_id ORDER BY movies.title;")
  end
  @movies = get_20_movies(@page_number.to_i, movies.to_a)
  @page_number = @page_number.to_i + 1

  erb :'movies/index'
end

get '/movies/:id' do
  movies = db_connection do |conn|
    conn.exec("SELECT movies.title, movies.id, movies.year, movies.rating, genres.name AS genre,
      studios.name AS studio, movies.synopsis FROM movies LEFT OUTER JOIN genres ON genres.id = movies.genre_id
      LEFT OUTER JOIN studios ON studios.id = movies.studio_id WHERE movies.id = '#{params[:id]}';")
    end
  movie_actors = db_connection do |conn|
    conn.exec("SELECT movies.title, actors.id, actors.name AS actor, cast_members.character
      FROM cast_members JOIN actors ON cast_members.actor_id = actors.id
      JOIN movies ON movies.id = cast_members.movie_id WHERE movies.id = '#{params[:id]}';")
    end
  @actors = movie_actors.to_a
  @movies = movies.to_a
  @movies.find do |each_hash|
    each_hash[:title] == params[:title]
    each_hash[:id] == params[:id]
  end

  erb :'movies/show'
end

get '/actors' do
    @page_number = params[:page] || 1
  if @page_number.to_i <= 1
    @return_page = 1
  else
    @return_page = @page_number.to_i - 1
  end
  actors = db_connection do |conn|
    conn.exec('SELECT name, id FROM actors ORDER BY name;')
  end
  @actors = get_20_movies(@page_number.to_i, actors.to_a)
  @page_number = @page_number.to_i + 1

  erb :'actors/index'
end

get '/actors/:id' do
  actors = db_connection do |conn|
    conn.exec("SELECT actors.name, actors.id, movies.title, movies.id AS movie_id, cast_members.character
      FROM cast_members JOIN actors ON actors.id = cast_members.actor_id JOIN movies
      ON movies.id = cast_members.movie_id WHERE actors.id = '#{params[:id]}';")
  end

    @actors = actors.to_a
    @actors.find do |each_hash|
      each_hash['id'] == params[:id]
    end
  erb :'actors/show'
  end

get '/search/movies' do
  @page_number = params[:page] || 1
  if @page_number.to_i <= 1
    @return_page = 1
  else
    @return_page = @page_number.to_i - 1
  end
    search_movies = params[:query_m]
  movies = db_connection do |conn|
    conn.exec("SELECT title, id FROM movies WHERE title ILIKE '%#{search_movies}%' ORDER BY title;")
  end
    @movies = get_20_movies(@page_number.to_i, movies.to_a)
    @page_number = @page_number.to_i + 1
  erb :'movies/search'
end

get '/search/actors' do
  @page_number = params[:page] || 1
  if @page_number.to_i <= 1
    @return_page = 1
  else
    @return_page = @page_number.to_i - 1
  end
    search_actors = params[:query_a]
  actors = db_connection do |conn|
    conn.exec("SELECT name, id FROM actors WHERE name ILIKE '%#{search_actors}%' ORDER BY name;")
  end
    @actors = get_20_movies(@page_number.to_i, actors.to_a)
    @page_number = @page_number.to_i + 1
  erb :'actors/search'
end


