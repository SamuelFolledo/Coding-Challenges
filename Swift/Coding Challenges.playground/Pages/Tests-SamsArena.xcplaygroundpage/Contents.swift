//: [Previous](@previous)

import Foundation
import XCTest

// Define your Game, Player, and Enemy structs/classes here
// Also define the GameResult enum


// MARK: - Supporting Types

struct Player {
    var hp: Double
    var maxHp: Double
    var isDead: Bool = false
}

enum GameResult: String {
    case win, lose, afkWin, afkLose, draw
}

// MARK: - Game Struct

struct Game {
    var player: Player = Player(hp: 100, maxHp: 100)
    var enemy: Player = Player(hp: 100, maxHp: 100)
    var enemyExited: Bool = false
    var isMaxRound: Bool = false

    func getGameResult() -> GameResult {
        let enemyHpPercent = enemy.hp / enemy.maxHp
        let playerHpPercent = player.hp / player.maxHp
        ///if the enemy's hp is less than  %, and enemy left the game, then user wins
        let lowestHpThreshold = 0.55
        ///If player's hp % + threshold below is greater than enemy's hp, then user wins
        let allowedHpDifferential = 0.1
        let result: GameResult
        if enemy.isDead {
            //player won
            result = .win
        } else if player.isDead {
            //enemy won
            result = .lose
        } else if enemyExited {
            //player won by default
            let isEnemyHpBelowThreshold = enemyHpPercent > lowestHpThreshold
            let isEnemyHpBelowPlayerHp = playerHpPercent + allowedHpDifferential < enemyHpPercent
            result = isEnemyHpBelowThreshold || isEnemyHpBelowPlayerHp ? .afkWin : .win
        } else if isMaxRound {
            result = .draw
        } else {
            print("Player afk and lost the game")
            let isPlayerHpBelowThreshold = playerHpPercent > lowestHpThreshold
            let isPlayerHpBelowEnemyHp = enemyHpPercent + allowedHpDifferential < playerHpPercent
            result = isPlayerHpBelowThreshold || isPlayerHpBelowEnemyHp ? .afkLose : .lose
        }
        print("GAMEOVER RESULT: \(result.rawValue)")
        return result
    }
}

//MARK: - TEST
func runAllTests() {
    var game = Game(player: Player(hp: 100, maxHp: 100), enemy: Player(hp: 100, maxHp: 100))

    func testPlayerWinsWhenEnemyIsDead() {
        game.player.hp = 50
        game.player.maxHp = 100
        game.enemy.hp = 0
        game.enemy.maxHp = 100
        game.enemy.isDead = true
        print("testPlayerWinsWhenEnemyIsDead: \(game.getGameResult()) == .win : \(game.getGameResult() == .win)")
    }

    func testPlayerLosesWhenPlayerIsDead() {
        game.player.hp = 0
        game.player.maxHp = 100
        game.player.isDead = true
        game.enemy.hp = 50
        game.enemy.maxHp = 100
        print("testPlayerLosesWhenPlayerIsDead: \(game.getGameResult()) == .lose : \(game.getGameResult() == .lose)")
    }

    func testPlayerWinsWhenEnemyExitsAndEnemyHpBelowThreshold() {
        game.player.hp = 60
        game.player.maxHp = 100
        game.enemy.hp = 50
        game.enemy.maxHp = 100
        game.enemyExited = true
        print("testPlayerWinsWhenEnemyExitsAndEnemyHpBelowThreshold: \(game.getGameResult()) == .win : \(game.getGameResult() == .win)")
    }

    func testPlayerAfkWinsWhenEnemyExitsAndEnemyHpAboveThreshold() {
        game.player.hp = 60
        game.player.maxHp = 100
        game.enemy.hp = 60
        game.enemy.maxHp = 100
        game.enemyExited = true
        print("testPlayerAfkWinsWhenEnemyExitsAndEnemyHpAboveThreshold: \(game.getGameResult()) == .afkWin : \(game.getGameResult() == .afkWin)")
    }

    func testDrawWhenMaxRoundReached() {
        game.player.hp = 50
        game.player.maxHp = 100
        game.enemy.hp = 50
        game.enemy.maxHp = 100
        game.isMaxRound = true
        print("testDrawWhenMaxRoundReached: \(game.getGameResult()) == .draw : \(game.getGameResult() == .draw)")
    }

    func testPlayerLosesWhenPlayerAfkAndHpBelowThreshold() {
        game.player.hp = 50
        game.player.maxHp = 100
        game.enemy.hp = 60
        game.enemy.maxHp = 100
        game.enemyExited = false
        game.isMaxRound = false
        print("testPlayerLosesWhenPlayerAfkAndHpBelowThreshold: \(game.getGameResult()) == .lose : \(game.getGameResult() == .lose)")
    }

    func testPlayerAfkLosesWhenPlayerAfkAndHpAboveThreshold() {
        game.player.hp = 60
        game.player.maxHp = 100
        game.enemy.hp = 60
        game.enemy.maxHp = 100
        game.enemyExited = false
        game.isMaxRound = false
        print("testPlayerAfkLosesWhenPlayerAfkAndHpAboveThreshold: \(game.getGameResult()) == .afkLose : \(game.getGameResult() == .afkLose)")
    }

    // Call all test methods
    testPlayerWinsWhenEnemyIsDead()
    testPlayerLosesWhenPlayerIsDead()
    testPlayerWinsWhenEnemyExitsAndEnemyHpBelowThreshold()
    testPlayerAfkWinsWhenEnemyExitsAndEnemyHpAboveThreshold()
    testDrawWhenMaxRoundReached()
    testPlayerLosesWhenPlayerAfkAndHpBelowThreshold()
    testPlayerAfkLosesWhenPlayerAfkAndHpAboveThreshold()
}

// Run all tests
runAllTests()

//: [Next](@next)
