//: [Previous](@previous)

import SwiftUI

var greeting = "Hello, playground"

//MARK: Helper objects

enum GameResult: String, CaseIterable {
    case win
    case lose
    case draw
    ///won by default like enemy disconnected
    case afkWin
    ///lose by default like player disconnected
    case afkLose

    var isWin: Bool {
        switch self {
        case .win, .afkWin:
            true
        case .lose, .draw, .afkLose:
            false
        }
    }

    var isDefault: Bool {
        switch self {
        case .win, .lose:
            false
        case .draw, .afkWin, .afkLose:
            true
        }
    }

    var applyRewardsDelay: CGFloat {
        switch self {
        case .win, .lose:
            1.5
        case .draw, .afkWin, .afkLose:
            0.3
        }
    }

    var experienceToGain: Int {
        switch self {
        case .win:
            100
        case .lose:
            25
        case .draw:
            10
        case .afkWin:
            10
        case .afkLose:
            1
        }
    }

    var coinsToGain: Int {
        switch self {
        case .win:
            10
        case .lose:
            3
        case .draw:
            2
        case .afkWin:
            2
        case .afkLose:
            0
        }
    }

    var ratingsToGain: Int {
        let winRating = 5
        let loseRating = -2
        switch self {
        case .win:
            return winRating
        case .lose:
            return loseRating
        case .draw:
            return loseRating * (3/2)
        case .afkWin:
            return winRating * (2/winRating)
        case .afkLose:
            return loseRating * 2
        }
    }

    var title: String {
        rawValue.capitalized
    }
}

struct PlayerExperience: Codable {
    private(set) var level: Int = 1
    ///current experience in this level
    private(set) var current: Int = 0
    ///total experience all time
    private(set) var total: Int = 0

    mutating func update(with result: GameResult) {
        let experienceGained = result.experienceToGain
        increaseExperience(by: experienceGained)
    }

    mutating func increaseExperience(by amount: Int) {
        total += amount
        let maxExperienceNeeded = getMaxExperienceNeeded(level: level)
        if current + amount >= maxExperienceNeeded {
            level += 1
            current = current + amount - maxExperienceNeeded
        } else {
            current += amount
        }
    }

    mutating func reset() {
        level = 1
        current = 0
        total = 0
    }

    private func getMaxExperienceNeeded(level: Int = 1) -> Int {
        let baseExp: Int = 100 //experience needed at level 1
        let growthRate = 1.4    // Growth rate for exponential growth
        //Using an exponential max experience growth rate
        let maxExperienceNeeded = Int(Double(baseExp) * pow(growthRate, Double(level - 1)))
        return maxExperienceNeeded
    }
}

struct LogInStats: Codable {
    private(set) var days: Int = 0
    private(set) var currentStreak: Int = 0
    private(set) var longestStreak: Int = 0
    private(set) var updatedAt: Date = Date()

    mutating func incrementDay() {
        days += 1
        currentStreak += 1
        longestStreak = max(longestStreak, currentStreak)
        updatedAt = Date()
    }

    mutating func reset() {
        days = 0
        currentStreak = 0
        longestStreak = 0
        updatedAt = Date()
    }
}

struct WinLoseStats: Codable {
    private(set) var wins: Int = 0
    private(set) var winStreak: Int = 0
    private(set) var longestWinStreak: Int = 0
    private(set) var losses: Int = 0
    private(set) var draws: Int = 0

    mutating func update(with result: GameResult) {
        switch result {
        case .win:
            wins += 1
        case .lose:
            losses += 1
        case .draw:
            draws += 1
        case .afkWin:
            wins += 1
        case .afkLose:
            losses += 1
        }
        //Update streak
        if result.isWin {
            winStreak += 1
            longestWinStreak = max(longestWinStreak, winStreak)
        } else {
            winStreak = 0
        }
    }

    mutating func reset() {
        wins = 0
        winStreak = 0
        longestWinStreak = 0
        losses = 0
        draws = 0
    }
}

//MARK: - Stats Protocol
protocol StatsProtocol: Codable {
    mutating func reset()
}

protocol RatingStatsProtocol: StatsProtocol {
    var rating: Int { get set }

    mutating func updateRatingStats(with result: GameResult)
}

extension RatingStatsProtocol {
    mutating func updateRatingStats(with result: GameResult) {
        rating += result.ratingsToGain
    }

    mutating func reset() {
        rating = 0
    }
}

protocol WinLoseStatsProtocol: StatsProtocol {
    var winLoseStats: WinLoseStats { get set }

    mutating func updateWinLoseStats(with result: GameResult)
}

extension WinLoseStatsProtocol {
    mutating func updateWinLoseStats(with result: GameResult) {
        winLoseStats.update(with: result)
    }

