# This is my spaghetti code for codecademy's movie database challenge.
# I recognize a lot of practices in here are likely very bad, but I was working through the codecademy Ruby track,
# and I felt like I knew enough to tackle making a smallish project like this. There are likely many cases where things will break terribly.
# :)

system(ls)
$movies = Hash.new{"No Movies Yet"}

$test_hash = {
  big_time_rush: 6,
  avatar_2: 9,
  the_lord_of_the_rings: 4,
  spongebob_the_move: 10,
  the_addams_family: 3,
  madagascar: 10,
  the_incredibles: 3,
  wacky_adventure_time: 8,
  gone_to_bed: 9,
  scream_2: 3,
  game_of_thrones: 3,
  breaking_bad: 9
}

def get_user_input_movie(action = "Adding", title = :default)
  case action
    when "Adding"
      puts "What is the movie you'd like to add?"
    when "Deleting"
      puts "What is the movie you'd like to delete?"
    when "Updating"
      puts "What is the movie you'd like to update?"
    when "Changing"
      puts "What would you like to change #{format_movie_title(title)} to?"
    else
      puts "I'm on fire how did I get here?!?!"
      return
  end
  return str_to_sym(gets.chomp)
end

def get_user_input_rating(title, updating = false)
  if !updating
    print_statement = "What do you want to rate #{format_movie_title(title)} [1-10]?"
  else
    print_statement = "#{format_movie_title(title)} is currently rated #{$movies[title]}. What would you like to change it to? [1-10]?"
  end

  loop do
    puts print_statement
    user_input = gets.chomp.to_i
    if user_input < 1 || user_input > 10
      puts "Rating scales is from 1-10, please try again!"
    else
      return user_input
    end
  end
end


# Formats movie titles from symbols to strings, and capitalizes every word
# Defaults to not displaying a rating, optional second arg allows for rating to be added
def format_movie_title(title, rating = 0)
  new_title = title.to_s.gsub("_", " ")
  new_title = new_title.split(" ").each{|word| word.capitalize!}.join(" ")

  if rating != 0
    return "#{new_title}, rating: #{rating}"
  else
    return "#{new_title}"
  end
end

# Swaps strings to symbols and follows style rules for symbols
def str_to_sym(str_in)
  str_in.downcase!
  str_in = str_in.gsub(" ", "_")
  str_in = str_in.to_sym
  return str_in
end

# Adds movie to $movies based on user input. Also can be called when updating
def add_movie(movie_title = "", changing_title = true, updating = false)
  
  if changing_title
    movie_title = get_user_input_movie("Adding")
  end

  in_database = compare_title_to_database(movie_title) unless updating
  if in_database && !updating
    print "#{format_movie_title(movie_title)} found in database with rating of #{$movies[movie_title]}. would you like to update? [y/n]"
    user_input = gets.chomp
    user_input.downcase!

    if user_input == 'y'
      title = change_title(movie_title)
      change_rating(title, $movies[title])
      return
    else
      puts "Returning to options..."
      return
    end
  end
  if movie_title != ""
    $movies[movie_title] = get_user_input_rating(movie_title)
  else
    puts "Need a title!"
  end
end

def add_movie_to_database(movie_key, rating, need_title)
  $movies[movie_key] = rating
end

def compare_title_to_database(title_key, debug = false)
  $movies.each_pair do |title, rating|
    puts "Comparing #{title} and #{title_key}" if debug
    if title == title_key
      puts "Found match" if debug
      return true
    end
  end
  puts "Match not found" if debug
  return false
end

def compare_rating_to_database(rating_value, debug = false)
  $movies.each_pair do |title, rating|
    puts "Comparing #{rating} and #{rating_value}" if debug
    if rating == rating_value
      puts "Found match" if debug
      return true
    end
  end
  puts "Match not found" if debug
  return false
end

