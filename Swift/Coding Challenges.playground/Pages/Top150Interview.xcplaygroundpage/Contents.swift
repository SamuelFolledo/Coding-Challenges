//: [Previous](@previous)

import Foundation

//1) 88. Merge Sorted Array
//You are given two integer arrays nums1 and nums2, sorted in non-decreasing order, and two integers m and n, representing the number of elements in nums1 and nums2 respectively.
//Input: nums1 = [1,2,3], m = 3, nums2 = [2,5,6], n = 3
//Output: [1,2,2,3,5,6]
func merge(_ nums1: inout [Int], _ m: Int, _ nums2: [Int], _ n: Int) {
    //clean nums1
    nums1 = Array(nums1[0..<m])
    let nums1Copy = nums1
    var nums2 = nums2
    var index = 0
    var index2 = 0
    let goalCount = nums1Copy.count + nums2.count
    while nums1.count < goalCount {
        if nums1Copy.count == index {
            //if all nums1 has been added...
            nums1.append(contentsOf: Array(nums2[index2..<nums2.count]))
            return
        } else if nums1Copy[index] <= nums2[index2] {
            index += 1
        } else {
            nums1.insert(nums2[index2], at: index + index2)
            index2 += 1
            if nums2.count == index2 {
                return
            }
        }
    }
}

/* 2) 27. Remove Element
 Given an integer array nums and an integer val, remove all occurrences of val in nums in-place. The order of the elements may be changed. Then return the number of elements in nums which are not equal to val.
*/
func removeElement(_ nums: inout [Int], _ val: Int) -> Int {
    var index = 0
    var nums2 = nums
    for i in 0..<nums.count {
        if nums2[i] != val {
            nums[index] = nums[i]
            index += 1
        }
    }
    return index
}

/* 3) 26. Remove Duplicates from Sorted Array
 Given an integer array nums sorted in non-decreasing order, remove the duplicates in-place such that each unique element appears only once. The relative order of the elements should be kept the same. Then return the number of unique elements in nums.
*/
func removeDuplicates(_ nums: inout [Int]) -> Int {
    guard nums.count > 1 else { return nums.count }
    var idx = 0
    for n in nums {
        if n != nums[idx] {
            idx += 1
            nums[idx] = n
        }
    }
    return idx + 1
}
var removeDuplicatesArr = [1,1,2,3,3]
removeDuplicates(&removeDuplicatesArr)

var removeDuplicatesArr2 = [1,1,2,3,3]
///Slightly more efficient in space using reversed to make shift not take too much time
func removeDuplicates2(_ nums: inout [Int]) -> Int {
    for i in (1..<nums.count).reversed() {
        if nums[i] == nums[i - 1] {
            nums.remove(at: i)
        }
    }
    return nums.count
}
removeDuplicates2(&removeDuplicatesArr2)

/* 4) 80. Remove Duplicates from Sorted Array II
 Given an integer array nums sorted in non-decreasing order, remove some duplicates in-place such that each unique element appears at most twice. The relative order of the elements should be kept the same.
 Input: nums = [0,0,1,1,1,1,2,3,3]
 Output: 7, nums = [0,0,1,1,2,3,3,_,_]
 */
var removeDuplicatesMediumBruteArr = [1,1,1,2,2,3]
///Brute force solution
func removeDuplicatesMediumBrute(_ nums: inout [Int]) -> Int {
    var counters: [Int: Int] = [:]
    var index = 0
    for n in nums {
        if let counter = counters[n] {
            if counter >= 2 {
                nums.remove(at: index)
            } else {
                counters[n]? += 1
                index += 1
            }
        } else {
            counters[n] = 1
            index += 1
        }
    }
    return nums.count
}
removeDuplicatesMediumBrute(&removeDuplicatesMediumBruteArr)

