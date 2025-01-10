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

//: [Next](@next)
