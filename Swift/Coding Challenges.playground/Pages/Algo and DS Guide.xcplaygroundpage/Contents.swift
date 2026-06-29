//: [Previous](@previous)

import Foundation

// Shared types used across examples
class ListNode {
    var val: Int
    var next: ListNode?
    init(_ val: Int, _ next: ListNode? = nil) { self.val = val; self.next = next }
}

class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ val: Int) { self.val = val }
}

/*:
 # Data Structure & Algorithm Recognition Guide

 ---

 ## Part 1: How to recognize which one to use

 Scan the problem for these signal words before reaching for a structure.

 - **"Find if X exists", "count occurrences", "duplicates"** → Hash Map / Hash Set
 - **"Subarray/substring with sum/condition"** → Sliding Window, Prefix Sum
 - **Sorted array, "find target in O(log n)"** → Binary Search
 - **"Two numbers that sum to X"** → Hash Map (one-pass) or Two Pointers (if sorted)
 - **"Next/previous greater/smaller element"** → Stack (monotonic stack)
 - **"Top K", "Kth largest/smallest", "median of stream"** → Heap (priority queue)
 - **"Level order", "shortest path (unweighted)"** → BFS, Queue
 - **"All paths", "all combinations/permutations"** → DFS, Backtracking
 - **"Connected components", "islands", "cycles"** → DFS/BFS on Graph, Union-Find
 - **"Min/max with overlapping subproblems"** → Dynamic Programming
 - **"Make locally optimal choice", "intervals", "scheduling"** → Greedy
 - **"Parent-child", "hierarchy", "ancestor"** → Tree, DFS recursion
 - **"Prefix matching", "autocomplete"** → Trie
 - **"LRU/LFU cache"** → Hash Map + Doubly Linked List
 - **"Range queries", "cumulative sum"** → Prefix Sum, Segment Tree
 - **Need order preserved AND fast lookup** → Ordered Hash Map
 - **"Merge intervals", "insert interval"** → Sort first, then scan

 **Quick mental checklist:**
 1. What's being asked: existence, count, order, optimal value, or all possibilities?
 2. Constraints? n ≤ 10 → brute force. n ≤ 10⁴ → O(n²). n ≤ 10⁶+ → O(n) or O(n log n).
 3. Is input sorted, or can I sort it?
 4. Need repeated lookups? → Hash Map.
 5. Need min/max as things change? → Heap.
 6. Implied relationships between nodes? → Graph traversal.

 ---

 ## Part 2: Data Structures

 ### Array
 - **Access/Update by index:** O(1)
 - **Insert/Delete at end:** O(1) amortized
 - **Insert/Delete at arbitrary index:** O(n)
 - **Search (unsorted):** O(n) — **Search (sorted):** O(log n)

 **Use when:** fast random access, index math, two pointers, sliding window, prefix sums.
*/

// Two Sum — find indices of two numbers that add to target
// Brute force: try every pair — O(n²)
// Best: one-pass hash map — O(n) time, O(n) space
func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var seen: [Int: Int] = [:]
    for (i, num) in nums.enumerated() {
        if let j = seen[target - num] { return [j, i] }
        seen[num] = i
    }
    return []
}
print(twoSum([2, 7, 11, 15], 9))   // [0, 1]
print(twoSum([3, 2, 4], 6))        // [1, 2]

/*:
 ---

 ### Linked List
 - **Access by index:** O(n)
 - **Insert/Delete at head or given node:** O(1)
 - **Insert/Delete at tail (doubly + tail pointer):** O(1)
 - **Search:** O(n)

 **Use when:** frequent head/tail insertions, LRU cache backbone, no random access needed.
*/

// Reverse a Linked List — iterative, O(n) time O(1) space
func reverseList(_ head: ListNode?) -> ListNode? {
    var prev: ListNode? = nil, curr = head
    while curr != nil {
        let next = curr?.next
        curr?.next = prev
        prev = curr
        curr = next
    }
    return prev
}

// Detect Cycle — fast & slow pointers, O(n) time O(1) space
// Alternative: hash set of visited nodes — O(n) space
func hasCycle(_ head: ListNode?) -> Bool {
    var slow = head, fast = head
    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
        if slow === fast { return true }
    }
    return false
}

