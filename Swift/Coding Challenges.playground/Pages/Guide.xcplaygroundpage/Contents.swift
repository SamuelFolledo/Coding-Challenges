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
 # Data Structure & Algorithm Guide
 A practical reference: signals, use cases, best approach rationale, alternatives, and examples.

 ---

 ## Part 1: Signal → Structure Quick Reference

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

 ---

 ## Part 2: Data Structures

 ---

 ### Array

 - **Access by index:** O(1)
 - **Insert/Delete at end:** O(1) amortized
 - **Insert/Delete at arbitrary index:** O(n)
 - **Search (unsorted):** O(n) — **Search (sorted):** O(log n)

 **Why Array wins:** O(1) random access lets two-pointer and sliding window algorithms jump
 between positions instantly. Index math is central to most array problems.

 **Alternative (less efficient):**
 - *Linked List* — O(n) to reach index i, killing any index-based algorithm
 - *Hash Map* — O(1) lookup but loses positional ordering

 **Applications:** Two Sum, Sliding Window Maximum, Trapping Rain Water, Product of Array Except Self
*/

// Example: Two Sum
// Brute force: try every pair — O(n²)
// Best: one pass with a hash map — O(n) time, O(n) space
func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var seen: [Int: Int] = [:]          // value → index
    for (i, num) in nums.enumerated() {
        let complement = target - num
        if let j = seen[complement] { return [j, i] }
        seen[num] = i
    }
    return []
}
print(twoSum([2, 7, 11, 15], 9))  // [0, 1]
print(twoSum([3, 2, 4], 6))       // [1, 2]

/*:
 ---

 ### Linked List

 - **Access by index:** O(n)
 - **Insert/Delete at head or given node:** O(1)
 - **Insert/Delete at tail (doubly, with tail pointer):** O(1)
 - **Search:** O(n)

 **Why Linked List wins:** Rewiring two pointers is O(1) regardless of list size.
 Arrays must shift all subsequent elements — O(n) — for the same operation.
 Paired with a hash map, it's the backbone of LRU/LFU caches.

 **Alternative (less efficient):**
 - *Array* — O(n) insert/delete in the middle due to shifting
 - *Dynamic Array* — same shifting cost; faster random access but irrelevant here

 **Applications:** LRU Cache, Merge K Sorted Lists, Reverse Linked List, Reorder List
*/

// Example 1: Detect Cycle in Linked List
// Brute force: hash set to track visited nodes — O(n) space
// Best: fast & slow pointers — O(n) time, O(1) space
func hasCycle(_ head: ListNode?) -> Bool {
    var slow = head, fast = head
    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
        if slow === fast { return true }
    }
    return false
}

// Example 2: Reverse a Linked List
// Iterative — O(n) time, O(1) space
func reverseList(_ head: ListNode?) -> ListNode? {
    var prev: ListNode? = nil
    var curr = head
    while curr != nil {
        let next = curr?.next
        curr?.next = prev
        prev = curr
        curr = next
    }
    return prev
}

/*:
 ---

 ### Stack (LIFO)

 - **Push / Pop / Peek:** all O(1)

 **Why Stack wins:** Whenever the most recently seen element is the one you need to compare
 against, a stack is the natural fit. "Last opened = first closed" — brackets, function calls,
 undo history — all follow LIFO. The current "pending" context is always at the top in O(1).

 **Alternative (less efficient):**
 - *Recursion* — implicitly uses the call stack; risks stack overflow on deep inputs
 - *Array with manual index* — equivalent but more verbose

 **Applications:** Valid Parentheses, Next Greater Element, Daily Temperatures, Min Stack, Evaluate Expression
*/

// Example 1: Valid Parentheses
// Brute force: repeatedly scan and remove matched pairs — O(n²)
// Best: push opens, pop and verify on each close — O(n)
func isValid(_ s: String) -> Bool {
    var stack: [Character] = []
    let pairs: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    for ch in s {
        if "([{".contains(ch) {
            stack.append(ch)
        } else {
            if stack.last != pairs[ch] { return false }
            stack.removeLast()
        }
    }
    return stack.isEmpty
}
print(isValid("()[]{}"))  // true
print(isValid("(]"))      // false
print(isValid("([)]"))    // false