def update_movie
  movie_to_update = get_user_input_movie("Updating")
  if compare_title_to_database(movie_to_update)
    title = change_title(movie_to_update)
    change_rating(title, $movies[title])
  else
    add_movie_from_update(movie_to_update)
  end
end

def change_title(title_in)
  print "Would you like to change the title of #{format_movie_title(title_in)}? [y/n]: "
  user_input = gets.chomp
  user_input.downcase!

  if user_input == 'y'
    new_movie_title = get_user_input_movie("Changing", title_in)
    $movies[new_movie_title] = $movies.delete title_in
    return new_movie_title
  end
  return title_in
end

def change_rating(title_in, rating_in)
  print "Would you like to change the rating of #{format_movie_title(title_in)}? [y/n]: "
  user_input = gets.chomp
  user_input.downcase!

  if user_input == 'y'
    add_movie(title_in, false, )
    $movies[title_in] = get_user_input_rating(title_in, true)
  end
end

def add_movie_from_update(title_in)
  puts "#{format_movie_title(title_in)} does not exist in our library."
  puts "Would you like to add it? [y/n]"
  user_input = gets.chomp
  user_input.downcase!

  if user_input == 'y'
    add_movie(title_in, false)      
  else
    puts "Returning to options..."
    return
  end
end

def display_movie
  display_hash = get_display_type
  display_hash.each do |title, rating|
    puts format_movie_title(title, rating)
  end
end

def get_display_type
  puts "Sort by alphabetical or rating? [a/r]"
  alphabet_or_rating = gets.chomp
  puts "Sort by 1. ascending (low-to-high) or 2. descending (high-to-low)? [1/2]"
  ascend_or_descend = gets.chomp
  new_hash = Hash.new
  case alphabet_or_rating
    when "a"
      if ascend_or_descend == "2"
        new_hash = $movies.sort.reverse.to_h
      elsif ascend_or_descend == "1"
        new_hash = $movies.sort.to_h
      else
        puts "Error: unable to read chosen sort option. Sorting by default..."
        return $movies
      end
      return new_hash
    when "r"
      if ascend_or_descend == "2"
        new_hash = $movies.sort_by {|title, rating| -rating}
        new_hash = new_hash.to_h
      elsif ascend_or_descend == "1"
        new_hash = $movies.sort_by {|title, rating| rating}
        new_hash = new_hash.to_h
      else
        puts "Error: unable to read chosen sort option. Sorting by default..."
        return $movies
      end
      return new_hash
    else
      puts "Error: unable to read chosen sort option. returning to options..."
      return
  end
end


def delete_movie
  movie_to_delete = get_user_input_movie("Deleting")
  puts "Deleting #{format_movie_title(movie_to_delete)}"
  $movies.delete(movie_to_delete)
end

def end_loop
  puts "Goodbye!"
  exit
end

def get_choice
  choice_arr = []
  puts "What would you like to do?"
  puts "Options: [add][update][display][delete][done]: "
  user_choice = gets.chomp
  user_choice.downcase!
  if user_choice.include? " "
    user_choice.split(" ").each do |word| 
      choice_arr.push(word)
    end
  else
    choice_arr.push(user_choice)
  end
  if choice_arr.length > 1
    choice_arr[1] = choice_arr[1].to_i
  end
  return choice_arr
end


def determine_action(choice, count = 1)
  case choice
    when "add"
      count.times { add_movie }
    when "update"
      count.times { update_movie }
    when "display"
      display_movie
    when "delete"
      count.times { delete_movie }
    when "done"
      end_loop
    when "test"
      puts "Adding test movies to database"
      $test_hash.each { |title, key| $movies[title] = key}
    else
      puts "ERROR!"
  end
end
def main_loop
  loop do 
    user_choice = get_choice
    if user_choice.length > 1
      determine_action(user_choice[0], user_choice[1])
    else
      determine_action(user_choice[0])
    end
  end
end

begin
  main_loop
end