/*:
 ---

 ### Stack (LIFO)
 - **Push / Pop / Peek:** O(1)

 **Use when:** matching/nesting problems, "undo", monotonic stack, iterative DFS.
*/

// Valid Parentheses — push opens, pop and verify on each close
// Brute force: repeatedly scan and remove pairs — O(n²)
// Best: single pass stack — O(n)
func isValid(_ s: String) -> Bool {
    var stack: [Character] = []
    let pairs: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    for ch in s {
        if "([{".contains(ch) { stack.append(ch) }
        else {
            if stack.last != pairs[ch] { return false }
            stack.removeLast()
        }
    }
    return stack.isEmpty
}
print(isValid("()[]{}"))  // true
print(isValid("([)]"))    // false

// Next Greater Element — monotonic decreasing stack
// Brute force: scan right for each element — O(n²)
// Best: stack — O(n)
func nextGreaterElement(_ nums: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: nums.count)
    var stack: [Int] = []   // indices
    for i in 0..<nums.count {
        while !stack.isEmpty && nums[stack.last!] < nums[i] {
            result[stack.removeLast()] = nums[i]
        }
        stack.append(i)
    }
    return result
}
print(nextGreaterElement([2, 1, 2, 4, 3]))  // [4, 2, 4, -1, -1]

/*:
 ---

 ### Queue (FIFO) / Deque
 - **Enqueue / Dequeue / Peek:** O(1)

 **Use when:** BFS, level-order traversal, sliding window maximum (deque), task scheduling.
*/

// Binary Tree Level Order Traversal — BFS groups nodes by level naturally
func levelOrder(_ root: TreeNode?) -> [[Int]] {
    guard let root = root else { return [] }
    var result: [[Int]] = [], queue = [root]
    while !queue.isEmpty {
        var level: [Int] = []
        for _ in 0..<queue.count {
            let node = queue.removeFirst()
            level.append(node.val)
            if let l = node.left  { queue.append(l) }
            if let r = node.right { queue.append(r) }
        }
        result.append(level)
    }
    return result
}

// Sliding Window Maximum — monotonic deque keeps max at front
// Brute force: scan each window for max — O(n * k)
// Best: deque — O(n)
func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
    var deque: [Int] = [], result: [Int] = []
    for i in 0..<nums.count {
        while !deque.isEmpty && deque.first! < i - k + 1 { deque.removeFirst() }
        while !deque.isEmpty && nums[deque.last!] < nums[i] { deque.removeLast() }
        deque.append(i)
        if i >= k - 1 { result.append(nums[deque.first!]) }
    }
    return result
}
print(maxSlidingWindow([1,3,-1,-3,5,3,6,7], 3))  // [3,3,5,5,6,7]

/*:
 ---

 ### Hash Map / Hash Set (Swift: `Dictionary` / `Set`)
 - **Insert / Lookup / Update / Delete:** O(1) average, O(n) worst case

 **Use when:** O(1) lookups, frequency counting, grouping, caching, two-sum variants.
*/

// Group Anagrams — sort each word as a key
// Brute force: compare every pair — O(n² * k log k)
// Best: O(n * k log k) where k = max word length
func groupAnagrams(_ strs: [String]) -> [[String]] {
    var map: [String: [String]] = [:]
    for s in strs { map[String(s.sorted()), default: []].append(s) }
    return Array(map.values)
}
print(groupAnagrams(["eat","tea","tan","ate","nat","bat"]))

// Top K Frequent Elements — bucket sort by frequency
// Sort approach: O(n log n). Bucket sort: O(n)
func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
    var freq: [Int: Int] = [:]
    nums.forEach { freq[$0, default: 0] += 1 }
    var buckets = Array(repeating: [Int](), count: nums.count + 1)
    for (num, count) in freq { buckets[count].append(num) }
    var result: [Int] = []
    for i in stride(from: buckets.count - 1, through: 0, by: -1) {
        result.append(contentsOf: buckets[i])
        if result.count >= k { return Array(result.prefix(k)) }
    }
    return result
}
print(topKFrequent([1,1,1,2,2,3], 2))  // [1, 2]

