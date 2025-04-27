//: [Previous](@previous)

import SwiftUI

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
}

/*:

 ## 1. Binary Search Tree
 Given the root of a binary search tree, rearrange the tree in in-order so that the leftmost node in the tree is now the root of the tree, and every node has no left child and only one right child.
 Example 1:
 Input: root = [5,3,6,2,4,null,8,1,null,null,null,7,9]
 Output: [1,null,2,null,3,null,4,null,5,null,6,null,7,null,8,null,9]

 Example 2:
 Input: root = [5,1,7]
 Output: [1,null,5,null,7]

 Constraints:
 - The number of nodes in the given tree will be in the range [1, 100].
 - 0 <= Node.val <= 1000
 */

func increasingBST(_ root: TreeNode?) -> TreeNode? {
    let dummy = TreeNode(0)
    var current: TreeNode? = dummy
    var stack: [TreeNode] = []
    var node = root
    while node != nil || !stack.isEmpty {
        // Traverse to the leftmost node
        while let n = node {
            stack.append(n)
            node = n.left
        }
        // Process the current node
        if let n = stack.popLast() {
            current?.right = n
            current = n
            current?.left = nil

            // Move to the right child
            node = n.right
        }
    }
    return dummy.right
}

func increasingBST_Recursion(_ root: TreeNode?) -> TreeNode? {
    var current: TreeNode?

    let dummy = TreeNode(0)
    current = dummy
    inorder(root)
    return dummy.right

    func inorder(_ node: TreeNode?) {
        guard let node = node else { return }
        inorder(node.left)

        node.left = nil
        current?.right = node
        current = node

        inorder(node.right)
    }
}

/*
 100. Same Tree = Easy
 Given the roots of two binary trees p and q, write a function to check if they are the same or not.

 Two binary trees are considered the same if they are structurally identical, and the nodes have the same value.

 Example 1:
 Input: p = [1,2,3], q = [1,2,3]
 Output: true

 Example 2:
 Input: p = [1,2], q = [1,null,2]
 Output: false

 Example 3:
 Input: p = [1,2,1], q = [1,1,2]
 Output: false
 */
func isSameTree(_ p: TreeNode?, _ q: TreeNode?) -> Bool {
    guard p != nil || q != nil else { return true }
    guard let p = p, let q = q else { return false }
    return p.val == q.val && isSameTree(p.left, q.left) && isSameTree(p.right, q.right)
}

/*
 101. Symmetric Tree = Easy
 Given the root of a binary tree, check whether it is a mirror of itself (i.e., symmetric around its center).

 Example 1:
 Input: root = [1,2,2,3,4,4,3]
 Output: true

 Example 2:
 Input: root = [1,2,2,null,3,null,3]
 Output: false
 */
func isSymmetric(_ root: TreeNode?) -> Bool {
    isMirror(root, root)
}

private func isMirror(_ left: TreeNode?, _ right: TreeNode?) -> Bool {
    if left == nil, right == nil { return true }
    guard left?.val == right?.val else { return false }
    return isMirror(left?.left, right?.right) && isMirror(left?.right, right?.left)
}

/*
 You are given an array of events where events[i] = [startDayi, endDayi]. Every event i starts at startDayi and ends at endDayi.

 You can attend an event i at any day d where startTimei <= d <= endTimei. You can only attend one event at any time d.

 Return the maximum number of events you can attend.



 Example 1:


 Input: events = [[1,2],[2,3],[3,4]]
 Output: 3
 Explanation: You can attend all the three events.
 One way to attend them all is as shown.
 Attend the first event on day 1.
 Attend the second event on day 2.
 Attend the third event on day 3.
 Example 2:

 Input: events= [[1,2],[2,3],[3,4],[1,2]]
 Output: 4


 Constraints:

 1 <= events.length <= 105
 events[i].length == 2
 1 <= startDayi <= endDayi <= 105
 */

func maxEvents(_ events: [[Int]]) -> Int {
    // Sort events by start time
    let sortedEvents = events.sorted { $0[0] < $1[0] }

    var minHeap = Heap<Int>(sort: <)
    var eventIndex = 0
    var maxAttended = 0
    var currentDay = 1

    while eventIndex < sortedEvents.count || !minHeap.isEmpty {
        // Add all events starting today to the heap
        while eventIndex < sortedEvents.count && sortedEvents[eventIndex][0] == currentDay {
            minHeap.insert(sortedEvents[eventIndex][1])
            eventIndex += 1
        }

        // Remove all ended events
        while !minHeap.isEmpty && minHeap.peek()! < currentDay {
            minHeap.remove()
        }

        // Attend the event ending soonest
        if !minHeap.isEmpty {
            minHeap.remove()
            maxAttended += 1
        }

        currentDay += 1
    }

    return maxAttended
}

// Heap implementation
struct Heap<Element> {
    var elements: [Element]
    let sort: (Element, Element) -> Bool

    init(sort: @escaping (Element, Element) -> Bool) {
        self.elements = []
        self.sort = sort
    }

    var isEmpty: Bool {
        return elements.isEmpty
    }

    func peek() -> Element? {
        return elements.first
    }

