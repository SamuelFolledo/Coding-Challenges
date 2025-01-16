//: A UIKit based Playground for presenting user interface
  
//import UIKit
//import PlaygroundSupport
//
//class MyViewController : UIViewController {
//    override func loadView() {
//        let view = UIView()
//        view.backgroundColor = .white
//
//        let label = UILabel()
//        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
//        label.text = "Hello World!"
//        label.textColor = .black
//        
//        view.addSubview(label)
//        self.view = view
//    }
//}
//// Present the view controller in the Live View window
//PlaygroundPage.current.liveView = MyViewController()

import Foundation

print("\n==================================================================\n1) ")
func alternatingParity(_ nums: [Int], _ k: Int) -> Bool {
    guard k <= nums.count else { return false }

    for start in 0...(nums.count - k) {
        var isAlternating = true
        for i in start..<(start + k - 1) {
            if nums[i] % 2 == nums[i + 1] % 2 {
                isAlternating = false
                break
            }
        }
        if isAlternating {
            return true
        }
    }
    return false
}

let nums = [1, 2, 3, 4, 5, 6, 7]
let k = 3
print(alternatingParity(nums, k))  // Output: true

print("\n==================================================================\n2) similarPairs")

func similarPairs(_ words: [String]) -> Int {
    var count = 0
    var wordSets: [[Character: Bool]] = []

    for word in words {
        let charSet = word.reduce(into: [Character: Bool]()) { $0[$1] = true }
        wordSets.append(charSet)
    }

    for i in 0..<words.count {
        for j in (i+1)..<words.count {
            if wordSets[i] == wordSets[j] {
                count += 1
            }
        }
    }

    return count
}

let words = ["abc", "bca", "cba", "def", "fed"]
print(similarPairs(words))  // Output: 3

print("\n==================================================================\n3) ")
func cyclicalTShifts(_ arr1: [Int], _ arr2: [Int], _ t: Int) -> Int {
    let n = arr1.count
    var maxMatches = 0

    for shift in 0...t {
        var matches = 0
        for i in 0..<n {
            if arr1[i] == arr2[(i - shift + n) % n] {
                matches += 1
            }
        }
        maxMatches = max(maxMatches, matches)
    }

    return maxMatches
}

let arr1 = [1, 2, 3, 4, 5]
let arr2 = [5, 1, 2, 3, 4]
let t = 2
print(cyclicalTShifts(arr1, arr2, t))  // Output: 5

print("\n==================================================================\n4) ")
func findPerfectXCenter(_ matrix: [[Int]]) -> (Int, Int)? {
    let rows = matrix.count
    let cols = matrix[0].count

    for i in 1..<(rows-1) {
        for j in 1..<(cols-1) {
            let center = matrix[i][j]
            let diagonals = [matrix[i-1][j-1], matrix[i-1][j+1], matrix[i+1][j-1], matrix[i+1][j+1]]
            let adjacents = [matrix[i][j-1], matrix[i][j+1], matrix[i-1][j], matrix[i+1][j]]

            if diagonals.allSatisfy({ $0 == center }) && adjacents.allSatisfy({ $0 != center }) {
                return (i, j)
            }
        }
    }

    return nil
}


let matrix = [
    [1, 2, 3, 4],
    [5, 1, 2, 3],
    [9, 5, 1, 2],
    [8, 9, 5, 1]
]
print(findPerfectXCenter(matrix))  // Output: Optional((2, 2))