var removeDuplicatesMediumArr = [1,1,1,2,2,3]
func removeDuplicatesMedium(_ nums: inout [Int]) -> Int {
    let n = nums.count
    guard n > 2 else { return n }
    var j = 1
    var count = 1

    for i in 1..<nums.count {
        if nums[i] == nums[i - 1] {
            count += 1
        } else {
            count = 1
        }

        if count <= 2 {
            nums[j] = nums[i]
            j += 1
        }
    }
    return j
}
removeDuplicatesMedium(&removeDuplicatesMediumArr)

/*
 5) 169. Majority Element
 Given an array nums of size n, return the majority element.

 Input: nums = [2,2,1,1,1,2,2]
 Output: 2
 */
func majorityElementBrute(_ nums: [Int]) -> Int {
    var counters: [Int: Int] = [:]
    for num in nums {
        if let count = counters[num] {
            counters[num] = count + 1
        } else {
            counters[num] = 1
        }
    }
    var max = 0
    var maxNum: Int = nums.first!
    for (num, count) in counters {
        if count > max {
            max = count
            maxNum = num
        }
    }
    return maxNum
}

//O(n)
func majorityElement(_ nums: [Int]) -> Int {
    var candidate: Int = Int.min
    var ticker: Int = 0
    for number in nums {
        if (ticker == 0) {
            candidate = number
        }

        if (number == candidate) {
            ticker += 1
        } else {
            ticker -= 1
        }
    }
    return candidate
}

/*
 6) 189. Rotate Array
 Given an integer array nums, rotate the array to the right by k steps, where k is non-negative.
 Input: nums = [1,2,3,4,5,6,7], k = 3
 Output: [5,6,7,1,2,3,4]
 */
func rotateBrute(_ nums: inout [Int], _ k: Int) {
    guard nums.count > 1 else { return }
    for _ in 0..<k {
        nums.insert(nums.popLast()!, at: 0)
    }
}

func rotate(_ nums: inout [Int], _ k: Int) {
    guard !nums.isEmpty ||  k > 0  else { return }

    //pointers
    let n = nums.count
    let k = k % n

    // Reverse entire array
    nums.reverse()

    // Reverse first k elements
    nums[0..<k].reverse()

    // Reverse remaining n-k elements
    nums[k..<n].reverse()
}
var rotateArr = [1,2,3,4,5,6,7]
rotate(&rotateArr, 3)

/*
 7) 121. Best Time to Buy and Sell Stock
 You are given an array prices where prices[i] is the price of a given stock on the ith day.
 You want to maximize your profit by choosing a single day to buy one stock and choosing a different day in the future to sell that stock.
 Return the maximum profit you can achieve from this transaction. If you cannot achieve any profit, return 0.

 Example 1:
 Input: prices = [7,1,5,3,6,4]
 Output: 5

 Example 2:
 Input: prices = [7,6,4,3,1]
 Output: 0
 */

func maxProfitBrute(_ prices: [Int]) -> Int {
    //TODO: Figure out why it's taking too long on large prices
    var maxProfit = 0
    for i in 0..<prices.count {
        for j in (i + 1)..<prices.count {
            let profit = prices[j] - prices[i]
            if profit > maxProfit {
                maxProfit = profit
            }
        }
    }
    return maxProfit
}

//sliding window solution
func maxProfit(_ prices: [Int]) -> Int {
    var maxProfit = 0
    var left = 0
    var right = 0
    while right < prices.count {
        if prices[left] < prices[right] {
            let profit = prices[right] - prices[left]
            maxProfit = max(maxProfit, profit)
        } else {
            left = right
        }
        right += 1
    }
    return maxProfit
}

/*
 8) 122. Best Time to Buy and Sell Stock II
 You are given an integer array prices where prices[i] is the price of a given stock on the ith day.
 On each day, you may decide to buy and/or sell the stock. You can only hold at most one share of the stock at any time. However, you can buy it then immediately sell it on the same day.
 Find and return the maximum profit you can achieve.

 Example 1:
 Input: prices = [7,1,5,3,6,4]
 Output: 7

 Example 2:
 Input: prices = [1,2,3,4,5]
 Output: 4
 */