    mutating func insert(_ element: Element) {
        elements.append(element)
        siftUp(from: elements.count - 1)
    }

    mutating func remove() -> Element? {
        guard !isEmpty else { return nil }
        elements.swapAt(0, elements.count - 1)
        let element = elements.removeLast()
        if !isEmpty {
            siftDown(from: 0)
        }
        return element
    }

    private mutating func siftUp(from index: Int) {
        var child = index
        var parent = parentIndex(of: child)
        while child > 0 && sort(elements[child], elements[parent]) {
            elements.swapAt(child, parent)
            child = parent
            parent = parentIndex(of: child)
        }
    }

    private mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let leftChild = leftChildIndex(of: parent)
            let rightChild = rightChildIndex(of: parent)
            var candidate = parent
            if leftChild < elements.count && sort(elements[leftChild], elements[candidate]) {
                candidate = leftChild
            }
            if rightChild < elements.count && sort(elements[rightChild], elements[candidate]) {
                candidate = rightChild
            }
            if candidate == parent {
                return
            }
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }

    private func parentIndex(of index: Int) -> Int {
        return (index - 1) / 2
    }

    private func leftChildIndex(of index: Int) -> Int {
        return 2 * index + 1
    }

    private func rightChildIndex(of index: Int) -> Int {
        return 2 * index + 2
    }
}

//Fibonacci memoisation
func fib(_ n: Int) -> Int {
    if n == 0 || n == 1 {
        return n
    } else {
        return fib(n - 1) + fib(n - 2)
    }
}

var memo: [Int: Int] = [:]
func fibMemoised(_ n: Int) -> Int {
    if let result = memo[n] {
        return result
    }
    if n == 0 || n == 1 {
        return n
    } else {
        memo[n] = fibMemoised(n - 1) + fibMemoised(n - 2)
        return memo[n]!
    }
}

let fibNum = 30
print("Test comparing memoised and non-memoised implementations \(fibNum)")
let fibStart = Date()
let regularFib = fib(fibNum)
let fibEnd = Date()
print("Non-memoised: \(regularFib) in \(fibStart.distance(to: fibEnd)) seconds")

let memoisedStart = Date()
let memoisedFib = fibMemoised(fibNum)
let memoisedEnd = Date()
print("Memoised: \(memoisedFib) in \(memoisedStart.distance(to: memoisedEnd)) seconds")

/*
 MARK: 136. Single Number = Easy
 Given a non-empty array of integers nums, every element appears twice except for one. Find that single one.

 You must implement a solution with a linear runtime complexity and use only constant extra space.

 Example 1:
 Input: nums = [2,2,1]
 Output: 1

 Example 2:
 Input: nums = [4,1,2,1,2]
 Output: 4

 Example 3:
 Input: nums = [1]
 Output: 1
 */

func singleNumber(_ nums: [Int]) -> Int {
    var numbers = Set<Int>()
    for num in nums {
        if numbers.contains(num) {
            numbers.remove(num)
        } else {
            numbers.insert(num)
        }
    }
    return numbers.first!
}

/*
 MARK: 163. Missing Ranges = Easy
 You are given an inclusive range [lower, upper] and a sorted unique integer array nums, where all elements are within the inclusive range.
 A number x is considered missing if x is in the range [lower, upper] and x is not in nums.
 Return the shortest sorted list of ranges that exactly covers all the missing numbers. That is, no element of nums is included in any of the ranges, and each missing number is covered by one of the ranges.

 Example 1:
 Input: nums = [0,1,3,50,75], lower = 0, upper = 99
 Output: [[2,2],[4,49],[51,74],[76,99]]
 Explanation: The ranges are:
 [2,2]
 [4,49]
 [51,74]
 [76,99]

 Example 2:
 Input: nums = [-1], lower = -1, upper = -1
 Output: []
 Explanation: There are no missing ranges since there are no missing numbers.
 */

func findMissingRanges(_ nums: [Int], _ lower: Int, _ upper: Int) -> [[Int]] {
    guard nums.isEmpty == false else { return [[lower, upper]] }
    var result = [[Int]]()
    //fill in the gaps between nums
    for i in 0..<nums.count-1 {
        if(nums[i]+1 != nums[i+1]) {
            result.append([nums[i]+1, nums[i+1]-1])
        }
    }
    //populate the beginning and end from lower to first number and last number to upper
    if nums.first != lower { result.insert(([lower, (nums.first ?? 0) - 1]), at: 0)}
    if nums.last != upper { result.append([(nums.last ?? 0) + 1, upper])}
    return result
}

/*
 14. Longest Common Prefix = Easy
 Write a function to find the longest common prefix string amongst an array of strings.
 If there is no common prefix, return an empty string "".

 Example 1:
 Input: strs = ["flower","flow","flight"]
 Output: "fl"

 Example 2:
 Input: strs = ["dog","racecar","car"]
 Output: ""
 */
func longestCommonPrefix(_ strs: [String]) -> String {
    guard !strs.isEmpty else { return "" }
    var prefix = strs[0]
    for word in strs {
        while !word.hasPrefix(prefix) {
            prefix = String(prefix.dropLast())
        }
    }
    return prefix
}

