require 'sinatra'
require 'sinatra/reloader' if development?

enable :sessions


get '/' do

  message = 'Welcome to Hangman'
  session[:game] = HangmanGame.new if (session[:game].nil? or session[:game].game_over)
  guess = params['guess'].to_s.upcase
  message = ''
  message += session[:game].play(guess) if guess.nil? == false
  message += session[:game].display_status
  locals = { :message => message }
  erb :index, :locals => locals
end

class HangmanGame
  attr_accessor :chances, :letters_guessed, :word, :game_over

  def initialize
    @chances = 8
    @file_path = '5desk.txt'
    @letters_guessed = []
    if @word.nil?
      @word = get_a_word
    end
    @game_over = false
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
    message = "\n\n"
    message += "<p>Letters guessed: #{@letters_guessed.join(' ').to_s}</p>"
    display_word = ''
    @word.split('').each do |x|
      if @letters_guessed.any?(x)
        display_word = display_word + ' ' + x
      else
        display_word = display_word + ' _'
      end
    end
    message += display_word
    message += "<p>Remaining Chances: #{@chances}</p>"
  end

  def play(guess)
    message = ''
    if @chances > 0
      if guess.length > 1
        message += "<p>You're guessing the word! #{guess}</p>"
        if guess == @word
          message += "<p>You got it!</p>"
          @game_over = true
        else
          message += "<p>You didn't get it!</p>"
        end
      else
        message += "<p>Your guess was #{guess}</p>"
        if @letters_guessed.any?(guess)
          message += "<p>You already guessed #{guess}</p>"
        else
          if (@word.split('').any?(guess))
            message += "<p>You got one!</p>"
          else
            message += "<p>Miss</p>"
          end
          @letters_guessed << guess
        end
      end
      @chances -= 1
    else
      message += "<p>The word was #{@word}.</p>"
      @game_over = true
    end
    return message
  end
end