/*:
 ---

 ### Binary Search Tree (balanced)
 - **Insert / Search / Delete:** O(log n)
 - **In-order traversal** (sorted order): O(n)

 **Use when:** sorted order must be maintained dynamically with fast insert/search/delete.
*/

// Validate Binary Search Tree
// Brute force: in-order traversal into array, then check sorted — O(n) space
// Best: pass min/max bounds down the tree — O(n) time, O(h) space
func isValidBST(_ root: TreeNode?) -> Bool {
    func validate(_ node: TreeNode?, _ min: Int?, _ max: Int?) -> Bool {
        guard let node = node else { return true }
        if let min = min, node.val <= min { return false }
        if let max = max, node.val >= max { return false }
        return validate(node.left, min, node.val) && validate(node.right, node.val, max)
    }
    return validate(root, nil, nil)
}

/*:
 ---

 ### Heap / Priority Queue
 - **Insert:** O(log n) — **Get min/max:** O(1) — **Extract min/max:** O(log n)
 - **Build from array:** O(n)

 Swift has no built-in heap; use a manual array-based implementation or `swift-collections`.

 **Use when:** Kth largest/smallest, top-K problems, streaming median, Dijkstra's.
*/

// Kth Largest Element
// Full sort: O(n log n). Min-heap of size k: O(n log k). Simulated with sort here:
func findKthLargest(_ nums: [Int], _ k: Int) -> Int {
    return nums.sorted(by: >)[k - 1]
    // Production: maintain a min-heap of size k — pop when size > k
}
print(findKthLargest([3,2,1,5,6,4], 2))            // 5
print(findKthLargest([3,2,3,1,2,4,5,5,6], 4))      // 4

/*:
 ---

 ### Trie (Prefix Tree)
 - All operations **O(L)** where L = word or prefix length

 **Use when:** prefix search, autocomplete, word existence checks across a large dictionary.
*/

class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isEnd = false
}
class Trie {
    private let root = TrieNode()
    func insert(_ word: String) {
        var node = root
        for ch in word {
            if node.children[ch] == nil { node.children[ch] = TrieNode() }
            node = node.children[ch]!
        }
        node.isEnd = true
    }
    func search(_ word: String) -> Bool {
        var node = root
        for ch in word { guard let n = node.children[ch] else { return false }; node = n }
        return node.isEnd
    }
    func startsWith(_ prefix: String) -> Bool {
        var node = root
        for ch in prefix { guard let n = node.children[ch] else { return false }; node = n }
        return true
    }
}
let trie = Trie()
trie.insert("apple"); trie.insert("app")
print(trie.search("apple"))     // true
print(trie.search("appl"))      // false
print(trie.startsWith("app"))   // true

/*:
 ---

 ### Graph (Adjacency List)
 - **Add vertex/edge:** O(1) — **Remove edge:** O(degree)
 - **BFS/DFS traversal:** O(V + E)

 **Use when:** relationships between entities — maps, social graphs, dependency graphs.
*/

// Number of Islands — DFS from each unvisited '1', mark visited as '0'
func numIslands(_ grid: [[Character]]) -> Int {
    var grid = grid, count = 0
    func dfs(_ r: Int, _ c: Int) {
        guard r >= 0, r < grid.count, c >= 0, c < grid[0].count,
              grid[r][c] == "1" else { return }
        grid[r][c] = "0"
        dfs(r+1,c); dfs(r-1,c); dfs(r,c+1); dfs(r,c-1)
    }
    for r in 0..<grid.count {
        for c in 0..<grid[0].count {
            if grid[r][c] == "1" { count += 1; dfs(r, c) }
        }
    }
    return count
}
let islandGrid: [[Character]] = [
    ["1","1","0","0"],
    ["1","1","0","0"],
    ["0","0","1","0"],
    ["0","0","0","1"]
]
print(numIslands(islandGrid))  // 3

/*:
 ---

 ### Union-Find (Disjoint Set)
 - **Find / Union:** O(α(n)) ≈ O(1) amortized (with path compression + union by rank)

 **Use when:** dynamic connectivity, counting components, cycle detection, Kruskal's MST.
*/

