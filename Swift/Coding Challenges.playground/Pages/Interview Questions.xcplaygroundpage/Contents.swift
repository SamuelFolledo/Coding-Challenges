//: [Previous](@previous)

import Foundation

/*
 Interview Question with James Fong from Apple's Health team on 2/12/2024
 
 Given an m x n 2D binary grid which represents a map of '1's (land) and '0's (water), return the number of islands.
 An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. You may assume all four edges of the grid are all surrounded by water.

 Note:
 In arr[i][j], i = row (vertical), j = column (horizontal)
 //
 Example 1:
 Input: grid = [
 [1,1,1,1,0],
 [1,1,0,1,0],
 [1,1,0,0,0],
 [0,0,0,0,0]
 ]
 Output: 1
 Example 2:
 Input: grid = [
 [1,1,0,0,0],
 [1,1,0,0,0],
 [0,0,1,0,0],
 [0,0,0,1,1]
 ]
 Output: 3
 */
func getNumberOfIslands(_ grid: [[Int]]) -> Int {
    var islandCounter = 0
    var grid2 = grid
    for x in 0..<grid.count {
        for y in 0..<grid2[x].count {
            let item = grid2[x][y]
            let isLand = item == 1
            if isLand {
                islandCounter += 1
                updateNeighbors(&grid2, x, y)
            }
        }
    }
    return islandCounter
}

func updateNeighbors(_ grid: inout [[Int]] , _ x: Int, _ y: Int) {
    //return if x or y is out of range OR item is water
    if x < 0 || x > grid.count - 1 || y < 0 || y > grid[x].count - 1 ||
        grid[x][y] == 0 {
        return
    }
    grid[x][y] = 0
    updateNeighbors(&grid, x-1, y)
    updateNeighbors(&grid, x+1, y)
    updateNeighbors(&grid, x, y-1)
    updateNeighbors(&grid, x, y+1)
}

let grid = [
    [1,1,1,1,0],
    [1,1,0,1,0],
    [1,1,0,0,0],
    [0,0,0,0,0]
] //Output: 1

let grid2 = [
    [1,1,0,0,0],
    [1,1,0,0,0],
    [0,0,1,0,0],
    [0,0,0,1,1]
] //Output: 3

//print("Number of island for grid1 = \(getNumberOfIslands(grid))")
//print("Number of island for grid2 = \(getNumberOfIslands(grid2))")

class Vehicle {
    var wheels: Int
    var name: String

    init(wheels: Int, name: String) {
        self.wheels = wheels
        self.name = name
    }
}

class Truck: Vehicle {
    var model: String

    init(model: String, wheels: Int, name: String) {
        self.model = model
        super.init(wheels: wheels, name: name)
    }
}

class FordTruck: Truck {
    var color: String
    
    init(color: String, model: String, wheels: Int, name: String) {
        self.color = color
        super.init(model: model, wheels: wheels, name: name)
    }
}

func printTruckDetails(truck: Truck) {
    print("Vehicle name is \(truck.name), wheels \(truck.wheels) and \(truck.model), nad ford")
}

let myTruck = FordTruck.init(color: "blue", model: "echo", wheels: 6, name: "f-pulling truck")
printTruckDetails(truck: myTruck)
myTruck.name = "Ford Truck"
printTruckDetails(truck: myTruck)

func getMaxExperienceNeeded(currentLevel: Int, growthRate: Double = 1.5, growthType: String = "logarithmic") -> Int {
    // Parameters for growth algorithms
    let baseExp = 100       // Base experience required for the first level
    var expIncrement = 50   // Increment value, can be adjusted dynamically
//    let growthRate = 1.5    // Growth rate for exponential growth
    let polynomialDegree = 3 // Degree for polynomial growth

    // Adjust increment dynamically based on the current level
    expIncrement += currentLevel * 5  // Increases increment with level

    // Calculate max experience based on growth type
    switch growthType.lowercased() {
    case "linear":
        return baseExp + (currentLevel - 1) * expIncrement

    case "exponential":
        return Int(Double(baseExp) * pow(growthRate, Double(currentLevel - 1)))

//    case "quadratic":
//        return baseExp + expIncrement * (currentLevel - 1) * (currentLevel - 1)

    case "logarithmic":
        return Int(Double(baseExp) * log(Double(currentLevel) + 1))

//    case "polynomial":
//        return baseExp + Int(pow(Double(currentLevel - 1), Double(polynomialDegree)))

    default:
        print("Invalid growth type. Please use 'linear', 'exponential', 'quadratic', 'logarithmic', or 'polynomial'.")
        return 0
    }
}