//O(n)
func maxProfit2(_ prices: [Int]) -> Int {
    guard !prices.isEmpty else { return 0 }

    var maxProfit = 0
    for i in 1..<prices.count {
        let price = prices[i]
        let previousPrice = prices[i - 1]
        ///only increment maxProfit if current price is greater than previous price
        guard price > previousPrice else { continue }
        maxProfit += price - previousPrice
    }
    return maxProfit
}

/*
 9) 55. Jump Game
 You are given an integer array nums. You are initially positioned at the array's first index, and each element in the array represents your maximum jump length at that position.
 Return true if you can reach the last index, or false otherwise.

 Example 1:

 Input: nums = [2,3,1,1,4]
 Output: true
 Explanation: Jump 1 step from index 0 to 1, then 3 steps to the last index.
 Example 2:

 Input: nums = [3,2,1,0,4]
 Output: false
 Explanation: You will always arrive at index 3 no matter what. Its maximum jump length is 0, which makes it impossible to reach the last index.
 */

//func canJump(_ nums: [Int]) -> Bool {
//    guard nums.count > 1 else { return true }
//    var i = 0
//    while i < nums.count {
//        i += nums[i]
//        if i >= nums.count - 1 {
//            return true
//        } else if nums[i] == 0 {
//            return false
//        }
//    }
//    return false
//}

func canJump(_ nums: [Int]) -> Bool {
    var reach = 0
    for (index, num) in nums.enumerated() {
        if index > reach {
            return false
        }
        reach = max(reach, index + num)
    }
    return true
}

//MARK: - 2 Pointers
/*
 25) 125. Valid Palindrome
 A phrase is a palindrome if, after converting all uppercase letters into lowercase letters and removing all non-alphanumeric characters, it reads the same forward and backward. Alphanumeric characters include letters and numbers.
 Given a string s, return true if it is a palindrome, or false otherwise.

 Example 1:
 Input: s = "A man, a plan, a canal: Panama"
 Output: true
 Explanation: "amanaplanacanalpanama" is a palindrome.

 Example 2:
 Input: s = "race a car"
 Output: false
 Explanation: "raceacar" is not a palindrome.
 */

func isPalindrome(_ s: String) -> Bool {
    ///remove non alphanumeric, then lowercase
    let str = Array(s.filter { $0.isLetter || $0.isNumber }.lowercased())
    var i = 0
    while i < str.count / 2 {
        if str[i] != str[str.count - 1 - i] {
            return false
        }
        i += 1
    }
    return true
}

/*
 26) 392. Is Subsequence
 Given two strings s and t, return true if s is a subsequence of t, or false otherwise.
 A subsequence of a string is a new string that is formed from the original string by deleting some (can be none) of the characters without disturbing the relative positions of the remaining characters. (i.e., "ace" is a subsequence of "abcde" while "aec" is not).

 Example 1:
 Input: s = "abc", t = "ahbgdc"
 Output: true

 Example 2:
 Input: s = "axc", t = "ahbgdc"
 Output: false
 */
func isSubsequenceBrute(_ s: String, _ t: String) -> Bool {
    guard !s.isEmpty else { return true }
    var index = 0
    for char in t {
        if Array(s)[index] == char {
            index += 1
            if index == s.count {
                return true
            }
        }
    }
    return false
}

func isSubsequence(_ s: String, _ t: String) -> Bool {
    var i = s.startIndex
    var j = t.startIndex
    while i < s.endIndex && j < t.endIndex {
        if s[i] == t[j] {
            i = s.index(after: i)
        }
        j = t.index(after: j)
    }
    return i == s.endIndex
}

/*
 27) 167. Two Sum II - Input Array Is Sorted
 Given a 1-indexed array of integers numbers that is already sorted in non-decreasing order, find two numbers such that they add up to a specific target number. Let these two numbers be numbers[index1] and numbers[index2] where 1 <= index1 < index2 <= numbers.length.
 Return the indices of the two numbers, index1 and index2, added by one as an integer array [index1, index2] of length 2.
 The tests are generated such that there is exactly one solution. You may not use the same element twice.
 Your solution must use only constant extra space.

 Example 1:
 Input: numbers = [2,7,11,15], target = 9
 Output: [1,2]
 Explanation: The sum of 2 and 7 is 9. Therefore, index1 = 1, index2 = 2. We return [1, 2].

 Example 2:
 Input: numbers = [2,3,4], target = 6
 Output: [1,3]
 */