// Number of Connected Components
func countComponents(_ n: Int, _ edges: [[Int]]) -> Int {
    var parent = Array(0..<n), rank = Array(repeating: 0, count: n)
    func find(_ x: Int) -> Int {
        if parent[x] != x { parent[x] = find(parent[x]) }
        return parent[x]
    }
    var components = n
    for e in edges {
        let px = find(e[0]), py = find(e[1])
        guard px != py else { continue }
        rank[px] < rank[py] ? (parent[px] = py) :
        rank[px] > rank[py] ? (parent[py] = px) : { parent[py] = px; rank[px] += 1 }()
        components -= 1
    }
    return components
}
print(countComponents(5, [[0,1],[1,2],[3,4]]))        // 2
print(countComponents(5, [[0,1],[1,2],[2,3],[3,4]]))  // 1

/*:
 ---

 ## Part 3: Algorithm Patterns

 ### Two Pointers
 - **When:** sorted array, pair/triplet sum, remove duplicates, palindrome check
 - **Complexity:** O(n)
*/

// Container With Most Water
// Brute force: every pair — O(n²). Best: shrink from both ends — O(n)
func maxArea(_ height: [Int]) -> Int {
    var l = 0, r = height.count - 1, best = 0
    while l < r {
        best = max(best, min(height[l], height[r]) * (r - l))
        height[l] < height[r] ? (l += 1) : (r -= 1)
    }
    return best
}
print(maxArea([1,8,6,2,5,4,8,3,7]))  // 49

/*:
 ---

 ### Sliding Window
 - **When:** contiguous subarray/substring with a sum, count, or character constraint
 - **Complexity:** O(n)
*/

// Longest Substring Without Repeating Characters
// Brute force: check every substring — O(n³). Best: sliding window — O(n)
func lengthOfLongestSubstring(_ s: String) -> Int {
    var lastSeen: [Character: Int] = [:], maxLen = 0, left = 0
    let chars = Array(s)
    for r in 0..<chars.count {
        if let prev = lastSeen[chars[r]], prev >= left { left = prev + 1 }
        lastSeen[chars[r]] = r
        maxLen = max(maxLen, r - left + 1)
    }
    return maxLen
}
print(lengthOfLongestSubstring("abcabcbb"))  // 3
print(lengthOfLongestSubstring("pwwkew"))    // 3

/*:
 ---

 ### Binary Search
 - **When:** sorted data, or any monotonic "is X feasible?" condition
 - **Complexity:** O(log n)
*/

// Search in Rotated Sorted Array
// Linear scan: O(n). Modified binary search — determine which half is sorted: O(log n)
func searchRotated(_ nums: [Int], _ target: Int) -> Int {
    var lo = 0, hi = nums.count - 1
    while lo <= hi {
        let mid = (lo + hi) / 2
        if nums[mid] == target { return mid }
        if nums[lo] <= nums[mid] {
            nums[lo] <= target && target < nums[mid] ? (hi = mid - 1) : (lo = mid + 1)
        } else {
            nums[mid] < target && target <= nums[hi] ? (lo = mid + 1) : (hi = mid - 1)
        }
    }
    return -1
}
print(searchRotated([4,5,6,7,0,1,2], 0))  // 4
print(searchRotated([4,5,6,7,0,1,2], 3))  // -1

/*:
 ---

 ### BFS
 - **When:** shortest path in unweighted graph, level-order, spreading problems
 - **Complexity:** O(V + E)
*/

// Word Ladder — shortest transformation sequence
// BFS guarantees shortest path; DFS would find a path but not necessarily the shortest
func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
    var wordSet = Set(wordList)
    guard wordSet.contains(endWord) else { return 0 }
    var queue = [(beginWord, 1)], i = 0
    while i < queue.count {
        let (word, steps) = queue[i]; i += 1
        if word == endWord { return steps }
        var chars = Array(word)
        for j in 0..<chars.count {
            let orig = chars[j]
            for c in "abcdefghijklmnopqrstuvwxyz" {
                chars[j] = c
                let next = String(chars)
                if wordSet.contains(next) { queue.append((next, steps + 1)); wordSet.remove(next) }
            }
            chars[j] = orig
        }
    }
    return 0
}
print(ladderLength("hit", "cog", ["hot","dot","dog","lot","log","cog"]))  // 5

