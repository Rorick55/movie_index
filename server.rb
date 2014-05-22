require 'sinatra'
require 'csv'
require 'pry'

def movies_array
  movies =[]
  CSV.foreach('movies.csv', headers: true) do |row|
    movie = {
      id: row["id"],
      title: row["title"],
      year: row["year"],
      synopsis: row["synopsis"],
      rating: row["rating"],
      genre: row["genre"],
      studio: row["studio"]
    }
    movies << movie
  end
  movies
end

def get_20_movies (page_number, all_movies)
  index = (page_number -1) * 20
  all_movies[index..index + 19]
end


get '/' do
  redirect '/movies'
end

get '/movies' do
  @page_number = params[:page] || 1

    @return_page = @page_number.to_i - 1

  @movies = get_20_movies(@page_number.to_i, movies_array)
  @page_number = @page_number.to_i + 1

  erb :movies
end

get '/:title/:id' do
  @movies = movies_array
  @movies.find do |each_hash|
    each_hash[:title] == params[:title]
    each_hash[:id] == params[:id]
  end
  erb :id
end

get '/search' do
  movie_hash = movies_array
  @movies = []
   movie_hash.each do |movie|

    if movie[:title].downcase.include? params['query'].downcase
     @movies << movie
    end

end

erb :search
end

