//: [Previous](@previous)

import Foundation

public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil; }
    public init(_ val: Int) { self.val = val; self.next = nil; }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next; }
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

///Generated a node from an array where the first item is the tail
func generateNode(_ inputs: [Int]) -> ListNode? {
    var resultNode: ListNode?
    for input in inputs {
        resultNode = ListNode(input, resultNode)
    }
    return resultNode
}

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
    print("Add Two Numbers: \(numString1) + \(numString2) = \(total)")
    var totalString = String(total)
    var resultNode: ListNode?
    for (index, char) in totalString.enumerated() {
        resultNode = ListNode(Int(String(char))!, resultNode)
    }
    return resultNode
}

func testAddTwoNumbers() {
    addTwoNumbers(generateNode([2,4,3]), generateNode([5,6,4]))
    addTwoNumbers(generateNode([0]), generateNode([0]))
    addTwoNumbers(generateNode([9,9,9,9,9,9,9,9]), generateNode([9,9,9,9]))
}

testAddTwoNumbers()


//: [Next](@next)