func twoSum2Brute(_ numbers: [Int], _ target: Int) -> [Int] {
    ///key is number we are looking for and value is the index of the first number
    var dic: [Int: Int] = [:]
    for (index, num) in numbers.enumerated() {
        if let firstIndex = dic[num] {
            return [firstIndex + 1, index + 1]
        } else {
            let difference = target - num
            dic[difference] = index
        }
    }
    return []
}

func twoSum2(_ numbers: [Int], _ target: Int) -> [Int] {
    var low = 0
    var high = numbers.count - 1
    while low < high {
        var sum = numbers[low] + numbers[high]
        if sum == target {
            return [low + 1, high + 1]
        } else if sum < target {
            low += 1
        } else {
            high -= 1
        }
    }
    return []
}

/*
 29) 3Sum
 Given an integer array nums, return all the triplets [nums[i], nums[j], nums[k]] such that i != j, i != k, and j != k, and nums[i] + nums[j] + nums[k] == 0.
 Notice that the solution set must not contain duplicate triplets.

 Example 1:
 Input: nums = [-1,0,1,2,-1,-4]
 Output: [[-1,-1,2],[-1,0,1]]
 Explanation:
 nums[0] + nums[1] + nums[2] = (-1) + 0 + 1 = 0.
 nums[1] + nums[2] + nums[4] = 0 + 1 + (-1) = 0.
 nums[0] + nums[3] + nums[4] = (-1) + 2 + (-1) = 0.
 The distinct triplets are [-1,0,1] and [-1,-1,2].
 Notice that the order of the output and the order of the triplets does not matter.

 Example 2:
 Input: nums = [0,1,1]
 Output: []
 Explanation: The only possible triplet does not sum up to 0.

 Example 3:
 Input: nums = [0,0,0]
 Output: [[0,0,0]]
 Explanation: The only possible triplet sums up to 0.
 */
func threeSumBrute(_ nums: [Int]) -> [[Int]] {
    let sortedNums = nums.sorted()
    var result = Set<[Int]>()
    for i in 0 ..< sortedNums.count {
        var j = i + 1
        var k = sortedNums.count - 1
        while j < k {
            let sum = sortedNums[i] + sortedNums[j] + sortedNums[k]
            if sum == 0 {
                result.insert([sortedNums[i], sortedNums[j], sortedNums[k]])
                j += 1
                k -= 1
            } else if sum < 0 {
                j += 1
            } else {
                k -= 1
            }
        }
    }
    return Array(result)
}

func threeSum(_ nums: [Int]) -> [[Int]] {
    let sortedNums = nums.sorted()
    if sortedNums.count < 3 { return [] }
    if sortedNums.last! < 0 { return [] }
    var result = [[Int]]()
    for i in 0..<sortedNums.count {
        if sortedNums[i] > 0 { break }
        if i > 0 && sortedNums[i] == sortedNums[i-1] { continue }
        var low = i + 1
        var high = sortedNums.count - 1
        var sum = 0
        while low < high {
            sum = sortedNums[i] + sortedNums[low] + sortedNums[high]
            if sum < 0 {
                low += 1
            } else if sum > 0 {
                high -= 1
            } else {
                result.append([sortedNums[i], sortedNums[low], sortedNums[high]])
                low += 1
                high -= 1
                while low < high && sortedNums[low] == sortedNums[low - 1] { low += 1 }
            }
        }
    }
    return result
}

//MARK: - Sliding Window

/*
 3. Longest Substring without repeating characters (M)
 Given a string s, find the length of the longest substring without repeating characters.

 Example 1:
 Input: s = "abcabcbb"
 Output: 3
 Explanation: The answer is "abc", with the length of 3.

 Example 2:
 Input: s = "bbbbb"
 Output: 1
 Explanation: The answer is "b", with the length of 1.

 Example 3:
 Input: s = "pwwkew"
 Output: 3
 Explanation: The answer is "wke", with the length of 3.
 Notice that the answer must be a substring, "pwke" is a subsequence and not a substring.
 */