// Example usage
let currentLevel = 5
let maxExpToLevelUp = getMaxExperienceNeeded(currentLevel: currentLevel)

//print("Max experience needed to level up from level \(currentLevel): \(maxExpToLevelUp)")
//for level in 1...10 {
//    print("LEVEL \(level) needs exp linear is \(getMaxExperienceNeeded(currentLevel: level, growthType: "linear"))")
//    print("LEVEL \(level) needs exp logarithmic is \(getMaxExperienceNeeded(currentLevel: level))")
//    print("LEVEL \(level) needs exp exponential is \(getMaxExperienceNeeded(currentLevel: level, growthType: "exponential"))")
//    print("LEVEL \(level) needs exp less exponential is \(getMaxExperienceNeeded(currentLevel: level, growthRate: 1.4, growthType: "exponential"))")
//    print("LEVEL \(level) needs exp quadratic is \(getMaxExperienceNeeded(currentLevel: level, growthType: "quadratic"))")
//    print("LEVEL \(level) needs exp polynomial is \(getMaxExperienceNeeded(currentLevel: level, growthType: "polynomial"))")
//    print()
//}

//// Function to calculate new ratings using the Elo rating system
//func calculateNewRatings(userRating: Int, enemyRating: Int, result: String, kFactor: Int = 16) -> (newUserRating: Int, newEnemyRating: Int) {
//    // Convert ratings to Double for calculations
//    let userRatingDouble = Double(userRating)
//    let enemyRatingDouble = Double(enemyRating)
//
//    // Calculate expected scores for both players
//    let expectedUserScore = 1 / (1 + pow(10, (enemyRatingDouble - userRatingDouble) / 400))
//    let expectedEnemyScore = 1 / (1 + pow(10, (userRatingDouble - enemyRatingDouble) / 400))
//
//    // Determine actual score based on the result
//    var userScore: Double = 0.0
//    var enemyScore: Double = 0.0
//
//    switch result.lowercased() {
//    case "win":
//        userScore = 1.0
//        enemyScore = 0.0
//    case "lose":
//        userScore = 0.0
//        enemyScore = 1.0
//    case "tie":
//        userScore = 0.5
//        enemyScore = 0.5
//    default:
//        print("Invalid result. Please use 'win', 'lose', or 'tie'.")
//        return (userRating, enemyRating)  // Return original ratings if the input is invalid
//    }
//
//    // Calculate new ratings
//    let newUserRating = userRatingDouble + Double(kFactor) * (userScore - expectedUserScore)
//    let newEnemyRating = enemyRatingDouble + Double(kFactor) * (enemyScore - expectedEnemyScore)
//
//    // Return new ratings as integers
//    return (Int(round(newUserRating)), Int(round(newEnemyRating)))
//}

//let (newUserRating, newEnemyRating) = calculateNewRatings(userRating: userRating, enemyRating: enemyRating, result: result)

//-------

//func calculateImprovedRatings(userRating: Int, enemyRating: Int, result: String, userGamesPlayed: Int, enemyGamesPlayed: Int) -> (newUserRating: Int, newEnemyRating: Int) {
//    // Convert ratings to Double for calculations
//    let userRatingDouble = Double(userRating)
//    let enemyRatingDouble = Double(enemyRating)
//
//    // Calculate expected scores for both players
//    let expectedUserScore = 1 / (1 + pow(10, (enemyRatingDouble - userRatingDouble) / 400))
//    let expectedEnemyScore = 1 / (1 + pow(10, (userRatingDouble - enemyRatingDouble) / 400))
//
//    // Determine actual score based on the result
//    var userScore: Double = 0.0
//    var enemyScore: Double = 0.0
//
//    switch result.lowercased() {
//    case "win":
//        userScore = 1.0
//        enemyScore = 0.0
//    case "lose":
//        userScore = 0.0
//        enemyScore = 1.0
//    case "tie":
//        userScore = 0.5
//        enemyScore = 0.5
//    default:
//        print("Invalid result. Please use 'win', 'lose', or 'tie'.")
//        return (userRating, enemyRating)  // Return original ratings if the input is invalid
//    }
//
//    // Dynamic K-factor based on games played: higher K for new players, lower K for experienced players
//    let baseKFactor = 32.0
//    let userKFactor = max(10, baseKFactor / sqrt(Double(userGamesPlayed + 1)))
//    let enemyKFactor = max(10, baseKFactor / sqrt(Double(enemyGamesPlayed + 1)))
//
//    // Calculate rating adjustments
//    let userRatingChange = userKFactor * (userScore - expectedUserScore)
//    let enemyRatingChange = enemyKFactor * (enemyScore - expectedEnemyScore)
//
//    // Apply asymmetric scaling based on result and player ratings
//    let newUserRating = userRatingDouble + userRatingChange
//    let newEnemyRating = enemyRatingDouble + enemyRatingChange
//
//    // Return new ratings as integers
//    return (Int(round(newUserRating)), Int(round(newEnemyRating)))
//}
//
//// Example usage
//let userRating = 1600
//let enemyRating = 1500
//let result = "win"
//let userGamesPlayed = 10
//let enemyGamesPlayed = 50
//let (newUserRating, newEnemyRating) = calculateImprovedRatings(userRating: userRating, enemyRating: enemyRating, result: result, userGamesPlayed: userGamesPlayed, enemyGamesPlayed: enemyGamesPlayed)
//
//print("If user \(result == "win" ? "win" : "lose")")
//print("User Rating: from \(userRating) to \(newUserRating)")
//print("Enemy Rating: from \(enemyRating) to \(newEnemyRating)")