// Example 2: Next Greater Element (monotonic stack)
// Brute force: for each element, scan right — O(n²)
// Best: monotonic decreasing stack — O(n)
func nextGreaterElement(_ nums: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: nums.count)
    var stack: [Int] = []   // stores indices
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

 - **Enqueue / Dequeue / Peek:** all O(1)

 **Why Queue wins:** BFS must process nodes in the order they were discovered — exactly FIFO.
 This guarantees that the first time you reach the target it's via the fewest steps.
 A deque extends this by supporting efficient removal from both ends (sliding window max).

 **Alternative (less efficient):**
 - *DFS* — finds a path but not the shortest in unweighted graphs
 - *Array used as queue* — O(n) dequeue due to element shifting

 **Applications:** Binary Tree Level Order, Shortest Path (unweighted), Sliding Window Maximum, Rotting Oranges
*/

// Example 1: Binary Tree Level Order Traversal
// DFS with depth tracking works but is harder to group by level
// Best: BFS — O(n), naturally produces level-grouped output
func levelOrder(_ root: TreeNode?) -> [[Int]] {
    guard let root = root else { return [] }
    var result: [[Int]] = []
    var queue: [TreeNode] = [root]
    while !queue.isEmpty {
        var level: [Int] = []
        let size = queue.count
        for _ in 0..<size {
            let node = queue.removeFirst()
            level.append(node.val)
            if let l = node.left  { queue.append(l) }
            if let r = node.right { queue.append(r) }
        }
        result.append(level)
    }
    return result
}

// Example 2: Sliding Window Maximum (Deque)
// Brute force: max of each window — O(n * k)
// Best: monotonic deque keeps max at front — O(n)
func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
    var deque: [Int] = []   // stores indices, decreasing by value
    var result: [Int] = []
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

 **Why Hash Map wins:** When you need to answer "have I seen X before?" or "how many times
 has X appeared?", a hash map gives you the answer in O(1). No other general-purpose
 structure matches this for pure lookup speed.

 **Alternative (less efficient):**
 - *Sorted array + binary search* — O(log n) lookup, O(n log n) to build
 - *Linear scan* — O(n) per query

 **Applications:** Two Sum, Group Anagrams, Top K Frequent Elements, Subarray Sum Equals K, LRU Cache
*/

// Example 1: Group Anagrams
// Brute force: compare every pair after sorting — O(n² * k log k)
// Best: sort each word as a key — O(n * k log k) where k = max word length
func groupAnagrams(_ strs: [String]) -> [[String]] {
    var map: [String: [String]] = [:]
    for s in strs {
        let key = String(s.sorted())
        map[key, default: []].append(s)
    }
    return Array(map.values)
}
print(groupAnagrams(["eat","tea","tan","ate","nat","bat"]))

// Example 2: Top K Frequent Elements
// Brute force: count then sort by frequency — O(n log n)
// Best: count with hash map, then bucket sort by frequency — O(n)
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

 ### Heap / Priority Queue

 - **Insert:** O(log n)
 - **Get min/max:** O(1)
 - **Extract min/max:** O(log n)
 - **Build from array:** O(n)

 Swift has no built-in Heap; use a manual array-based heap or `swift-collections`.

 **Why Heap wins:** For top-K problems, maintain a heap of size K — you only track what you
 need. Full sorting costs O(n log n) every time; a heap maintains the K best in O(log K) per update.

 **Alternative (less efficient):**
 - *Full sort each time* — O(n log n) per update vs O(log K)
 - *Linear scan for min/max* — O(n) per operation vs O(1) peek, O(log n) extract

 **Applications:** Kth Largest, Merge K Sorted Lists, Top K Frequent Words, Median from Data Stream, Dijkstra's
*/