/*:
 ---

 ### DFS / Backtracking
 - **When:** all combinations/permutations/subsets, constraint satisfaction, path exploration
 - **Complexity:** O(branching^depth) — pruning cuts branches early
*/

// Subsets
func subsets(_ nums: [Int]) -> [[Int]] {
    var result: [[Int]] = []
    func bt(_ start: Int, _ curr: inout [Int]) {
        result.append(curr)
        for i in start..<nums.count {
            curr.append(nums[i]); bt(i + 1, &curr); curr.removeLast()
        }
    }
    var tmp: [Int] = []; bt(0, &tmp)
    return result
}
print(subsets([1,2,3]).count)  // 8

// Combination Sum (with pruning)
func combinationSum(_ candidates: [Int], _ target: Int) -> [[Int]] {
    var result: [[Int]] = []
    let sorted = candidates.sorted()
    func bt(_ start: Int, _ rem: Int, _ curr: inout [Int]) {
        if rem == 0 { result.append(curr); return }
        for i in start..<sorted.count {
            if sorted[i] > rem { break }
            curr.append(sorted[i]); bt(i, rem - sorted[i], &curr); curr.removeLast()
        }
    }
    var tmp: [Int] = []; bt(0, target, &tmp)
    return result
}
print(combinationSum([2,3,6,7], 7))  // [[2,2,3],[7]]

/*:
 ---

 ### Dynamic Programming
 - **When:** optimal value with overlapping subproblems + optimal substructure
 - **Complexity:** typically O(n) to O(n²)
*/

// Coin Change — minimum coins to make amount
// Naive recursion: O(amount^coins). DP bottom-up: O(amount * coins)
func coinChange(_ coins: [Int], _ amount: Int) -> Int {
    var dp = Array(repeating: amount + 1, count: amount + 1)
    dp[0] = 0
    for i in 1...amount {
        for coin in coins where coin <= i { dp[i] = min(dp[i], dp[i - coin] + 1) }
    }
    return dp[amount] > amount ? -1 : dp[amount]
}
print(coinChange([1,5,10,25], 41))  // 4  (25+10+5+1)
print(coinChange([2], 3))           // -1

// Longest Increasing Subsequence
func lengthOfLIS(_ nums: [Int]) -> Int {
    var dp = Array(repeating: 1, count: nums.count)
    for i in 1..<nums.count {
        for j in 0..<i where nums[j] < nums[i] { dp[i] = max(dp[i], dp[j] + 1) }
    }
    return dp.max() ?? 0
}
print(lengthOfLIS([10,9,2,5,3,7,101,18]))  // 4

/*:
 ---

 ### Greedy
 - **When:** locally optimal choice provably leads to the global optimum
 - **Complexity:** O(n) or O(n log n)
*/

// Jump Game — track furthest reachable index
// DP: O(n²). Greedy: O(n)
func canJump(_ nums: [Int]) -> Bool {
    var maxReach = 0
    for i in 0..<nums.count {
        if i > maxReach { return false }
        maxReach = max(maxReach, i + nums[i])
    }
    return true
}
print(canJump([2,3,1,1,4]))  // true
print(canJump([3,2,1,0,4]))  // false

// Non-overlapping Intervals — sort by end time, greedily keep earliest-ending intervals
func eraseOverlapIntervals(_ intervals: [[Int]]) -> Int {
    let sorted = intervals.sorted { $0[1] < $1[1] }
    var removed = 0, end = Int.min
    for iv in sorted {
        iv[0] >= end ? (end = iv[1]) : (removed += 1)
    }
    return removed
}
print(eraseOverlapIntervals([[1,2],[2,3],[3,4],[1,3]]))  // 1

/*:
 ---

 ### Topological Sort
 - **When:** order tasks/nodes that have dependencies (DAG)
 - **Complexity:** O(V + E)
*/