//// Function to calculate new ratings using an improved Elo rating system
//func calculateImprovedRatings(userRating: Int, enemyRating: Int, result: String, userGamesPlayed: Int, enemyGamesPlayed: Int) -> (newUserRating: Double, newEnemyRating: Double) {
//    // Convert ratings to Double for calculations
//    let userRatingDouble = Double(userRating)
//    let enemyRatingDouble = Double(enemyRating)
//
//    // Calculate expected scores for both players
//    let expectedUserScore = 1 / (1 + pow(10, (enemyRatingDouble - userRatingDouble) / 400))
//    let expectedEnemyScore = 1 / (1 + pow(10, (userRatingDouble - enemyRatingDouble) / 400))
//
//    // Determine actual score based on the result
//    var userScore: Double = 0.0
//    var enemyScore: Double = 0.0
//
//    switch result.lowercased() {
//    case "win":
//        userScore = 1.0
//        enemyScore = 0.0
//    case "lose":
//        userScore = 0.0
//        enemyScore = 1.0
//    case "tie":
//        userScore = 0.5
//        enemyScore = 0.5
//    default:
//        print("Invalid result. Please use 'win', 'lose', or 'tie'.")
//        return (Double(userRating), Double(enemyRating))  // Return original ratings if the input is invalid
//    }
//
//    // Dynamic K-factor based on games played: higher K for new players, lower K for experienced players
//    let baseKFactor = 12.0
//    let userKFactor = max(10, baseKFactor / sqrt(Double(userGamesPlayed) + 1))
//    let enemyKFactor = max(10, baseKFactor / sqrt(Double(enemyGamesPlayed) + 1))
//
//    // Calculate rating adjustments
//    let userRatingChange = userKFactor * (userScore - expectedUserScore)
//    let enemyRatingChange = enemyKFactor * (enemyScore - expectedEnemyScore)
//
//    // Apply rating changes
//    let newUserRating = userRatingDouble + userRatingChange
//    let newEnemyRating = enemyRatingDouble + enemyRatingChange
//
//    // Return new ratings as integers
//    return (round(Double(newUserRating)), round(Double(newEnemyRating)))
//}

// Enum to represent game results
enum GameResult {
    case win
    case lose
    case tie
    case afkWin
    case afkLose

    var isWin: Bool {
        switch self {
        case .win, .afkWin:
            true
        case .lose, .tie, .afkLose:
            false
        }
    }

    var isDefault: Bool {
        switch self {
        case .win, .lose:
            false
        case .tie, .afkWin, .afkLose:
            true
        }
    }
}