// Example: Kth Largest Element (simulated with sort for clarity)
// Brute force: full sort — O(n log n)
// Optimal: min-heap of size k — O(n log k). Simulated here with sort for readability.
func findKthLargest(_ nums: [Int], _ k: Int) -> Int {
    return nums.sorted(by: >)[k - 1]
    // In production: maintain a min-heap of size k,
    // push each element, pop when size > k → top is the kth largest
}
print(findKthLargest([3, 2, 1, 5, 6, 4], 2))  // 5
print(findKthLargest([3, 2, 3, 1, 2, 4, 5, 5, 6], 4))  // 4

/*:
 ---

 ### Trie (Prefix Tree)

 All operations are **O(L)** where L = length of the word or prefix.

 - **Insert word**
 - **Search word (exact)**
 - **Search prefix**
 - **Delete word**

 **Why Trie wins:** A hash set can check exact matches in O(L) but can't answer "does any word
 start with 'pre'?" efficiently. A Trie naturally shares prefixes across words, making prefix
 queries O(L) regardless of how many words are stored.

 **Alternative (less efficient):**
 - *Hash Set* — O(L) exact match only, no prefix search
 - *Sorted array + binary search* — O(L log n) per prefix query
 - *Linear scan* — O(n * L) per query

 **Applications:** Implement Trie, Word Search II, Design Autocomplete, Replace Words, Search Suggestions System
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
        for ch in word {
            guard let next = node.children[ch] else { return false }
            node = next
        }
        return node.isEnd
    }

    func startsWith(_ prefix: String) -> Bool {
        var node = root
        for ch in prefix {
            guard let next = node.children[ch] else { return false }
            node = next
        }
        return true
    }
}

let trie = Trie()
trie.insert("apple")
trie.insert("app")
print(trie.search("apple"))    // true
print(trie.search("app"))      // true
print(trie.startsWith("ap"))   // true
print(trie.search("appl"))     // false

/*:
 ---

 ### Graph (Adjacency List)

 - **Add vertex/edge:** O(1)
 - **Remove edge:** O(degree)
 - **Remove vertex:** O(V + E)
 - **BFS/DFS traversal:** O(V + E)

 **Why Adjacency List wins:** For sparse graphs (most interview problems), it uses O(V + E)
 space. An adjacency matrix uses O(V²) — wasteful when most nodes aren't directly connected.

 **Alternative (less efficient):**
 - *Adjacency Matrix* — O(V²) space; good only for dense graphs or O(1) edge existence checks
 - *Edge List* — simple storage but O(E) to find neighbors of a node

 **Applications:** Number of Islands, Clone Graph, Course Schedule, Word Ladder, Pacific Atlantic Water Flow
*/

// Example: Number of Islands
// Given a 2D grid of '1' (land) and '0' (water), count distinct islands.
// DFS from each unvisited '1', marking visited cells — O(m * n)
func numIslands(_ grid: [[Character]]) -> Int {
    var grid = grid
    var count = 0

    func dfs(_ r: Int, _ c: Int) {
        guard r >= 0, r < grid.count, c >= 0, c < grid[0].count,
              grid[r][c] == "1" else { return }
        grid[r][c] = "0"   // mark visited
        dfs(r + 1, c); dfs(r - 1, c)
        dfs(r, c + 1); dfs(r, c - 1)
    }

    for r in 0..<grid.count {
        for c in 0..<grid[0].count {
            if grid[r][c] == "1" { count += 1; dfs(r, c) }
        }
    }
    return count
}
let islandGrid: [[Character]] = [
    ["1","1","0","0","0"],
    ["1","1","0","0","0"],
    ["0","0","1","0","0"],
    ["0","0","0","1","1"]
]
print(numIslands(islandGrid))  // 3

/*:
 ---

 ### Union-Find (Disjoint Set)

 With path compression + union by rank:
 - **Find** (which component?): O(α(n)) ≈ O(1) amortized
 - **Union** (connect two nodes): O(α(n)) ≈ O(1) amortized

 **Why Union-Find wins:** Running BFS/DFS for each connectivity query costs O(V + E) per
 query. Union-Find answers the same question in near-constant time after an O(n) setup.

 **Alternative (less efficient):**
 - *BFS/DFS per query* — O(V + E) per query vs O(1) amortized
 - *Adjacency matrix* — no built-in component tracking

 **Applications:** Number of Connected Components, Redundant Connection, Accounts Merge, Kruskal's MST, Friend Circles
*/