// Course Schedule — detect cycle using Kahn's BFS algorithm
func canFinish(_ numCourses: Int, _ prerequisites: [[Int]]) -> Bool {
    var inDegree = Array(repeating: 0, count: numCourses)
    var adj      = Array(repeating: [Int](), count: numCourses)
    for pre in prerequisites { adj[pre[1]].append(pre[0]); inDegree[pre[0]] += 1 }
    var queue = inDegree.indices.filter { inDegree[$0] == 0 }, processed = 0, i = 0
    while i < queue.count {
        let c = queue[i]; i += 1; processed += 1
        for next in adj[c] { inDegree[next] -= 1; if inDegree[next] == 0 { queue.append(next) } }
    }
    return processed == numCourses
}
print(canFinish(2, [[1,0]]))        // true
print(canFinish(2, [[1,0],[0,1]]))  // false (cycle)

/*:
 ---

 ### Prefix Sum
 - **When:** repeated range-sum queries on a static array; subarray sum problems
 - **Complexity:** O(n) build, O(1) per query
*/

// Subarray Sum Equals K
// Brute force: check every subarray — O(n²). Prefix sum + hash map: O(n)
func subarraySum(_ nums: [Int], _ k: Int) -> Int {
    var count = 0, prefix = 0, freq: [Int: Int] = [0: 1]
    for num in nums {
        prefix += num
        count += freq[prefix - k, default: 0]
        freq[prefix, default: 0] += 1
    }
    return count
}
print(subarraySum([1,1,1], 2))   // 2
print(subarraySum([1,2,3], 3))   // 2

/*:
 ---

 ### Fast & Slow Pointers
 - **When:** cycle detection, finding middle of a list, duplicate detection
 - **Complexity:** O(n) time, O(1) space
*/

// Find Middle of Linked List — one pass, O(1) space
// Alternative: count nodes then walk half — two passes
func middleNode(_ head: ListNode?) -> ListNode? {
    var slow = head, fast = head
    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
    }
    return slow
}

// Find Duplicate Number — Floyd's cycle detection on the array
// Hash set: O(n) space. Fast & slow: O(1) space
func findDuplicate(_ nums: [Int]) -> Int {
    var slow = nums[0], fast = nums[0]
    repeat { slow = nums[slow]; fast = nums[nums[fast]] } while slow != fast
    slow = nums[0]
    while slow != fast { slow = nums[slow]; fast = nums[fast] }
    return slow
}
print(findDuplicate([1,3,4,2,2]))  // 2
print(findDuplicate([3,1,3,4,2]))  // 3

/*:
 ---

 ## Part 4: Sorting Algorithms

 ### Quick Sort
 - **Average:** O(n log n) — **Worst:** O(n²) — **Space:** O(log n) — **Stable:** No
 - Best general-purpose in-place sort; randomized pivot avoids worst case.
 - Worse when stability matters or input is already sorted with a fixed pivot.

 ### Merge Sort
 - **Average:** O(n log n) — **Worst:** O(n log n) — **Space:** O(n) — **Stable:** Yes
 - Guaranteed O(n log n), ideal for linked lists and external sorting.
 - Worse when O(n) extra space is a hard constraint.

 ### Heap Sort
 - **Average:** O(n log n) — **Worst:** O(n log n) — **Space:** O(1) — **Stable:** No
 - In-place with guaranteed O(n log n). Poor cache locality in practice.

 ### Insertion Sort
 - **Average:** O(n²) — **Worst:** O(n²) — **Space:** O(1) — **Stable:** Yes
 - Adaptive — runs in O(n) for nearly-sorted input. Best for small arrays (n < ~20).

 ### Bubble Sort
 - **Average:** O(n²) — **Worst:** O(n²) — **Space:** O(1) — **Stable:** Yes
 - Rarely used in practice. Know it conceptually; prefer Insertion Sort for small inputs.

 ---

 ## How to use this in an interview

 1. Restate the problem and constraints out loud.
 2. State the brute force and its complexity, even if you won't code it.
 3. Name the pattern that fits and *why* — point to the signal from Part 1.
 4. State target time/space complexity before writing any code.
 5. Code it, then verify against the complexity you promised.

 This sequence alone signals strong CS fundamentals, even before you write a line of code.
*/

//: [Next](@next)
