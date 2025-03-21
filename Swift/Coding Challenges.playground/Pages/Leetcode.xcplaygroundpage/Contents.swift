//: [Previous](@previous)

import Foundation

public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil; }
    public init(_ val: Int) { self.val = val; self.next = nil; }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
}

///Generated a node from an array where the first item is the tail
func generateNode(_ inputs: [Int], isReversed: Bool = false) -> ListNode? {
    let inputs = isReversed ? inputs : inputs.reversed()
    var resultNode: ListNode?
    for input in inputs {
        resultNode = ListNode(input, resultNode)
    }
    return resultNode
}

func printAllNodeValues(_ node: ListNode?) {
    var currentNode = node
    if let currentNode {
        let isLastItem: Bool = currentNode.next == nil
        if isLastItem {
            print(currentNode.val)
        } else {
            //print value with a comma and no new line
            print("\(currentNode.val),", terminator: "")
        }
    } else {
        print([])
    }
    if let nextNode = currentNode?.next {
        printAllNodeValues(nextNode)
    }
}

/*:
 ## 2. [Add Two Numbers](https://leetcode.com/problems/add-two-numbers/description/)
 The pair sum of a pair (a,b) is equal to a + b. The maximum pair sum is the largest pair sum in a list of pairs.

 - You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order, and each of their nodes contains a single digit. Add the two numbers and return the sum as a linked list.
 - You may assume the two numbers do not contain any leading zero, except the number 0 itself.

 #### Example 1:
 Input: l1 = [2,4,3], l2 = [5,6,4]
 Output: [7,0,8]
 Explanation: 342 + 465 = 807.

 #### Example 2:

 Input: l1 = [0], l2 = [0]
 Output: [0]

 #### Example 3:

 Input: l1 = [9,9,9,9,9,9,9], l2 = [9,9,9,9]
 Output: [8,9,9,9,0,0,0,1]
 */

func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode? {
    var node1 = l1
    var node2 = l2
    var numString1 = ""
    var numString2 = ""
    while node1 != nil {
        numString1 = String(node1!.val) + numString1
        node1 = node1!.next
    }
    while node2 != nil {
        numString2 = String(node2!.val) + numString2
        node2 = node2!.next
    }
    var total = 0
    if let num1 = NumberFormatter().number(from: numString1) {
        total += num1.intValue
    }
    if let num2 = NumberFormatter().number(from: numString2) {
        total += num2.intValue
    }
//    print("Add Two Numbers: \(numString1) + \(numString2) = \(total)")
    var totalString = String(total)
    var resultNode: ListNode?
    for (index, char) in totalString.enumerated() {
        resultNode = ListNode(Int(String(char))!, resultNode)
    }
    return resultNode
}

func testAddTwoNumbers() {
    print("\n2: Add Two Numbers")
    printAllNodeValues(addTwoNumbers(generateNode([2,4,3], isReversed: true), generateNode([5,6,4])))
    printAllNodeValues(addTwoNumbers(generateNode([0], isReversed: true), generateNode([0])))
    printAllNodeValues(addTwoNumbers(generateNode([9,9,9,9,9,9,9,9], isReversed: true), generateNode([9,9,9,9])))
}

testAddTwoNumbers()


/*:
 ## 21. [Merge Two Sorted Lists](https://leetcode.com/problems/merge-two-sorted-lists/description/)
 You are given the heads of two sorted linked lists list1 and list2.

 Merge the two lists into one sorted list. The list should be made by splicing together the nodes of the first two lists.

 Return the head of the merged linked list.

 Constraints:
 - The number of nodes in both lists is in the range [0, 50].
 - -100 <= Node.val <= 100
 - Both list1 and list2 are sorted in non-decreasing order.
 */

func mergeTwoLists(_ list1: [Int], _ list2: [Int]) {
    var sortedList = [Int]()
    var index1 = 0
    var index2 = 0
    while sortedList.count < list1.count + list2.count {
        if index1 == list1.count {
            sortedList.append(contentsOf: Array(list2[index2..<list2.count]))
        } else if index2 == list2.count {
            sortedList.append(contentsOf: Array(list1[index1..<list1.count]))
        } else {
            let item1 = list1[index1]
            let item2 = list2[index2]
            if item1 < item2 {
                sortedList.append(item1)
                index1 += 1
            } else {
                sortedList.append(item2)
                index2 += 1
            }
        }
    }
    print(sortedList)
}

func mergeTwoLists(_ list1: ListNode?, _ list2: ListNode?) -> ListNode? {
    guard let list1 = list1 else { return list2 }
    guard let list2 = list2 else { return list1 }
    var resultNode: ListNode?
    if list1.val < list2.val {
        resultNode = list1
        resultNode?.next = mergeTwoLists(list1.next, list2)
    } else {
        resultNode = list2
        resultNode?.next = mergeTwoLists(list1, list2.next)
    }
    return resultNode
}