// Example: Number of Connected Components in an Undirected Graph
func countComponents(_ n: Int, _ edges: [[Int]]) -> Int {
    var parent = Array(0..<n)
    var rank   = Array(repeating: 0, count: n)

    func find(_ x: Int) -> Int {
        if parent[x] != x { parent[x] = find(parent[x]) }  // path compression
        return parent[x]
    }

    var components = n
    for edge in edges {
        let px = find(edge[0]), py = find(edge[1])
        guard px != py else { continue }
        if rank[px] < rank[py]      { parent[px] = py }
        else if rank[px] > rank[py] { parent[py] = px }
        else                        { parent[py] = px; rank[px] += 1 }
        components -= 1
    }
    return components
}
print(countComponents(5, [[0,1],[1,2],[3,4]]))   // 2
print(countComponents(5, [[0,1],[1,2],[2,3],[3,4]]))  // 1

/*:
 ---

 ## Part 3: Algorithm Patterns

 ---

 ### Two Pointers

 - **When:** sorted array, pair/triplet sum, palindrome check, removing duplicates in-place
 - **Complexity:** O(n)

 **Why Two Pointers wins:** Sorting gives us a guarantee — if the sum of the two pointers is
 too large, move the right pointer left; too small, move the left pointer right. One pass
 eliminates half the candidates per step instead of trying every pair.

 **Alternative (less efficient):**
 - *Nested loops* — O(n²), always correct but slow
 - *Hash map* — O(n) but uses O(n) extra space; two pointers is O(1) space

 **Applications:** Two Sum II (sorted input), 3Sum, Container With Most Water, Remove Duplicates from Sorted Array
*/

// Example: Container With Most Water
// Brute force: try every pair — O(n²)
// Best: start at both ends, always move the shorter side inward — O(n)
// Why? Moving the taller side can only decrease or maintain width while height won't improve.
func maxArea(_ height: [Int]) -> Int {
    var left = 0, right = height.count - 1, best = 0
    while left < right {
        let area = min(height[left], height[right]) * (right - left)
        best = max(best, area)
        if height[left] < height[right] { left += 1 } else { right -= 1 }
    }
    return best
}
print(maxArea([1,8,6,2,5,4,8,3,7]))  // 49

/*:
 ---

 ### Sliding Window

 - **When:** contiguous subarray/substring with a sum, count, or character constraint
 - **Complexity:** O(n)

 **Why Sliding Window wins:** Instead of recomputing the window state from scratch for every
 starting index (O(n²) or O(n³)), you slide the right pointer forward and shrink the left
 only when the constraint is violated. Each element enters and leaves the window at most once.

 **Alternative (less efficient):**
 - *Brute force nested loops* — O(n²) or O(n³)
 - *Prefix sums* — good for range sums on static arrays, but less flexible for character constraints

 **Applications:** Longest Substring Without Repeating Chars, Minimum Window Substring, Max Sum Subarray of Size K, Fruit Into Baskets
*/

// Example: Longest Substring Without Repeating Characters
// Brute force: check every substring — O(n³)
// Best: sliding window with last-seen index map — O(n)
func lengthOfLongestSubstring(_ s: String) -> Int {
    var lastSeen: [Character: Int] = [:]
    var maxLen = 0, left = 0
    let chars = Array(s)
    for right in 0..<chars.count {
        if let prev = lastSeen[chars[right]], prev >= left {
            left = prev + 1   // jump left past the duplicate
        }
        lastSeen[chars[right]] = right
        maxLen = max(maxLen, right - left + 1)
    }
    return maxLen
}
print(lengthOfLongestSubstring("abcabcbb"))  // 3
print(lengthOfLongestSubstring("pwwkew"))   // 3

