require 'debugger'

class Piece
  attr_accessor :color, :position, :board, :name

  CARDINAL_MOVES = [[0, 1],[0, -1],[1, 0],[-1, 0]]
  DIAGONAL_MOVES = [[1, 1], [-1, -1], [-1, 1], [1, -1]]
  KNIGHT_MOVES = [[1, 2], [1, -2], [2, 1], [2, -1],[-1, 2], [-1, -2], [-2, 1], [-2, -1]]
  WHITE_PAWN_MOVES = [[-1,0],[-1,-1],[-1, 1]]
  BLACK_PAWN_MOVES = [[1, 0],[1, -1],[1, 1]]

  def initialize(color, position, board)
    @color = color
    @position = position
    @board = board
  end

  def name
    "#{color}#{self.class}"
  end

  def on_board?(move)
    return false unless move.first > -1 &&
                        move.first < 8 &&
                        move.last > -1 &&
                        move.last < 8
    return true
  end

  def dup
    self.class.new(self.color, self.position.dup, self.board)
  end
end

class SlidingPiece < Piece
  def moves
    poss_moves = []

    self.directions.each do |diagonal_move|
      each_possible_direction_array = []
      next_move = [(diagonal_move[0]+ @position[0]), (diagonal_move[1]+ @position[1])]

      next unless @board.position_available?(self.color, next_move)

        while on_board?(next_move) && @board.position_available?(self.color, next_move)

          each_possible_direction_array += next_move
          next_move = next_move.dup

          next_move[0] += diagonal_move[0]
          next_move[1] += diagonal_move[1]
        end

       poss_moves += each_possible_direction_array
       # foo = true if nextis not avail
    end

    poss_moves
    # next if foo = true
  end
end

class SteppingPiece < Piece #should work

  def moves
    poss_moves = []
    self.directions.each do |move|
      next_move = [(move[0]+ @position[0]), (move[1]+ @position[1])]
      if on_board?(next_move)
        if @board.position_available?(self.color, next_move)
          poss_moves << next_move
        end
      end
    end
    poss_moves
  end

  def directions
    raise "not implemented"
  end
end

class King < SteppingPiece

  def directions
    CARDINAL_MOVES + DIAGONAL_MOVES
  end
end

class Knight < SteppingPiece

  def directions
   KNIGHT_MOVES
  end
end

class Bishop < SlidingPiece

  def directions
    DIAGONAL_MOVES
  end
end

class Rook < SlidingPiece

  def directions
    CARDINAL_MOVES
  end
end

class Queen < SlidingPiece

  def directions
    DIAGONAL_MOVES + CARDINAL_MOVES
  end
end

class Pawn < Piece
  attr_accessor :moved

  def initialize(color, position, board, moved = false )
    super(color, position, board)
    @moved = moved
  end

  def directions
    pawn_array = self.color == "black" ? BLACK_PAWN_MOVES : WHITE_PAWN_MOVES
    addition = self.color == "black" ? [2, 0] : [-2, 0]

    pawn_array << addition unless @moved

    pawn_array
  end

  def moves
    poss_moves = []

    self.directions.each do |move|
      next_move = [(move[0]+ @position[0]), (move[1] + @position[1])]

      if on_board?(next_move)
        if next_move.last != @position.last
          if !@board[next_move].nil?
            if @board[next_move].color != self.color
              poss_moves << next_move
            end
          end
        else
          if @board[next_move].nil?
            temp_var = next_move.first - @position.first
            if temp_var == 2
              if self.color == "black"
                poss_moves << next_move if @board[[@position.first+1, 0]].nil?
              else
                poss_moves << next_move if @board[[@position.first-1, 0]].nil?
              end
            else
              poss_moves << next_move if @board[next_move].nil?
            end
          end
        end
      end
    end

    poss_moves
  end

  def kill_moves
    killer_moves = []
    self.directions.each do |move|
      next_move = [(move[0]+ @position[0]), (move[1] + @position[1])]

      if on_board?(next_move)
        if next_move.last != @position.last
          if @board[next_move].nil?
              killer_moves << next_move
          end
        end
      end
    end
    killer_moves
  end
end




























