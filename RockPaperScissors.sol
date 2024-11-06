// SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

contract RockPaperScissors {
    enum Move { None, Rock, Paper, Scissors }
    enum GameState { Created, Joined, Committed, Revealed, Finished }
    
    struct Game {
        address player1;
        address player2;
        uint256 betAmount;
        bytes32 commitment1;
        bytes32 commitment2;
        Move move1;
        Move move2;
        GameState state;
    }
    
    mapping(uint256 => Game) public games;
    uint256 public gameCounter;
    uint256 public registrationFee;
    
    constructor(uint256 _registrationFee) {
        registrationFee = _registrationFee;
    }
    
    function createGame(uint256 registrationFee) public payable returns (uint256) {
        require(msg.value == registrationFee, "Must send exact registration fee");
        
        uint256 gameId = gameCounter++;
        games[gameId] = Game({
            player1: msg.sender,
            player2: address(0),
            betAmount: msg.value,
            commitment1: bytes32(0),
            commitment2: bytes32(0),
            move1: Move.None,
            move2: Move.None,
            state: GameState.Created
        });
        
        return gameId;
    }
    
    function joinGame(uint256 gameId) public payable {
        Game storage game = games[gameId];
        require(game.state == GameState.Created, "Game not available");
        require(msg.value == game.betAmount, "Must match bet amount");
        require(msg.sender != game.player1, "Cannot play against yourself");
        
        game.player2 = msg.sender;
        game.state = GameState.Joined;
    }
    
    function commitMove(uint256 gameId, bytes32 commitment) public {
        Game storage game = games[gameId];
        require(game.state == GameState.Joined || game.state == GameState.Committed, "Invalid game state");
        require(msg.sender == game.player1 || msg.sender == game.player2, "Not a player");
        
        if (msg.sender == game.player1) {
            require(game.commitment1 == bytes32(0), "Already committed");
            game.commitment1 = commitment;
        } else {
            require(game.commitment2 == bytes32(0), "Already committed");
            game.commitment2 = commitment;
        }
        
        if (game.commitment1 != bytes32(0) && game.commitment2 != bytes32(0)) {
            game.state = GameState.Committed;
        }
    }
    
    function revealMove(uint256 gameId, Move move, bytes32 salt) public {
        Game storage game = games[gameId];
        require(game.state == GameState.Committed, "Not in reveal phase");
        require(msg.sender == game.player1 || msg.sender == game.player2, "Not a player");
        
        bytes32 commitment = keccak256(abi.encodePacked(move, salt));
        
        if (msg.sender == game.player1) {
            require(commitment == game.commitment1, "Invalid move");
            game.move1 = move;
        } else {
            require(commitment == game.commitment2, "Invalid move");
            game.move2 = move;
        }
        
        if (game.move1 != Move.None && game.move2 != Move.None) {
            game.state = GameState.Revealed;
            determineWinner(gameId);
        }
    }
    
    function determineWinner(uint256 gameId) internal {
        Game storage game = games[gameId];
        require(game.state == GameState.Revealed, "Game not revealed");
        
        address winner;
        if (game.move1 == game.move2) {
            // Draw - return funds to both players
            payable(game.player1).transfer(game.betAmount);
            payable(game.player2).transfer(game.betAmount);
        } else if (
            (game.move1 == Move.Rock && game.move2 == Move.Scissors) ||
            (game.move1 == Move.Paper && game.move2 == Move.Rock) ||
            (game.move1 == Move.Scissors && game.move2 == Move.Paper)
        ) {
            // Player 1 wins
            payable(game.player1).transfer(game.betAmount * 2);
            winner = game.player1;
        } else {
            // Player 2 wins
            payable(game.player2).transfer(game.betAmount * 2);
            winner = game.player2;
        }
        
        game.state = GameState.Finished;
    }
    
    function getGameState(uint256 gameId) public view returns (
        address player1,
        address player2,
        uint256 betAmount,
        GameState state
    ) {
        Game storage game = games[gameId];
        return (game.player1, game.player2, game.betAmount, game.state);
    }
}