/*:
 ---

 ### Binary Search

 - **When:** sorted data; or any monotonic condition you can binary-search on the answer
 - **Complexity:** O(log n)

 **Why Binary Search wins:** Each step eliminates half the remaining candidates. This also
 extends beyond arrays — any problem where you can ask "is X feasible?" and the answer
 flips from false to true at some threshold is binary-searchable on the answer value.

 **Alternative (less efficient):**
 - *Linear scan* — O(n); correct but doesn't exploit sorted order
 - *Hash set* — O(1) lookup for exact matches but loses ordering and can't handle range queries

 **Applications:** Search in Rotated Sorted Array, Find Minimum in Rotated Array, Koko Eating Bananas, Median of Two Sorted Arrays
*/

// Example: Search in Rotated Sorted Array
// Brute force: linear scan — O(n)
// Best: determine which half is sorted, then decide which half to search — O(log n)
func searchRotated(_ nums: [Int], _ target: Int) -> Int {
    var lo = 0, hi = nums.count - 1
    while lo <= hi {
        let mid = (lo + hi) / 2
        if nums[mid] == target { return mid }
        if nums[lo] <= nums[mid] {            // left half is sorted
            if nums[lo] <= target && target < nums[mid] { hi = mid - 1 }
            else { lo = mid + 1 }
        } else {                               // right half is sorted
            if nums[mid] < target && target <= nums[hi] { lo = mid + 1 }
            else { hi = mid - 1 }
        }
    }
    return -1
}
print(searchRotated([4,5,6,7,0,1,2], 0))  // 4
print(searchRotated([4,5,6,7,0,1,2], 3))  // -1

/*:
 ---

 ### BFS (Breadth-First Search)

 - **When:** shortest path in unweighted graph, level-order traversal, spreading/infection problems
 - **Complexity:** O(V + E)

 **Why BFS wins:** BFS explores all nodes at distance d before any at distance d+1, so the
 first time it reaches the target is guaranteed to be via the shortest path. DFS would find
 *a* path but not necessarily the shortest.

 **Alternative (less efficient):**
 - *DFS* — O(V + E) same complexity but doesn't guarantee shortest path
 - *Dijkstra* — correct for weighted graphs but O((V+E) log V) — overkill when all edges have equal weight

 **Applications:** Shortest Path (unweighted), Word Ladder, Rotting Oranges, Walls and Gates, Minimum Knight Moves
*/

// Example: Word Ladder — shortest transformation sequence from begin to end word
// BFS guarantees we find the shortest sequence first — O(n * L²) where L = word length
func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
    var wordSet = Set(wordList)
    guard wordSet.contains(endWord) else { return 0 }
    var queue = [(beginWord, 1)]
    var i = 0
    while i < queue.count {
        let (word, steps) = queue[i]; i += 1
        if word == endWord { return steps }
        var chars = Array(word)
        for j in 0..<chars.count {
            let original = chars[j]
            for c in "abcdefghijklmnopqrstuvwxyz" {
                chars[j] = c
                let next = String(chars)
                if wordSet.contains(next) {
                    queue.append((next, steps + 1))
                    wordSet.remove(next)
                }
            }
            chars[j] = original
        }
    }
    return 0
}
print(ladderLength("hit", "cog", ["hot","dot","dog","lot","log","cog"]))  // 5

/*:
 ---

 ### DFS / Backtracking

 - **When:** generate all possibilities (subsets, permutations, combinations), constraint satisfaction, path exploration
 - **Complexity:** O(branching^depth) — but pruning cuts branches early

 **Why Backtracking wins:** As soon as a partial solution violates a constraint, you prune
 that entire branch without exploring it. Pure brute force generates all candidates first
 then filters; backtracking does both simultaneously.

 **Alternative (less efficient):**
 - *Brute force generate-then-filter* — same complexity but no early pruning, slower in practice
 - *BFS for combinations* — uses exponentially more memory storing all partial states

 **Applications:** Subsets, Permutations, Combination Sum, N-Queens, Sudoku Solver, Word Search
*/

// Example 1: Generate All Subsets
func subsets(_ nums: [Int]) -> [[Int]] {
    var result: [[Int]] = []
    func backtrack(_ start: Int, _ current: inout [Int]) {
        result.append(current)
        for i in start..<nums.count {
            current.append(nums[i])
            backtrack(i + 1, &current)
            current.removeLast()
        }
    }
    var temp: [Int] = []
    backtrack(0, &temp)
    return result
}
print(subsets([1,2,3]))  // 8 subsets

