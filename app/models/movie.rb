class Movie < ActiveRecord::Base
    has_many :reviews
    scope :with_good_reviews, lambda { |threshold|
    Movie.joins(:reviews).group(:movie_id).
      having(['AVG(reviews.potatoes) > ?', threshold.to_i])
    }
    
  
end
