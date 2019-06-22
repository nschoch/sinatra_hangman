require 'sinatra'
enable :sessions

message = 'Welcome to Hangman'

get '/' do

  locals = {:message => message }

  erb :index, :locals => locals
end

class HangmanGame

  def initialize
    @chances = 8
    @file_path = '5desk.txt'
    @letters_guessed = []
    load_save
    if @word.nil?
      @word = get_a_word
    end
  end

  def get_a_word(min_length=5, max_length=12)
    dictionary_file = File.open(@file_path, 'r')
    dictionary_words = dictionary_file.readlines
    word = ''
    while word.length < min_length or word.length > max_length
      word = dictionary_words.sample.chomp
    end
    dictionary_file.close
    return word.upcase
  end

  def display_status
    puts "\n\n"
    puts "Letters guessed: #{@letters_guessed.join(' ').to_s}"
    display_word = ''
    @word.split('').each do |x|
      if @letters_guessed.any?(x)
        display_word = display_word + ' ' + x
      else
        display_word = display_word + ' _'
      end
    end
    puts display_word
    puts "Remaining Chances: #{@chances}"
  end

  def play
    display_status

    while @chances > 0
      puts "Guess or quit & save by inputting 'CTRL+C'"
      guess = gets.chomp.upcase
      if guess.length > 1
        puts "You're guessing the word! #{guess}"
        if guess == @word
          puts "You got it!"
          remove_save
          exit
        else
          puts "You didn't get it!"
        end
      else
        puts "Your guess was #{guess}"
        if @letters_guessed.any?(guess)
          puts "You already guessed #{guess}"
        else
          if (@word.split('').any?(guess))
            puts "You got one!"
          else
            puts "Miss"
          end
          @letters_guessed << guess
        end
      end
      @chances -= 1
      save_to_yaml
      display_status
    end

    puts "The word was #{@word}."
    remove_save
  end
end