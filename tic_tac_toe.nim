import sequtils, tables, strutils, strformat, random, os, parseopt

randomize()

let nextPlayer = {"X":"O", "O":"X"}.toTable

type
    Board = ref object of RootObj
        list: seq[string]

# Winning combinations
let wins = @[ @[0,1,2], @[3,4,5], @[6,7,8], @[0, 3, 6], @[1,4,7], @[2,5,8], @[0,4,8], @[2,4,6] ]

proc newBoard(): Board =
    var b  = Board()
    b.list = @["0", "1", "2", "3", "4", "5", "6", "7", "8"]
    return b

proc done(this: Board): (bool, string) =
    # Check if there are 3 of the same type in a row, then if its X or O that player wins.
    for w in wins:
        if this.list[w[0]] == this.list[w[1]] and this.list[w[1]]  == this.list[w[2]]:
            if this.list[w[0]] == "X":
                return (true, "X")
            elif this.list[w[0]] == "O":
                return (true, "O")
    # If all the elements on the board are etiher X or O then its a stalemate.            
    if all(this.list, proc(x:string):bool = x in @["O", "X"]) == true:
        return (true, "tie")
    else:
        return (false, "going")

proc `$`(this:Board): string =
    let rows: seq[seq[string]] = @[this.list[0..2], this.list[3..5], this.list[6..8]]
    for x, row  in rows:
        for y, cell in row:
            stdout.write(cell)
            if y < 2: stdout.write(" | ")
        if x < 2: echo("\n----------")

# This method returns the empty spaces on the board (they contain an integer)
proc emptySpots(this:Board):seq[int] =
    var emptyindices = newSeq[int]()
    for i in this.list:
        if i.isDigit():
            emptyindices.add(parseInt(i))
    return emptyindices

type 
    Move = tuple[score: int, pos: int]

proc `<` (a, b: Move): bool =
    return a.score < b.score

type
    Game = ref object of RootObj
        currentPlayer*: string
        board*: Board
        aiPlayer*: string
        difficulty*: int


proc newGame(aiPlayer:string="", difficulty:int=9): Game =
    var game = new Game

    game.board = newBoard()
    game.currentPlayer = "X"
    game.aiPlayer = aiPlayer
    game.difficulty = difficulty # 9 is the hardest 1 the easiest

    return game

    # 0 1 2
    # 3 4 5
    # 6 7 8 

proc changePlayer(this:Game) : void =
    this.currentPlayer = nextPlayer[this.currentPlayer]

proc getBestMove(this: Game, board: Board, player: string): Move =

    let (done, winner) = board.done()

    if done:
        if winner == this.aiPlayer:
            return (score: 10, pos: 0)
        elif winner != "tie":
            return (score: -10, pos: 0)
        else:
            return (score: 0, pos: 0)
    
    let emptySpots = board.emptySpots()
    var moves = newSeq[Move]()

    for pos in emptySpots:
        # Create a new board
        var newBoard = newBoard()
        # Copy the current state of the board
        newboard.list = map(board.list, proc(x:string):string=x)
        # Add a move on the next empty spot
        newBoard.list[pos] = player
        # Call this method recursively on the current move changing the player
        let score = this.getBestMove(newBoard, nextPlayer[player]).score
        let pos = pos
        let move = (score:score, pos:pos)
        moves.add(move)

    if player == this.aiPlayer:
        return max(moves)
    else:
        return min(moves)

proc startGame*(this:Game): void=
    while true:
        echo this.board
        if this.aiPlayer != this.currentPlayer:
            stdout.write("Player " & this.currentPlayer & " enter your move: ")
            let move = stdin.readLine()
            this.board.list[parseInt($move)] = this.currentPlayer
        else:
            if this.currentPlayer == this.aiPlayer:
                echo "AI player turn!"
                let currentEmptySpots = this.board.emptySpots()
                
                if len(currentEmptySpots) <= this.difficulty:
                    echo "AI move!"
                    let move = getBestMove(this, this.board, this.aiPlayer)
                    this.board.list[move.pos] = this.aiPlayer
                else:
                    # Do a random move on an empty spot.
                    echo "Random move!"
                    this.board.list[currentEmptySpots.rand()] = this.aiPlayer
            
            
        this.changePlayer()
        let (done, winner) = this.board.done()
        
        if done:
            echo this.board
            if winner == "tie":
                echo ("TIE!")
            else:
                echo("The winner is: ", winner," !")
            break;

proc writeHelp() =
    echo """
    Tic Tac Toe 0.1.0 (MinMax version)
    Arguments:
      -h | --help    : This screen
      -a | --ai      : AI player [X or O]
      -l | --level   : Difficulty level 9 (High) to 0 (Low)
    """

proc cli*() =
    var 
        aiplayer = ""
        difficulty = 9

    for kind, key, val in getopt():
        case kind
        of cmdArgument, cmdLongOption, cmdShortOption:
            case key 
            of "help", "h":
                writeHelp()
                return
            of "aiplayer", "a":
                echo "AI Player: " & val
                aiplayer = val
            of "level", "l":
                difficulty = parseInt(val)
            else:
                discard
        else:
            discard

    let g = newGame(aiPlayer, difficulty)
    g.startGame()   

when isMainModule:
    cli()