//O(n) solution
func lengthOfLongestSubstring(_ s: String) -> Int {
    guard !s.isEmpty else { return 0 }
    var len = 0
    var chars = [Character]()
    for c in s {
        if let idx = chars.firstIndex(of: c) {
            chars.removeSubrange(0...idx)
        }
        chars.append(c)
        len = max(len, chars.count)
    }
    return len
}

//lengthOfLongestSubstring("abcabcba") //3

//MARK: - Matrix

/*
 36. Valid Sudoku

 Determine if a 9 x 9 Sudoku board is valid. Only the filled cells need to be validated according to the following rules:
 - Each row must contain the digits 1-9 without repetition.
 - Each column must contain the digits 1-9 without repetition.
 - Each of the nine 3 x 3 sub-boxes of the grid must contain the digits 1-9 without repetition.

 Note:
 A Sudoku board (partially filled) could be valid but is not necessarily solvable.
 Only the filled cells need to be validated according to the mentioned rules.

 Example 1:
 Input: board =
 [["5","3",".",".","7",".",".",".","."]
 ,["6",".",".","1","9","5",".",".","."]
 ,[".","9","8",".",".",".",".","6","."]
 ,["8",".",".",".","6",".",".",".","3"]
 ,["4",".",".","8",".","3",".",".","1"]
 ,["7",".",".",".","2",".",".",".","6"]
 ,[".","6",".",".",".",".","2","8","."]
 ,[".",".",".","4","1","9",".",".","5"]
 ,[".",".",".",".","8",".",".","7","9"]]
 Output: true

 Example 2:
 Input: board =
 [["8","3",".",".","7",".",".",".","."] //has 8
 ,["6",".",".","1","9","5",".",".","."]
 ,[".","9","8",".",".",".",".","6","."]
 ,["8",".",".",".","6",".",".",".","3"] //has 8 again
 ,["4",".",".","8",".","3",".",".","1"]
 ,["7",".",".",".","2",".",".",".","6"]
 ,[".","6",".",".",".",".","2","8","."]
 ,[".",".",".","4","1","9",".",".","5"]
 ,[".",".",".",".","8",".",".","7","9"]]
 Output: false
 Explanation: Same as Example 1, except with the 5 in the top left corner being modified to 8. Since there are two 8's in the top left 3x3 sub-box, it is invalid.
 */

func isValidSudokuBrute(_ board: [[Character]]) -> Bool {
    //iterate through each row
    for i in 0 ..< 9 {
        var set = Set<Character>()
        for j in 0 ..< 9 {
            if board[i][j] != ".", set.contains(board[i][j]) {
                return false
            }
            set.insert(board[i][j])
        }
    }

    //iterate through each column
    for j in 0 ..< 9 {
        var set = Set<Character>()
        for i in 0 ..< 9 {
            if board[i][j] != ".", set.contains(board[i][j]) {
                return false
            }
            set.insert(board[i][j])
        }
    }

    //iterate through each 3x3
    for k in 0 ..< 9 {
        var set = Set<Character>()
        let row = k / 3 * 3 //starting row for each sub-box
        for i in row ..< row + 3 {
            let column = k % 3 * 3 //starting column for each sub-box
            for j in column ..< column + 3 {
                if board[i][j] != ".", set.contains(board[i][j]) {
                    return false
                }
                set.insert(board[i][j])
            }
        }
    }

    return true
}

func isValidSudoku(_ board: [[Character]]) -> Bool {
    func isInvalid(_ box: [Character]) -> Bool {
        var chars: [Character] = []
        for c in box where c != "." {
            if chars.contains(c) { return true } else { chars.append(c) }
        }
        return false
    }

    for i in 0..<9 {
        if isInvalid(board[i]) { return false }
        if isInvalid(board.map({ $0[i] })) { return false } ///creates an array of characters from the i-th column of the board
        let col = (i % 3) * 3
        let row = (i / 3) * 3
        let box = Array(board[row][col..<col + 3]) + Array(board[row + 1][col..<col + 3]) + Array(board[row + 2][col..<col + 3])
        if isInvalid(box) { return false }
    }
    return true
}

