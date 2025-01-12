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

//: [Next](@next)
