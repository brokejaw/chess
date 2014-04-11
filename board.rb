class Board
  attr_accessor :piece

  UNICODE = {
    "whiteKing" => "\u2654",
    "whiteQueen" => "\u2655",
    "whiteRook" => "\u2656",
    "whiteBishop" => "\u2657",
    "whiteKnight" => "\u2658",
    "whitePawn" => "\u2659",
    "blackKing" => "\u265A",
    "blackQueen" => "\u265B",
    "blackRook" => "\u265C",
    "blackBishop" => "\u265D",
    "blackKnight" => "\u265E",
    "blackPawn" => "\u265F"
  }

  def initialize(populate=true)
    @board = Array.new(8) { Array.new(8, nil) }
    populate_board if populate
  end

  def [](pos)
    @board[pos.first][pos.last]
  end

  def []=(pos, value)
    @board[pos.first][pos.last] = value
  end

  def populate_board
    populate_black_side("black", 0)
    populate_white_side("white", 7)
  end

  def populate_black_side(color, row)
    back_row = [
      Rook.new(color, [row, 0], self),
      Knight.new(color, [row, 1], self),
      Bishop.new(color, [row, 2], self),
      Queen.new(color, [row, 3], self),
      King.new(color, [row, 4], self),
      Bishop.new(color, [row, 5], self),
      Knight.new(color, [row, 6], self),
      Rook.new(color, [row, 7], self)
    ]
    second_row = []

    1.times do |row|
      8.times do |col|
        second_row << Pawn.new(color, [1, col], self)
      end
    end

    @board[0], @board[1] = back_row, second_row
  end

  def populate_white_side(color, row)
    back_row = [
      Rook.new(color, [row, 0], self),
      Knight.new(color, [row, 1], self),
      Bishop.new(color, [row, 2], self),
      Queen.new(color, [row, 4], self),
      King.new(color, [row, 3], self),
      Bishop.new(color, [row, 5], self),
      Knight.new(color, [row, 6], self),
      Rook.new(color, [row, 7], self)
    ]
    second_row = []

    1.times do |row|
      8.times do |col|
        second_row << Pawn.new(color, [6, col], self)
      end
    end

    @board[7], @board[6] = back_row, second_row
  end

  def print_board
    print " "
    8.times { |col| print " #{col} " }
    puts

    8.times do |row|
      print "#{row}"
      8.times do |col|
        piece = @board[row][col]
        if piece.nil?
          print " * "
        else
          print " #{UNICODE[@board[row][col].name]} "
        end
      end
      puts
    end
  end

  def position_available?(color, move)
    return true if @board[move.first][move.last].nil?
    return true if @board[move.first][move.last].color != color
    false
  end

  def in_check?(color, duped_board)
    king_position = find_king(color, duped_board)
    danger_moves = find_opponent_moves(color, duped_board)
    return true if danger_moves.include?(king_position)
    false
  end

  def find_opponent_moves(color, duped_board)
    opponent_moves = []

    duped_board.each do |row|
      row.each do |el|
        unless el.nil?
          if el.color != color
            if el.is_a?(Pawn)
              opponent_moves += el.kill_moves
            else
              opponent_moves += el.moves
            end
          end
        end
      end
    end
    opponent_moves.uniq
  end

  def find_king(color, duped_board)
    king_position = []

   duped_board.each do |row|
     row.each do |el|
       king_position += el.position if el.is_a?(King) && el.color == color
     end
   end

   king_position
  end

  def move(start, end_pos)
    if valid?(start, end_pos)
      if @board[start.first][start.last].moves.include?(end_pos)
        @board[start.first][start.last].position = [end_pos.first,end_pos.last]
        @board[end_pos.first][end_pos.last] = @board[start.first][start.last]
        @board[start.first][start.last] = nil
      else
        raise "Ohhh noes"
      end
    end
  end

  def hypo_move(start, end_pos, dup_board)
    if dup_board[[start.first, start.last]].moves.include?(end_pos)
      dup_board[[start.first, start.last]].position = [end_pos.first,end_pos.last]
      dup_board[[end_pos.first, end_pos.last]] = dup_board[[start.first, start.last]]
      dup_board[[start.first,start.last]] = nil
    else
      raise "Ohhh noes"
    end
  end

  def valid?(start, end_pos)
    duped_board = dup
    hypo_move(start, end_pos, duped_board)
    return true unless in_check?(duped_board[[start, end_pos]].color, duped_board)
    false
  end

  def dup
    duped_board = Board.new(false)

    @board.each_with_index do |row, row_index|
      row.each_with_index do |piece, column_index|
        next if piece.nil?
        duped_piece = piece.dup

        duped_piece.board = duped_board

        duped_board[[row_index,column_index]] = duped_piece
      end
    end

    duped_board
  end
end

#find_opponent_moves