// Function to calculate new ratings using an improved Elo rating system
//func calculateImprovedRatings(userRating: Int, enemyRating: Int, result: GameResult, userGamesPlayed: Int, enemyGamesPlayed: Int, userHP: Double, enemyHP: Double) -> (newUserRating: Int, newEnemyRating: Int) {
//    // Convert ratings to Double for calculations
//    let userRatingDouble = Double(userRating)
//    let enemyRatingDouble = Double(enemyRating)
//
//    // Calculate expected scores for both players
//    let expectedUserScore = 1 / (1 + pow(10, (enemyRatingDouble - userRatingDouble) / 400))
//    let expectedEnemyScore = 1 / (1 + pow(10, (userRatingDouble - enemyRatingDouble) / 400))
//
//    // Determine actual score based on the result
//    var userScore: Double = 0.0
//    var enemyScore: Double = 0.0
//    var hpFactor: Double = 1.0 // Default HP factor
//
//    switch result {
//    case .win:
//        userScore = 1.0
//        enemyScore = 0.0
//        hpFactor = 1 + userHP / 100.0 // Increase change based on user HP
//    case .lose:
//        userScore = 0.0
//        enemyScore = 1.0
//        hpFactor = 1 + enemyHP / 100.0 // Increase change based on enemy HP
//    case .tie:
//        userScore = 0.5
//        enemyScore = 0.5
//    case .afkWin:
//        userScore = 1.0
//        enemyScore = 0.0
//        hpFactor = 0.5 // Reduced effect for winning due to disconnection
//    case .afkLose:
//        userScore = 0.0
//        enemyScore = 1.0
//        hpFactor = 0.5 // Reduced effect for losing due to disconnection
//    }
//
//    // Dynamic K-factor based on games played: higher K for new players, lower K for experienced players
//    let baseKFactor = 32.0
//    let userKFactor = max(10, baseKFactor / sqrt(Double(userGamesPlayed) + 1))
//    let enemyKFactor = max(10, baseKFactor / sqrt(Double(enemyGamesPlayed) + 1))
//
//    // Calculate rating adjustments, factoring in the HP and disconnect outcomes
//    let userRatingChange = userKFactor * (userScore - expectedUserScore) * hpFactor
//    let enemyRatingChange = enemyKFactor * (enemyScore - expectedEnemyScore) * hpFactor
//
//    // Apply rating changes
//    let newUserRating = userRatingDouble + userRatingChange
//    let newEnemyRating = enemyRatingDouble + enemyRatingChange
//
//    // Return new ratings as integers
//    return (Int(round(newUserRating)), Int(round(newEnemyRating)))
//}

// Example usage
//let userRating = 1600
//let enemyRating = 1500
//let result: GameResult = .win
//let userGamesPlayed = 10
//let enemyGamesPlayed = 50
//let userHP = 10.0   // User has 80% HP remaining
//let enemyHP = 0.0  // Enemy has 20% HP remaining

//let (newUserRating, newEnemyRating) = calculateImprovedRatings(userRating: userRating, enemyRating: enemyRating, result: result, userHP: userHP, enemyHP: enemyHP)
//print("New User Rating: \(newUserRating)")
//print("New Enemy Rating: \(newEnemyRating)")

// Example usage
//let userRating = 1600
//let enemyRating = 1500
//let result = "lose"
//let userGamesPlayed = 10
//let enemyGamesPlayed = 10
//let (newUserRating, newEnemyRating) = calculateImprovedRatings(userRating: userRating, enemyRating: enemyRating, result: result, userGamesPlayed: userGamesPlayed, enemyGamesPlayed: enemyGamesPlayed)

//print("New --User Rating: \(newUserRating)")
//print("New Enemy Rating: \(newEnemyRating)")