/*
 345. Reverse Vowels of a String = Easy
 Given a string s, reverse only all the vowels in the string and return it.

 The vowels are 'a', 'e', 'i', 'o', and 'u', and they can appear in both lower and upper cases, more than once.

 Example 1:
 Input: s = "IceCreAm"
 Output: "AceCreIm"
 Explanation: The vowels in s are ['I', 'e', 'e', 'A']. On reversing the vowels, s becomes "AceCreIm".

 Example 2:
 Input: s = "leetcode"
 Output: "leotcede"
 */
func reverseVowels(_ s: String) -> String {
    //have 2 pointers from beginning to end, and whenever vowel is seen, swap the vowels
    guard s.count > 1 else { return s }
    var start = 0
    var end = s.count - 1
    let vowels: Set<Character> = ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U"]
    var s = Array(s)
    while start < end {
        if vowels.contains(s[start]) && vowels.contains(s[end]) {
            s.swapAt(start, end)
            start += 1
            end -= 1
        } else if vowels.contains(s[start]) {
            end -= 1
        } else if vowels.contains(s[end]) {
            start += 1
        } else {
            start += 1
            end -= 1
        }
    }
    return String(s)
}

/*
 408. Valid Word Abbreviation = Easy
 A string can be abbreviated by replacing any number of non-adjacent, non-empty substrings with their lengths. The lengths should not have leading zeros.
 For example, a string such as "substitution" could be abbreviated as (but not limited to):

 "s10n" ("s ubstitutio n")
 "sub4u4" ("sub stit u tion")
 "12" ("substitution")
 "su3i1u2on" ("su bst i t u ti on")
 "substitution" (no substrings replaced)
 The following are not valid abbreviations:

 "s55n" ("s ubsti tutio n", the replaced substrings are adjacent)
 "s010n" (has leading zeros)
 "s0ubstitution" (replaces an empty substring)

 Given a string word and an abbreviation abbr, return whether the string matches the given abbreviation.
 A substring is a contiguous non-empty sequence of characters within a string.
 */

func validWordAbbreviation(_ word: String, _ abbr: String) -> Bool {
    var i = 0, j = 0
    let word = Array(word)
    let abbr = Array(abbr)
    while i < word.count && j < abbr.count {
        if let val = abbr[j].wholeNumberValue {
            guard val != 0 else { return false } //number cannot start with 0
            var num = 0
            while j < abbr.count, let digit = abbr[j].wholeNumberValue {
                num = num * 10 + digit
                j += 1
            }
            i += num //move i to num indicies
        } else {
            guard word[i] == abbr[j] else { return false }
            i += 1
            j += 1
        }
    }
    return i == word.count && j == abbr.count
}

/*
 771. Jewels and Stones = Easy
 You're given strings jewels representing the types of stones that are jewels, and stones representing the stones you have. Each character in stones is a type of stone you have. You want to know how many of the stones you have are also jewels.

 Letters are case sensitive, so "a" is considered a different type of stone from "A".

 Example 1:
 Input: jewels = "aA", stones = "aAAbbbb"
 Output: 3

 Example 2:
 Input: jewels = "z", stones = "ZZ"
 Output: 0
 */

func numJewelsInStones(_ jewels: String, _ stones: String) -> Int {
    var jewelCounter = 0
    for stone in stones {
        if jewels.contains(stone) {
            jewelCounter += 1
        }
    }
    return jewelCounter
}

/*
 Easy Challenges
 Reverse a String: Write a function to reverse a given string.

 Find Maximum in Array: Given an array of integers, find the maximum element.

 Check if a String is Palindrome: Determine if a given string is a palindrome.

 Sum of Array Elements: Calculate the sum of all elements in an array.

 Check if a Number is Prime: Write a function to check if a number is prime.

 Medium Challenges
 Find Duplicate in Array: Given an array of integers from 1 to n, where each integer appears once except for one that appears twice, find the duplicate number.

 Reverse Linked List: Write a function to reverse a singly linked list.

 Maximum Subarray: Find the maximum contiguous subarray of an array.

 First Non-Repeating Character: Given a string, find the first non-repeating character.

 Binary Search: Implement binary search to find an element in a sorted array.

 More Medium Challenges
 Validate Palindrome with Two Pointers: Given a string, determine if it is a palindrome using two pointers.

 Merge Two Sorted Lists: Merge two sorted linked lists into one sorted linked list.

 Find Missing Number: Given an array of integers from 1 to n, where one number is missing, find the missing number.

 Rotate Array: Rotate an array by a given number of positions.

 Minimum Window Substring: Find the minimum window substring that contains all characters of another string.

 Additional Medium Challenges
 Top K Frequent Elements: Given an array of integers, find the top k frequent elements.

 Validate IP Address: Write a function to validate whether a given string is a valid IP address.

 Find All Anagrams: Given a string and a pattern, find all anagrams of the pattern in the string.

 Longest Common Prefix: Find the longest common prefix among all strings in an array.

 Subarray with Given Sum: Given an array and a target sum, find if there exists a subarray with the given sum.
 */

//: [Next](@next)