func testMergeTwoLists() {
    print("\n21: Merge Two Sorted Lists (Int)")
    mergeTwoLists([1,4,5,9], [0,1,2,3,6,9]) //Output: [0, 1, 1, 2, 3, 4, 5, 6, 9, 9]
    mergeTwoLists([], [])
    mergeTwoLists([], [0])
    print("\n21: Merge Two Sorted Lists (LinkNode)")
    printAllNodeValues(mergeTwoLists(generateNode([1,2,4]), generateNode([1,3,4]))) //Output: [1,1,2,3,4,4]
    printAllNodeValues(mergeTwoLists(generateNode([1,4,5,9]), generateNode([0,1,2,3,6,9]))) //Output: [0, 1, 1, 2, 3, 4, 5, 6, 9, 9]
    printAllNodeValues(mergeTwoLists(generateNode([]), generateNode([]))) //Output: []
    printAllNodeValues(mergeTwoLists(generateNode([]), generateNode([0]))) //Output: [0]
}

testMergeTwoLists()

/*:
 ## 32. [Longest Valid Parentheses](https://leetcode.com/problems/longest-valid-parentheses/description/)
 Hard
 Given a string containing just the characters '(' and ')', return the length of the longest valid (well-formed) parentheses
 substring.

 #### Example 1:
 Input: s = "(()"
 Output: 2
 Explanation: The longest valid parentheses substring is "()".

 #### Example 2:
 Input: s = ")()())"
 Output: 4
 Explanation: The longest valid parentheses substring is "()()".

 #### Example 3:
 Input: s = ""
 Output: 0

 #### Constraints:
 0 <= s.length <= 3 * 104
 s[i] is '(', or ')'.
 */

func longestValidParentheses(_ s: String) -> Int {
    guard s.count >= 2 else { return 0 }
    var result = 0
    var counter = 0
    var hasOpen = false
    for i in 0..<s.count {
        let char = Array(s)[i]
        if hasOpen {
            if char == ")" {
                counter += 2
                if counter > result {
                    result = counter
                }
            } else {
                hasOpen = true
                counter = 0
            }
        }
        hasOpen = char == "("
    }
    return result
}

func testLongestValidParentheses() {
    print("\n32: Longest Valid Parentheses")
    print(longestValidParentheses("()")) //Output: 2
    print(longestValidParentheses("(()")) //Output: 2
    print(longestValidParentheses(")()())")) //Output: 4
    print(longestValidParentheses("")) //Output: 0
    print(longestValidParentheses("()(())")) //Output: 6
}
testLongestValidParentheses()

/*:
 ## 39. [Combination Sum](https://leetcode.com/problems/combination-sum/description/)
 Medium

 Given an array of distinct integers candidates and a target integer target, return a list of all unique combinations of candidates where the chosen numbers sum to target. You may return the combinations in any order.

 The same number may be chosen from candidates an unlimited number of times. Two combinations are unique if the
 frequency
 of at least one of the chosen numbers is different.

 The test cases are generated such that the number of unique combinations that sum up to target is less than 150 combinations for the given input.

 ### Example 1:
 Input: candidates = [2,3,6,7], target = 7
 Output: [[2,2,3],[7]]
 #### Explanation:
 2 and 3 are candidates, and 2 + 2 + 3 = 7. Note that 2 can be used multiple times.
 7 is a candidate, and 7 = 7.
 These are the only two combinations.
 
 ### Example 2:
 Input: candidates = [2,3,5], target = 8
 Output: [[2,2,2,2],[2,3,3],[3,5]]

 ### Example 3:
 Input: candidates = [2], target = 1
 Output: []


 ### Constraints:
 - 1 <= candidates.length <= 30
 - 2 <= candidates[i] <= 40
 - All elements of candidates are distinct.
 - 1 <= target <= 40
 */

func combinationSum(_ candidates: [Int], _ target: Int) -> [[Int]] {
    func helper(_ index: Int, _ left: Int) -> [[Int]] {
        if left < 0 { return [] }
        if left == 0 { return [[]]}
        if index >= candidates.count { return [] }
        var output = [[Int]]()
        output.append(contentsOf: helper(index, left - candidates[index]).map { $0 + [candidates[index]] })
        output.append(contentsOf: helper(index + 1, left))
        return output
    }
    return helper(0, target)
}

func testCombinationSum() {
    print("\n39: Combination Sum")
    print(combinationSum([2,3,6,7], 7)) //Output: [[2,2,3],[7]]
    print(combinationSum([2,3,5], 8)) //Output: [[2,2,2,2],[2,3,3],[3,5]]
    print(combinationSum([2], 1)) //Output: []
}
testCombinationSum()

/*
 164. Maximum Gap = Medium
 Given an integer array nums, return the maximum difference between two successive elements in its sorted form. If the array contains less than two elements, return 0.

 You must write an algorithm that runs in linear time and uses linear extra space.

 Example 1:
 Input: nums = [3,6,9,1]
 Output: 3
 Explanation: The sorted form of the array is [1,3,6,9], either (3,6) or (6,9) has the maximum difference 3.

 Example 2:
 Input: nums = [10]
 Output: 0
 Explanation: The array contains less than 2 elements, therefore return 0.
 */
func maximumGap(_ nums: [Int]) -> Int {
    guard nums.count > 1 else { return 0 }
    let nums = nums.sorted()
    var maxDifference = 0
    for i in 1..<nums.count {
        if maxDifference < nums[i] - nums[i - 1] {
            maxDifference = nums[i] - nums[i - 1]
        }
    }
    return maxDifference
}
//: [Next](@next)
