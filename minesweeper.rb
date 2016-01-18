class Board

  def initialize(size, mines)
    @my_size = size
    @my_num_mines = mines
    @my_board = Array.new(@my_size){ |row| Array.new(@my_size) { |col| Cell.new(row,col) } }
    @num_revealed = 0
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

    # remove hanging new line
    string[0,string.length-1]
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
    if cell.revealed?
      return "You've already looked there!"
    end

    # use a stack of cells we need to reveal
    # tried using more elegant recursion but stack got too deep for large, empty boards
    # changed to iterative instead
    cells = [cell]

    while !cells.empty?
      cell = cells.pop
      if cell.revealed?
        next # skip this neighbor since it was revealed by another cell already
      end

      cell.reveal
      @num_revealed += 1

      if cell.mine?
        return "Game over"
      end

      # if this cell has no mines next to it, also reveal any non-revealed neighbor cells
      if cell.value == 0
        neighbors_to(cell.row, cell.col).each do |neighbor|
          unless neighbor.mine? || neighbor.revealed?
            cells.push(neighbor)
          end
        end
      end
    end

    # Player wins when all cells except the mine cells have been revealed
    if @num_revealed == (size * size) - num_mines
      return "Congratulations! You win!"
    end

    "\n"
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


puts "Welcome to Minesweeper!"

# if we want to play again after the game
play_again = "y"

while play_again == "y"
  puts "Please enter the size of the board you want to play:"
  size = gets.chomp

  while (size =~ /^\d+$/).nil? || (size.to_i <= 0)
    puts "You need to type a positive integer (e.g. 10):"
    size = gets.chomp
  end

  size = size.to_i

  puts "How many mines do you want to have?"
  mines = gets.chomp

  while true
    if (mines =~ /^\d+$/).nil?
      puts "You need to type a positive integer (e.g. 10):"
      mines = gets.chomp
    elsif mines.to_i > (size * size) - 1
      puts "You need fewer mines than spaces on the board!"
      mines = gets.chomp
    else
      break
    end
  end

  mines = mines.to_i

  board = Board.new(size, mines)

  while true
    puts ""
    border = ""
    size.times { border += "-" }
    puts border
    puts "#{board.print_board}"
    puts border
    puts ""
    puts "Type a row and a column to reveal (row,column):"
    pos = gets.chomp

    while true
      if (pos =~ /^\d+,\s*\d+$/).nil?
        puts "Please type in a valid row,column pair"
        pos = gets.chomp
      elsif pos.split(',').map(&:to_i).any? {|num| num > size}
        puts "Your values must be on the board"
        pos = gets.chomp
      else
        pos = pos.split(',').map(&:to_i)
        break
      end
    end

    message = board.reveal(pos[0]-1, pos[1]-1)

    if message == "Game over"
      puts "You hit a mine! Game over!"
      puts "#{board.print_board}"
      break
    elsif message == "Congratulations! You win!"
      puts message
      puts "#{board.print_board}"
      break    
    else
      puts message
    end

  end

  loop do
    puts "Would you like to play again? (y/n)"
    play_again = gets.chomp

    if play_again == "y" || play_again == "n"
      break
    end
  end
end

