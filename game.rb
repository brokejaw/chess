require './pieces.rb'
require './board.rb'
require 'debugger'

class Game

  attr_accessor :board

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @current_player = @player1
    @board = Board.new
  end
end



# change pawn flag after you place move
# update logic for stepping pieces - only move to available positions
# update logic for sliding pieces - only if path unobstructed

if __FILE__ == $PROGRAM_NAME
  g = Game.new("steve", "eddie")
  g.board.move([1,1], [2,1])
  p board.print_board
end