    mutating func reset() {
        winLoseStats.reset()
    }
}

protocol LevelExperienceStatsProtocol: StatsProtocol {
    var experience: PlayerExperience { get set }
    var levelsGained: Int { get set }

    mutating func incrementExperience(by amount: Int)
}

extension LevelExperienceStatsProtocol {
    mutating func incrementExperience(by amount: Int) {
        let currentLevel = experience.level
        experience.increaseExperience(by: amount)
        levelsGained += experience.level - currentLevel
    }

    mutating func reset() {
        experience.reset()
        levelsGained = 0
    }
}

//MARK: - All - Time

protocol StatsFrequencyAllTimeProtocol: RatingStatsProtocol, WinLoseStatsProtocol, LevelExperienceStatsProtocol {
    mutating func update(with result: GameResult)
    mutating func reset()
}

extension StatsFrequencyAllTimeProtocol {
    mutating func reset() {
        rating = 0
        winLoseStats.reset()
        experience.reset()
        levelsGained = 0
    }

    mutating func update(with result: GameResult) {
        updateWinLoseStats(with: result)
        updateRatingStats(with: result)
        incrementExperience(by: result.experienceToGain)
    }
}

class StatsFrequencyAllTime: StatsFrequencyAllTimeProtocol {
    var winLoseStats: WinLoseStats = .init()
    var experience: PlayerExperience = .init()
    var rating: Int = 0
    var levelsGained: Int = 0

    func printValues() {
        print("All Time Stats")
        print("Rating: \(rating)")
        print("WinLoseStats: \(winLoseStats)")
        print("Experience: \(experience) and gained \(levelsGained) levels")
        print("")
    }
}

//MARK: - Weekly

protocol StatsFrequencyWeeklyProtocol: WinLoseStatsProtocol, LevelExperienceStatsProtocol {
    mutating func update(with result: GameResult)
    mutating func reset()
}

extension StatsFrequencyWeeklyProtocol {
    mutating func reset() {
        winLoseStats.reset()
        experience.reset()
        levelsGained = 0
    }

    mutating func update(with result: GameResult) {
        winLoseStats.update(with: result)
        incrementExperience(by: result.experienceToGain)
    }
}

struct StatsFrequencyWeekly: StatsFrequencyWeeklyProtocol {
    var winLoseStats: WinLoseStats = .init()
    var experience: PlayerExperience = .init()
    var levelsGained: Int = 0

    func printValues() {
        print("Weekly Stats")
        print("WinLoseStats: \(winLoseStats)")
        print("Experience: \(experience) and gained \(levelsGained) levels")
        print("")
    }
}

//MARK: - Tests

struct PlayerStats: Codable {
    var allStats = StatsFrequencyAllTime()
    var statsThisWeek = StatsFrequencyWeekly()

    mutating func update(with result: GameResult) {
        allStats.update(with: result)
        statsThisWeek.update(with: result)
    }

    mutating func reset() {
        allStats.reset()
        statsThisWeek.reset()
    }

    func printValues() {
        allStats.printValues()
        statsThisWeek.printValues()
    }
}

func test() {
    var player = PlayerStats()
    let gameResults: [GameResult] = [.win, .win, .lose, .win, .lose, .win]
    var index = 0
    gameResults.forEach {
        print("==============================================================================")
        print("#\(index + 1): Simulating a game with result: \($0)")
        player.update(with: $0)
        player.printValues()
        index += 1
    }

    print("==============================================================================")
    print("RESETTING")
    player.reset()
    player.printValues()
}

test()

struct Mission: Hashable, Identifiable {
    var id: String = UUID().uuidString
    var counter: Int = 0
    var frequency: Frequency = Frequency.allCases.randomElement()!
}

enum Frequency: Int, CaseIterable, Hashable, Identifiable {
    case weekly, monthly, yearly

    var id: String { String(self.rawValue) }
}

//var missionDic: [Frequency: Mission] = [:]
//Frequency.allCases.forEach {
//    missionDic[$0] = .init()
//}

var missions: [Mission] = (0...10).compactMap { _ in .init() }
let frequency: Frequency = .weekly
let numberOfWeeklyMissions: Int = missions.filter { $0.frequency == frequency }.count
print("There are \(numberOfWeeklyMissions) weekly missions")
for index in missions.indices where missions[index].frequency == frequency {
    let mission: Mission = missions[index]
    print("Mission \(mission.id) is in \(index) AND \(missions.firstIndex(where: { $0.id == mission.id }) ?? -1)")
    missions[index].counter += 1
}
print("Missions are: \(missions)")
//: [Next](@next)
