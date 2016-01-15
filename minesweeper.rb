puts "What is your name?"
STDOUT.flush
s = gets.chomp

puts "Your name is " + s



class Board

  def initialize(size, mines)
    @my_size = size
    @my_num_mines = mines
    @my_board = Array.new(@my_size){ |row| Array.new(@my_size) { |col| Cell.new(row,col) } }
    place_mines()
  end


  def print_board(user = true)
    string = ""
    @my_board.each do |row|
      row.each do |cell|
        if user
          string += cell.user_to_s
        else
          string += cell.to_s
        end
      end
      string += "\n"
    end
    puts string
  end

  def size
    @my_size
  end

  def num_mines
    @my_num_mines
  end

  def board
    @my_board
  end

  def cell(row,col)
    board[row][col]
  end

  def reveal(row,col)
    cell = cell(row,col)
    cell.reveal

    if cell.mine?
      puts "Game over"
    end

    if cell.value == 0
      # reveal all neighbors that aren't mines
      neighbors_to(row,col).each do |neighbor|
        unless neighbor.mine? || neighbor.revealed?
          reveal(adj_row, adj_col)
        end
      end
    end
  end


  private
  def place_mines
    # nums = [*0..(@my_size*@my_size-1)]
    # nums.sample(@my_num_mines).each do |num|
      # row = num / @my_size
      # col = num % @my_size
    @my_num_mines.times do |num|
      row = -1
      col = -1
      loop do
        row = rand(@my_size)
        col = rand(@my_size)
        break if !cell(row, col).mine?
      end

      board[row][col] = Cell.new(row, col, mine = true)
      
      puts neighbors_to(row,col).inspect
      #increment neighboring empty cells
      neighbors_to(row,col).each do |neighbor|
        unless neighbor.mine?
          neighbor.increment_value
        end
      end
    end
  end

  def on_board?(row,col)
    row >= 0 && row < @my_size && col >= 0 && col < @my_size
  end

  def neighbors_to(row,col)
    neighbors = []
    (-1..1).each do |drow|
      (-1..1).each do |dcol|
        neighbor_row = row + drow
        neighbor_col = col + dcol
        if on_board?(neighbor_row, neighbor_col) && (neighbor_row != row || neighbor_col != col)
          neighbors << cell(neighbor_row, neighbor_col)
        end
      end
    end
    neighbors
  end

end

class Cell

  def initialize( row, col, mine = false)
    # @my_board = board
    @my_row = row
    @my_col = col
    # @my_neighbors = []
    # find_neighbors

    if mine
      @value = "M"
    else
      @value = 0
    end
    @revealed = false
  end

  def mine?
    @value == "M"
  end

  def revealed?
    @revealed
  end

  def board
    @my_board
  end

  def row
    @my_row
  end

  def col
    @my_col
  end

  def neighbors
    @my_neighbors
  end

  def reveal
    @revealed = true
  end

  def value
    @value
  end

  def increment_value
    @value += 1
  end


  def user_to_s
    if revealed?
      @value.to_s
    else
      "X"
    end
  end

  def to_s
    @value.to_s
  end

  private
  def find_neighbors
    (-1..1).each do |drow|
      (-1..1).each do |dcol|
        neighbor_row = row + drow
        neighbor_col = col + dcol
        if board.on_board?(neighbor_row, neighbor_col) && neighbor_row != row && neighbor_col != col
          @my_neighbors << board.cell(neighbor_row, neighbor_col)
        end
      end
    end
  end
  
end