// Example 2: Combination Sum (with pruning)
// Find all combinations that sum to target (can reuse elements)
func combinationSum(_ candidates: [Int], _ target: Int) -> [[Int]] {
    var result: [[Int]] = []
    let sorted = candidates.sorted()
    func backtrack(_ start: Int, _ remaining: Int, _ current: inout [Int]) {
        if remaining == 0 { result.append(current); return }
        for i in start..<sorted.count {
            if sorted[i] > remaining { break }   // pruning: no point continuing
            current.append(sorted[i])
            backtrack(i, remaining - sorted[i], &current)
            current.removeLast()
        }
    }
    var temp: [Int] = []
    backtrack(0, target, &temp)
    return result
}
print(combinationSum([2,3,6,7], 7))  // [[2,2,3],[7]]

/*:
 ---

 ### Dynamic Programming

 - **When:** find optimal value where subproblems overlap and optimal substructure holds
 - **Complexity:** typically O(n) to O(n²) — problem-dependent

 **Why DP wins:** Naive recursion recomputes the same subproblems exponentially. Memoizing
 each result means each unique subproblem is solved exactly once. This collapses O(2^n)
 recursive solutions into O(n) or O(n²) DP solutions.

 **Alternative (less efficient):**
 - *Naive recursion* — O(2^n) due to recomputation of overlapping subproblems
 - *Greedy* — only works when locally optimal choices always lead to the global optimum

 **Applications:** Coin Change, Longest Increasing Subsequence, Edit Distance, House Robber, Knapsack, Longest Common Subsequence
*/

// Example 1: Coin Change — minimum coins to make amount
// Naive recursion: O(amount^coins) — recomputes same amounts repeatedly
// DP bottom-up: build dp[0..amount], each state solved once — O(amount * coins)
func coinChange(_ coins: [Int], _ amount: Int) -> Int {
    var dp = Array(repeating: amount + 1, count: amount + 1)
    dp[0] = 0
    for i in 1...amount {
        for coin in coins where coin <= i {
            dp[i] = min(dp[i], dp[i - coin] + 1)
        }
    }
    return dp[amount] > amount ? -1 : dp[amount]
}
print(coinChange([1,5,10,25], 41))   // 4  (25+10+5+1)
print(coinChange([2], 3))            // -1

// Example 2: Longest Increasing Subsequence
// DP: O(n²) — for each i, check all j < i
// Optimal with patience sorting: O(n log n) — but O(n²) DP is the classic interview answer
func lengthOfLIS(_ nums: [Int]) -> Int {
    var dp = Array(repeating: 1, count: nums.count)
    for i in 1..<nums.count {
        for j in 0..<i where nums[j] < nums[i] {
            dp[i] = max(dp[i], dp[j] + 1)
        }
    }
    return dp.max() ?? 0
}
print(lengthOfLIS([10,9,2,5,3,7,101,18]))  // 4  (2,3,7,101 or 2,5,7,101)

/*:
 ---

 ### Greedy

 - **When:** locally optimal choice at each step provably leads to the globally optimal solution
 - **Complexity:** typically O(n) or O(n log n)

 **Why Greedy wins:** When the problem has the "greedy choice property," there's no need to
 explore subproblems. One forward pass makes each local decision optimally, achieving in O(n)
 what DP would solve in O(n²).

 **Alternative (less efficient):**
 - *DP* — always correct but overkill when the greedy property holds
 - *Backtracking* — exponential; explores all possible choices instead of committing greedily

 **Applications:** Jump Game, Interval Scheduling, Gas Station, Meeting Rooms, Assign Cookies, Huffman Coding
*/

// Example 1: Jump Game — can you reach the last index?
// DP: check all reachable previous positions — O(n²)
// Greedy: track the furthest index reachable so far — O(n)
func canJump(_ nums: [Int]) -> Bool {
    var maxReach = 0
    for i in 0..<nums.count {
        if i > maxReach { return false }          // can't reach index i
        maxReach = max(maxReach, i + nums[i])
    }
    return true
}
print(canJump([2,3,1,1,4]))  // true
print(canJump([3,2,1,0,4]))  // false

