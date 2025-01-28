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
//: [Next](@next)