/*
 54. Spiral Matrix
 Given an m x n matrix, return all elements of the matrix in spiral order.

 Example 1:
 Input: matrix = [[1,2,3],[4,5,6],[7,8,9]]
 Output: [1,2,3,6,9,8,7,4,5]

 Example 2:
 Input: matrix = [[1,2,3,4],[5,6,7,8],[9,10,11,12]]
 Output: [1,2,3,4,8,12,11,10,9,5,6,7]
 */

func spiralOrder(_ matrix: [[Int]]) -> [Int] {
    guard !(matrix.isEmpty) else { return [] }

    var result: [Int] = []
    var rBegin = 0
    var rEnd = matrix.count - 1
    var cBegin = 0
    var cEnd = matrix[0].count - 1

    while rBegin <= rEnd && cBegin <= cEnd {
        // Traverse right
        for i in stride(from: cBegin, to: cEnd + 1, by: 1) {
            print("right to \(matrix[rBegin][i])")
            result.append(matrix[rBegin][i])
        }
        rBegin += 1 //move row begin down

        // Traverse down
        for i in stride(from: rBegin, to: rEnd + 1, by: 1) {
            print("down to \(matrix[i][cEnd])")
            result.append(matrix[i][cEnd])
        }
        cEnd -= 1 //move column end to the left

        // Traverse left
        if rBegin <= rEnd {
            for i in stride(from: cEnd, to: cBegin - 1, by: -1) {
                print("LEFT to \(matrix[rEnd][i])")
                result.append(matrix[rEnd][i])
            }
        }
        rEnd -= 1 //move row end up

        // Traverse up
        if cBegin <= cEnd {
            for i in stride(from: rEnd, to: rBegin - 1, by: -1) {
                print("up to \(matrix[i][cBegin])")
                result.append(matrix[i][cBegin])
            }
        }
        cBegin += 1 //more column begin to the right
    }
    return result
}

//spiralOrder([[1,2,3],[4,5,6],[7,8,9]])

//MARK: - Hashmap

//MARK: - Intervals

//MARK: - Stack
/*
 20. Valid Parentheses = Easy
 Given a string s containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.
 An input string is valid if:

 Open brackets must be closed by the same type of brackets.
 Open brackets must be closed in the correct order.
 Every close bracket has a corresponding open bracket of the same type.

 Example 1:
 Input: s = "()"
 Output: true

 Example 2:
 Input: s = "()[]{}"
 Output: true

 Example 3:
 Input: s = "(]"
 Output: false

 Example 4:
 Input: s = "([])"
 Output: true
 */

func isValidParenthesis(_ s: String) -> Bool {
    guard s.count % 2 == 0 else { return false }
    var stack: [Character] = []
    for ch in s {
        switch ch {
        case "(": stack.append(")")
        case "[": stack.append("]")
        case "{": stack.append("}")
        default:
            if stack.isEmpty || stack.removeLast() != ch {
                return false
            }
        }
    }
    return stack.isEmpty
}

/*
 155. Min Stack = Medium
 Design a stack that supports push, pop, top, and retrieving the minimum element in constant time.

 Implement the MinStack class:
 MinStack() initializes the stack object.
 void push(int val) pushes the element val onto the stack.
 void pop() removes the element on the top of the stack.
 int top() gets the top element of the stack.
 int getMin() retrieves the minimum element in the stack.
 You must implement a solution with O(1) time complexity for each function.

 Example 1:
 Input
 ["MinStack","push","push","push","getMin","pop","top","getMin"]
 [[],[-2],[0],[-3],[],[],[],[]]

 Output
 [null,null,null,null,-3,null,0,-2]
 Explanation
 MinStack minStack = new MinStack();
 minStack.push(-2);
 minStack.push(0);
 minStack.push(-3);
 minStack.getMin(); // return -3
 minStack.pop();
 minStack.top();    // return 0
 minStack.getMin(); // return -2
 */