// Example 2: Non-overlapping Intervals — remove minimum intervals to make rest non-overlapping
// Greedy: sort by end time, greedily keep earliest-ending non-overlapping intervals
func eraseOverlapIntervals(_ intervals: [[Int]]) -> Int {
    let sorted = intervals.sorted { $0[1] < $1[1] }
    var count = 0, end = Int.min
    for interval in sorted {
        if interval[0] >= end { end = interval[1] }   // keep this interval
        else { count += 1 }                            // remove overlapping one
    }
    return count
}
print(eraseOverlapIntervals([[1,2],[2,3],[3,4],[1,3]]))  // 1

/*:
 ---

 ### Topological Sort

 - **When:** order nodes/tasks that have dependencies (directed acyclic graph)
 - **Complexity:** O(V + E)

 **Why Topological Sort wins:** Processes each node and edge exactly once. Also detects cycles
 as a side effect — if a cycle exists, not all nodes can be added to the ordering.

 **Alternative (less efficient):**
 - *Try all permutations and validate* — O(n! * E), completely impractical
 - *Naive DFS without systematic ordering* — doesn't produce a valid topological order

 **Applications:** Course Schedule, Task Dependencies, Alien Dictionary, Build Systems, Recipe Dependencies
*/

// Example: Course Schedule — can you finish all courses? (cycle detection in directed graph)
// Kahn's algorithm (BFS-based): process nodes with no incoming edges first — O(V + E)
func canFinish(_ numCourses: Int, _ prerequisites: [[Int]]) -> Bool {
    var inDegree = Array(repeating: 0, count: numCourses)
    var adj      = Array(repeating: [Int](), count: numCourses)
    for pre in prerequisites {
        adj[pre[1]].append(pre[0])
        inDegree[pre[0]] += 1
    }
    var queue = inDegree.indices.filter { inDegree[$0] == 0 }
    var processed = 0
    var i = 0
    while i < queue.count {
        let course = queue[i]; i += 1
        processed += 1
        for next in adj[course] {
            inDegree[next] -= 1
            if inDegree[next] == 0 { queue.append(next) }
        }
    }
    return processed == numCourses
}
print(canFinish(2, [[1,0]]))        // true
print(canFinish(2, [[1,0],[0,1]]))  // false — cycle

/*:
 ---

 ### Prefix Sum

 - **When:** repeated range-sum queries on a static array; subarray sum problems
 - **Complexity:** O(n) build, O(1) per query

 **Why Prefix Sum wins:** Build once in O(n), then any range sum `[i, j]` = `prefix[j+1] - prefix[i]`
 in O(1). Without it, each range query costs O(n). For subarray problems, pairing prefix sums
 with a hash map finds subarrays with a target sum in a single O(n) pass.

 **Alternative (less efficient):**
 - *Brute force range sum* — O(n) per query = O(n * q) total for q queries
 - *Segment Tree* — O(log n) per query, needed only when the array can be mutated between queries

 **Applications:** Range Sum Query, Subarray Sum Equals K, Product of Array Except Self, Number of Subarrays with Bounded Maximum
*/

// Example 1: Range Sum Query (immutable)
struct NumArray {
    private var prefix: [Int]
    init(_ nums: [Int]) {
        prefix = [0]
        for n in nums { prefix.append(prefix.last! + n) }
    }
    func sumRange(_ left: Int, _ right: Int) -> Int {
        return prefix[right + 1] - prefix[left]
    }
}
let numArray = NumArray([-2, 0, 3, -5, 2, -1])
print(numArray.sumRange(0, 2))   // 1  (-2+0+3)
print(numArray.sumRange(2, 5))   // -1 (3-5+2-1)

// Example 2: Subarray Sum Equals K
// Brute force: check every subarray — O(n²)
// Best: prefix sum + hash map — O(n). Key insight: if prefix[j] - prefix[i] == k, subarray [i,j] sums to k
func subarraySum(_ nums: [Int], _ k: Int) -> Int {
    var count = 0, prefixSum = 0
    var freq: [Int: Int] = [0: 1]   // empty prefix seen once
    for num in nums {
        prefixSum += num
        count += freq[prefixSum - k, default: 0]
        freq[prefixSum, default: 0] += 1
    }
    return count
}
print(subarraySum([1,1,1], 2))   // 2
print(subarraySum([1,2,3], 3))   // 2  ([1,2] and [3])

