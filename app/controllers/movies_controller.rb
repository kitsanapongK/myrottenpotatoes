class MoviesController < ApplicationController
  skip_before_action :authenticate!, only: [ :show, :index ,:search_tmdb ,:show_tmdb ,:new ,:all_destroy ,:edit ,:destroy ,:create,:create_from_search_movies]
    def index
      @movies = Movie.all.order('title')
    end

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      @sum=0
      @movie.reviews.all.each do |review|
        @sum = @sum+review.potatoes
      end
      @sum=@sum/@movie.reviews.count if @movie.reviews.count != 0
      render(:partial => 'movie', :object => @movie) if request.xhr?
      # will render app/views/movies/show.html.haml by default
    end

    def new
      if set_current_user
        @movie = Movie.new
      else
        flash[:warning] = "Please log in before create action"
        redirect_to movies_path
      end
    end

    def create
      if set_current_user
        @para=params.require(:movie)
        if Movie.exists?(:title => @para[:title],:description => @para[:description]) == false
          permitted = params[:movie].permit(:title,:rating,:release_date,:description)
          @movie = Movie.create!(permitted)
          #@movie.avatar.attach(params[:avatar]
          flash[:notice] = "#{@movie.title} was successfully created."
          redirect_to movie_path(@movie)
        else
          @movie= Movie.find_by(:title=> @para[:title])
          flash[:warning] = "#{@movie.title} was already existed."
          redirect_to movies_path
        end
      else
        flash[:warning] = "Please login before create action."
        redirect_to movies_path
      end
    end

    def edit
      if set_current_user
        @movie = Movie.find params[:id]
      else
        flash[:warning] = "Please log in before edit action"
        redirect_to movies_path
      end
    end

    def update
      @movie = Movie.find params[:id]
      permitted = params[:movie].permit(:title,:rating,:release_date,:description)
      @movie.update_attributes!(permitted)

      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end

    def destroy
      if set_current_user
        @movie = Movie.find(params[:id])
        @movie.destroy
        flash[:notice] = "Movie '#{@movie.title}' deleted."
        redirect_to movies_path
      else
        flash[:warning] = "Please log in before destroy action"
        redirect_to movies_path
      end
    end

    def all_destroy
      if set_current_user
        Movie.destroy_all
        flash[:notice] = "All Movie deleted."
        redirect_to movies_path
      else
        flash[:warning] = "Please log in before destroy action"
        redirect_to movies_path
      end
    end
    def create_from_search_movies
      if set_current_user
        search_params = params.require(:search_movie)
        @search = Tmdb::Movie.find(search_params)
        @search.each do |movie|
          if Movie.exists?(:title => movie.title,:description => movie.overview) == false
            permitted = {:title => movie.title,:rating =>"G" ,:release_date =>movie.release_date,:description => movie.overview}
            Movie.create!(permitted)
          end
        end
        flash[:notice] = "All movies from searching was successfully created."
        redirect_to movies_path
      else
        flash[:warning] = "Please login before create action."
        redirect_to movies_path
      end
    end  

    def search_tmdb
      @search_params = params[:search_terms]
      @search_params = " " if @search_params  == ""
      @search = Tmdb::Movie.find(@search_params)
      #createa_from_movies(@search)
      if @search != []
        render "search"
      else
        flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb."
        redirect_to movies_path
      end
    end
    
    def show_tmdb
      id = params[:id] # retrieve movie ID from URI route
      @search = Tmdb::Movie.lists(id)
      #render(:partial => 'tmdbmovie', :object => @movie) if request.xhr?
      render "show_tmdb"
    end

  end
