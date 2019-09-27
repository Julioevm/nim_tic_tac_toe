import sequtils, tables, strutils, strformat, random, os, parseopt2

randomize()

let NEXT_PLAYER = {"X":"O", "O":"X"}.toTable

type
    Board = ref object of RootObj
        list: seq[string]

# Winning combinations
let WINS = @[ @[0,1,2], @[3,4,5], @[6,7,8], @[0, 3, 6], @[1,4,7], @[2,5,8], @[0,4,8], @[2,4,6] ]

proc newBoard(): Board =
    var b  = Board()
    b.list = @["0", "1", "2", "3", "4", "5", "6", "7", "8"]
    return b

proc done(this: Board): (bool, string) =
    # Check if there are 3 of the same type in a row, then if its X or O that player wins.
    for w in WINS:
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
    this.currentPlayer = NEXT_PLAYER[this.currentPlayer]

proc startGame*(this:Game): void=
    while true:
        echo this.board
        if this.aiPlayer != this.currentPlayer:
            stdout.write("Player " & this.currentPlayer & " enter your move: ")
            let move = stdin.readLine()
            this.board.list[parseInt($move)] = this.currentPlayer
        this.changePlayer()
        let (done, winner) = this.board.done()
        
        if done:
            echo this.board
            if winner == "tie":
                echo ("TIE!")
            else:
                echo("The winner is: ", winner," !")
            break;

let g = newGame(aiPlayer="", difficulty=0)
g.startGame()