// Function to calculate the user's new rating using the improved Elo rating system
func calculateImprovedRating(userRating: Int, enemyRating: Int, result: GameResult, userHP: Double, enemyHP: Double = 0, consecutiveLosses: Int) -> Int {
    // Convert ratings to Double for calculations
    let userRatingDouble = Double(userRating)
    let enemyRatingDouble = Double(enemyRating)

    // Calculate expected score for the user
    let expectedUserScore = 1 / (1 + pow(10, (enemyRatingDouble - userRatingDouble) / 400))

    // Determine actual score based on the result and a base rating change of 20-25 points
    var userScore: Double = 0.0
    var randomChangeRate: Double = Double.random(in: 24...30) // Random adjustment between 20 and 25 points

    switch result {
    case .win:
        userScore = 1.0
        randomChangeRate *= (1 + userHP / 100.0) // Scale up based on remaining HP
    case .lose:
        userScore = 0.0
        randomChangeRate *= (1 + enemyHP / 100.0) // Scale up based on enemy's remaining HP
    case .tie:
        userScore = 0.5
        randomChangeRate = 0.0 // No rating change on a tie
    case .afkWin:
        userScore = 1.0
        randomChangeRate *= 0.5 // Reduced rating change for winning due to AFK
    case .afkLose:
        userScore = 0.0
        randomChangeRate *= 0.5 // Reduced rating change for losing due to AFK
    }

    // Calculate rating change
    let performanceRatingChange = randomChangeRate * (userScore - expectedUserScore)
    let ratingChange: Double

    //Based on performance rating,
    let isSmallRatingChange = Int(performanceRatingChange) == 0
    let isMediumRatingChange = Int(performanceRatingChange) > 10
    switch performanceRatingChange {
    case _ where performanceRatingChange < -50:
        ratingChange = -31
    case _ where performanceRatingChange < -40:
        ratingChange = -25
    case _ where performanceRatingChange < -30:
        ratingChange = -23
    case _ where performanceRatingChange < -20:
        ratingChange = -23
    case _ where performanceRatingChange < -10:
        ratingChange = result.isDefault ? result.isWin ? isSmallRatingChange ? -3 : isMediumRatingChange ? -10 : performanceRatingChange : -5 : -21
    case _ where performanceRatingChange < 0:
        ratingChange = result.isDefault ? result.isWin ? isSmallRatingChange ? -2 : isMediumRatingChange ? -10 : performanceRatingChange : -5 : -19
    case 0:
        ratingChange = result.isWin ? 15 : 1
    case _ where performanceRatingChange > 50:
        ratingChange = 36
    case _ where performanceRatingChange > 40:
        ratingChange = 32
    case _ where performanceRatingChange > 30:
        ratingChange = 28
    case _ where performanceRatingChange > 20:
        ratingChange = 24
    case _ where performanceRatingChange > 10:
        ratingChange = result.isDefault ? result.isWin ? isSmallRatingChange ? 4 : isMediumRatingChange ? 10 : performanceRatingChange : 5 : 24
    case _ where performanceRatingChange > 0:
        ratingChange = result.isDefault ? result.isWin ? isSmallRatingChange ? 3 : isMediumRatingChange ? 10 : performanceRatingChange : 5 : 22
    default:
        ratingChange = 3
    }

    let newRating = userRatingDouble + ratingChange
    // Check for lock at multiples of 500
    let ratingLock = (userRating / 500) * 500
    var finalRating = newRating
    if userRating >= ratingLock && newRating < Double(ratingLock) && consecutiveLosses < 10 {
        finalRating = Double(ratingLock) // Lock rating at the multiple of 500 if less than 10 losses
    } else if !result.isDefault {
        //Add random bonus for completed games
        let bonus = round(Double.random(in: 0...2))
        finalRating += bonus
    }

    // Return the new user rating as an integer
    return Int(round(finalRating))
}

// Example usage
//let userRating = 1600
let enemyRating = 1550
//let result: GameResult = .win
let winnerHpLeft = 5.0    // User has 75% HP remaining
//let enemyHP = 70.0   // Enemy has 70% HP remaining
let consecutiveLosses = 3 // User has lost 3 times in a row

for rating in enemyRating-500...enemyRating + 1500 {
    if rating % 100 == 50 {
        print("\(rating) vs \(enemyRating)")
        let userWinRating = calculateImprovedRating(userRating: rating, enemyRating: enemyRating, result: .win, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)
        let userLoseRating = calculateImprovedRating(userRating: rating, enemyRating: enemyRating, result: .lose, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)
        let enemyWinRating = calculateImprovedRating(userRating: enemyRating, enemyRating: rating, result: .win, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)
        let enemyLoseRating = calculateImprovedRating(userRating: enemyRating, enemyRating: rating, result: .lose, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)
//        print("\nafk")
        let userWinRating2 = calculateImprovedRating(userRating: rating, enemyRating: enemyRating, result: .afkWin, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)
        let userLoseRating2 = calculateImprovedRating(userRating: rating, enemyRating: enemyRating, result: .afkLose, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)
        let enemyWinRating2 = calculateImprovedRating(userRating: enemyRating, enemyRating: rating, result: .afkWin, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)
        let enemyLoseRating2 = calculateImprovedRating(userRating: enemyRating, enemyRating: rating, result: .afkLose, userHP: winnerHpLeft, consecutiveLosses: consecutiveLosses)

        print("User rating \t\t \(rating) is \tW:\(userWinRating-rating) \t L:\(userLoseRating-rating) \t\tW:\(userWinRating2-rating) \t L:\(userLoseRating2-rating)")
        print("Enemy rating \(rating) vs \(enemyRating) is \tW:\(enemyWinRating-enemyRating) \t L:\(enemyLoseRating-enemyRating) \t\tW:\(enemyWinRating2-enemyRating) \t L:\(enemyLoseRating2-enemyRating)")
        if rating == enemyRating {
            print("====================================================================")
        }
        print("====================================================================\n")
    }
}

//: [Next](@next)
