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
func generateNode(_ inputs: [Int]) -> ListNode? {
    var resultNode: ListNode?
    for input in inputs {
        resultNode = ListNode(input, resultNode)
    }
    return resultNode
}

func printAllNode(_ node: ListNode?, isReversed: Bool = true) {
    var currentNode = node
    if let currentNode {
        let isLastItem: Bool = currentNode.next == nil
        if isLastItem {
            print(currentNode.val)
        } else {
            //print value with a comma and no new line
            print("\(currentNode.val),", terminator: "")
        }
    }
    if let nextNode = currentNode?.next {
        printAllNode(nextNode)
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
    printAllNode(addTwoNumbers(generateNode([2,4,3]), generateNode([5,6,4])))
    printAllNode(addTwoNumbers(generateNode([2,4,3]), generateNode([5,6,4])))
    printAllNode(addTwoNumbers(generateNode([0]), generateNode([0])))
    printAllNode(addTwoNumbers(generateNode([9,9,9,9,9,9,9,9]), generateNode([9,9,9,9])))
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

func mergeTwoLists(_ list1: ListNode?, _ list2: ListNode?) -> ListNode? {
    var resultNode: ListNode?
    
    return resultNode
}
func testMergeTwoLists() {
    mergeTwoLists(generateNode([1,2,4]), generateNode([1,3,4])) //Output: [1,1,2,3,4,4]
    mergeTwoLists(generateNode([]), generateNode([])) //Output: []
    mergeTwoLists(generateNode([]), generateNode([0])) //Output: [0]
}

testMergeTwoLists()

//: [Next](@next)