class MinStack {
    private var stack: [(x: Int, min: Int)] = []

    func push(_ x: Int) {
        if stack.isEmpty {
            stack.append((x, x))
        } else {
            let currentMin = min(x, stack.last!.min)
            stack.append((x, currentMin))
        }
    }

    func pop() {
        stack.removeLast()
    }

    func top() -> Int {
        return stack.last!.x
    }

    func getMin() -> Int {
        return stack.last!.min
    }
}

//MARK: - Linked List

//MARK: - Binary Tree General
public class TreeNode {
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?

    public init() { self.val = 0; self.left = nil; self.right = nil; }
    public init(_ val: Int) { self.val = val; self.left = nil; self.right = nil; }
    public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
        self.val = val
        self.left = left
        self.right = right
    }

    ///Initialize TreeNode using an array instead where root is the first item in the array
    public init?(_ array: [Int]) {
        guard !array.isEmpty else { return nil }
        self.val = array[0]
        self.left = nil
        self.right = nil
        var queue = [self]
        var i = 1
        while i < array.count {
            let node = queue.removeFirst()
            if i < array.count {
                node.left = TreeNode(array[i])
                queue.append(node.left!)
                i += 1
            }
            if i < array.count {
                node.right = TreeNode(array[i])
                queue.append(node.right!)
                i += 1
            }
        }
    }

    // BFS Print
    public func printBFS() {
        var queue = [self]
        var result = [Int]()

        while !queue.isEmpty {
            let node = queue.removeFirst()
            result.append(node.val)

            if let left = node.left {
                queue.append(left)
            }
            if let right = node.right {
                queue.append(right)
            }
        }

        print("BFS: \(result)")
    }
}

/*
 104. Maximum Depth of Binary Tree = Easy
 Given the root of a binary tree, return its maximum depth.
 A binary tree's maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.

 Example 1:
 Input: root = [3,9,20,null,null,15,7]
 Output: 3

 Example 2:
 Input: root = [1,null,2]
 Output: 2
 */

// - Complexity:
//   - time: O(n), where n is the number of nodes.
//   - space: O(n), where n is the number of nodes.

func maxDepth(_ root: TreeNode?) -> Int {
    guard let root else { return 0 }
    return 1 + max(maxDepth(root.left), maxDepth(root.right))
}

/*
 226. Invert Binary Tree = Easy
 Given the root of a binary tree, invert the tree, and return its root.

 Example 1:
 Input: root = [4,2,7,1,3,6,9]
 Output: [4,7,2,9,6,3,1]

 Example 2:
 Input: root = [2,1,3]
 Output: [2,3,1]
 Explanation:
     [2]            [2]
    /   \   ->     /   \
 [1]    [3]     [3]     [1]

 Example 3:
 Input: root = []
 Output: []
 */

func invertTree(_ root: TreeNode?) -> TreeNode? {
    print("+Inverting \(root?.val.description ?? "nil") \twith\t \(root?.left?.val.description ?? "noLeft")-\(root?.right?.val.description ?? "noRight")")
    guard let root = root else {return nil}
    let left = invertTree(root.left)
    let right = invertTree(root.right)
    root.left = right
    root.right = left
    print("-Returning root \(root.val)")
    return root
}

let tree = TreeNode([4,2,7,1,3,6,9])
invertTree(tree)
tree?.printBFS()

//MARK: - Binary Tree BFS

//MARK: - Binary Search Tree

//MARK: - Graph General

//MARK: - Graph BFS

//MARK: - Trie

//MARK: - Backtracking

//MARK: - Divide & Conquer

//MARK: - Kadane's Algorithm

//MARK: - Binary Search

//MARK: - Heap

//MARK: - Bit Manipulation

//MARK: - Math

//MARK: - 1D DP

//MARK: - Multidimensional DP



//: [Next](@next)