/*:
 ---

 ### Fast & Slow Pointers

 - **When:** cycle detection, finding the middle of a linked list, duplicate number detection
 - **Complexity:** O(n) time, O(1) space

 **Why Fast & Slow wins:** Two pointers moving at different speeds through a structure eliminates
 extra storage. For cycle detection: if there's a cycle, fast will lap slow and they'll meet.
 If there's no cycle, fast reaches the end. One pass, constant space.

 **Alternative (less efficient):**
 - *Hash set to track visited nodes* — O(n) time but O(n) extra space
 - *Two passes to find middle* — count nodes then walk half; fast & slow does it in one pass

 **Applications:** Linked List Cycle, Middle of Linked List, Happy Number, Find the Duplicate Number
*/

// Example 1: Find Middle of Linked List
// Brute force: count nodes, walk half — two passes
// Best: when fast reaches end, slow is at middle — one pass, O(1) space
func middleNode(_ head: ListNode?) -> ListNode? {
    var slow = head, fast = head
    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
    }
    return slow
}

// Example 2: Find Duplicate Number (in array 1..n with one duplicate)
// Hash set: O(n) space
// Fast & slow pointers (treat array values as "next" pointers): O(1) space — Floyd's cycle detection
func findDuplicate(_ nums: [Int]) -> Int {
    var slow = nums[0], fast = nums[0]
    repeat {
        slow = nums[slow]
        fast = nums[nums[fast]]
    } while slow != fast
    slow = nums[0]
    while slow != fast {
        slow = nums[slow]
        fast = nums[fast]
    }
    return slow
}
print(findDuplicate([1,3,4,2,2]))  // 2
print(findDuplicate([3,1,3,4,2]))  // 3

/*:
 ---

 ## Part 4: Sorting Algorithms

 ### Quick Sort
 - **Average:** O(n log n) — **Worst:** O(n²) (sorted input with bad pivot) — **Space:** O(log n) — **Stable:** No
 - **Best when:** general-purpose in-place sorting; randomized pivot avoids worst case in practice.
 - **Worse than Merge Sort when:** stability matters, or input is already/nearly sorted with a fixed pivot.

 ### Merge Sort
 - **Average:** O(n log n) — **Worst:** O(n log n) — **Space:** O(n) — **Stable:** Yes
 - **Best when:** guaranteed O(n log n), stability matters, or sorting a linked list (no random access needed).
 - **Worse than Quick Sort when:** O(n) extra space is a hard constraint.

 ### Heap Sort
 - **Average:** O(n log n) — **Worst:** O(n log n) — **Space:** O(1) — **Stable:** No
 - **Best when:** in-place sort with guaranteed O(n log n) and no extra memory.
 - **Worse than Quick Sort when:** cache locality matters (heap's access pattern is non-sequential).

 ### Insertion Sort
 - **Average:** O(n²) — **Worst:** O(n²) — **Space:** O(1) — **Stable:** Yes
 - **Best when:** input is small (n < ~20) or nearly sorted — adaptive, runs in O(n) for nearly-sorted input.
 - **Worse than Quick/Merge when:** n is large and data is random.

 ### Bubble Sort
 - **Average:** O(n²) — **Worst:** O(n²) — **Space:** O(1) — **Stable:** Yes
 - **Rarely used in practice** — Insertion Sort is always preferable for small inputs.
 - Know it conceptually; never justify using it in an interview.

 ---

 ## How to use this in an interview

 1. Restate the problem and constraints out loud.
 2. State the brute force and its complexity, even if you won't code it.
 3. Name the pattern that fits and *why* — point to the signal above.
 4. State target time/space complexity before writing any code.
 5. Code it, then verify your solution matches the complexity you promised.

 This sequence alone — even before you write a line of code — signals strong CS fundamentals.
*/

//: [Next](@next)
