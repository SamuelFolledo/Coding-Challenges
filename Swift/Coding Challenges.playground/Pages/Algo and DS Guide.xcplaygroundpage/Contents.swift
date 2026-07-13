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
 <a id="top"></a>
 # Data Structure & Algorithm Recognition Guide

 ## Contents
 - [Part 1: How to Recognize Which One to Use](#part1)
 - [Part 2: Data Structures](#part2) — Array · Linked List · Stack · Queue · Hash Map · BST · Heap · Trie · Graph · Union-Find
 - [Part 3: Algorithm Patterns](#part3) — Two Pointers · Sliding Window · Binary Search · BFS · DFS · DP · Greedy · Topo Sort · Prefix Sum · Fast & Slow
 - [Part 4: Sorting Algorithms](#part4)
 - [Interview Tips](#tips)

 ---

 <a id="part1"></a>
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

 [↑ Back to Top](#top)

 ---

 <a id="part2"></a>
 ## Part 2: Data Structures

 ### Array
 - **Access/Update by index:** O(1)
 - **Insert/Delete at end:** O(1) amortized
 - **Insert/Delete at arbitrary index:** O(n)
 - **Search (unsorted):** O(n) — **Search (sorted):** O(log n)

 **Use when:** fast random access, index math, two pointers, sliding window, prefix sums.
*/

// Problem (LeetCode 1 — Two Sum): given an array of integers `nums` and an integer `target`,
// return the indices of the two numbers that add up to `target`. Assume exactly one solution
// exists and you may not use the same element twice.
// Brute force: try every pair — O(n²)
// Best: one-pass hash map — O(n) time, O(n) space
//
// How it works: walk the array once. At index i, compute the complement (target - num).
// If we've already seen that complement, we found our pair — return its stored index and i.
// Otherwise, remember this num's index in `seen` in case a later element needs it.
func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var seen: [Int: Int] = [:]   // value → index of numbers seen so far
    for (i, num) in nums.enumerated() {
        if let j = seen[target - num] {
            return [j, i]
        }
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

// Problem (LeetCode 206 — Reverse Linked List): given the head of a singly linked list,
// reverse the list in place and return the new head.
// Iterative — O(n) time, O(1) space
//
// How it works: walk the list once, re-pointing each node's `next` to the node before it
// (`prev`) instead of the node after it. `prev` and `curr` both march forward together;
// by the time `curr` runs off the end, `prev` is sitting on the new head.
func reverseList(_ head: ListNode?) -> ListNode? {
    var prev: ListNode? = nil
    var curr = head
    while curr != nil {
        let next = curr?.next   // save the rest of the list before we overwrite curr.next
        curr?.next = prev       // reverse the pointer
        prev = curr             // advance prev
        curr = next              // advance curr
    }
    return prev
}

// Problem (LeetCode 141 — Linked List Cycle): given the head of a linked list, determine
// whether the list has a cycle (some node's `next` eventually points back to an earlier node).
// Fast & slow pointers (Floyd's algorithm) — O(n) time, O(1) space
// Alternative: hash set of visited nodes — O(n) space
//
// How it works: `slow` advances one node per step, `fast` advances two. If there's no cycle,
// `fast` reaches the end (nil) first. If there IS a cycle, fast will eventually lap slow inside
// the loop and they'll land on the same node — like two runners on a circular track.
func hasCycle(_ head: ListNode?) -> Bool {
    var slow = head
    var fast = head
    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
        if slow === fast { return true }   // fast caught up to slow → cycle
    }
    return false
}

/*:
 ---

 ### Stack (LIFO)
 - **Push / Pop / Peek:** O(1)

 **Use when:** matching/nesting problems, "undo", monotonic stack, iterative DFS.
*/

// Problem (LeetCode 20 — Valid Parentheses): given a string containing just the characters
// '(', ')', '{', '}', '[', ']', determine whether every bracket is closed by the same type
// in the correct order (e.g. "([)]" is invalid even though counts match).
// Brute force: repeatedly scan and remove matched pairs — O(n²)
// Best: single pass stack — O(n)
//
// How it works: push every opening bracket. On a closing bracket, the top of the stack MUST
// be its matching opener (that's the most recently opened, still-unclosed bracket) — pop it
// if so, else the string is invalid. At the end the stack must be empty (nothing left open).
func isValid(_ s: String) -> Bool {
    var stack: [Character] = []
    let pairs: [Character: Character] = [")": "(", "]": "[", "}": "{"]
    for ch in s {
        if "([{".contains(ch) {
            stack.append(ch)
        } else {
            if stack.last != pairs[ch] {
                return false
            }
            stack.removeLast()
        }
    }
    return stack.isEmpty
}
print(isValid("()[]{}"))  // true
print(isValid("([)]"))    // false

// Problem (LeetCode 496 — Next Greater Element I / core idea): for each element in an array,
// find the first element to its right that is strictly greater; use -1 if none exists.
// Brute force: scan right for each element — O(n²)
// Best: monotonic decreasing stack — O(n)
//
// How it works: keep a stack of indices whose "next greater" hasn't been found yet, values
// strictly decreasing bottom-to-top. At index i, pop any stacked index whose value is less
// than nums[i] — nums[i] IS their next greater element. Then push i, since it now needs its
// own next-greater to be found later.
func nextGreaterElement(_ nums: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: nums.count)
    var stack: [Int] = []   // indices, values strictly decreasing bottom to top
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

// Problem (LeetCode 102 — Binary Tree Level Order Traversal): given the root of a binary
// tree, return the values of its nodes grouped level by level, top to bottom.
// BFS groups nodes by level naturally — O(n)
//
// How it works: the queue holds one level's worth of nodes at a time. Snapshot `queue.count`
// before the inner loop so we process exactly that level's nodes (not ones enqueued from the
// next level), collecting their values and pushing their children for the following round.
func levelOrder(_ root: TreeNode?) -> [[Int]] {
    guard let root = root else { return [] }
    var result: [[Int]] = []
    var queue = [root]
    while !queue.isEmpty {
        var level: [Int] = []
        for _ in 0..<queue.count {   // exactly this level's node count
            let node = queue.removeFirst()
            level.append(node.val)
            if let l = node.left  { queue.append(l) }
            if let r = node.right { queue.append(r) }
        }
        result.append(level)
    }
    return result
}

// Problem (LeetCode 239 — Sliding Window Maximum): given an array `nums` and a window size
// `k` that slides from the very left to the very right, return the maximum value in the
// window at each position.
// Brute force: scan each window for max — O(n * k)
// Best: monotonic decreasing deque keeps the max at the front — O(n)
//
// How it works: the deque stores indices with strictly decreasing values, front-to-back.
// Before adding index i: (1) drop the front index if it has slid outside the window,
// (2) drop back indices whose value is ≤ nums[i], since they can never be the max again
// while i is in the window. The front of the deque is always the current window's max.
func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
    var deque: [Int] = []   // indices, values strictly decreasing front to back
    var result: [Int] = []
    for i in 0..<nums.count {
        while !deque.isEmpty && deque.first! < i - k + 1 { deque.removeFirst() }  // out of window
        while !deque.isEmpty && nums[deque.last!] < nums[i] { deque.removeLast() } // stale smaller values
        deque.append(i)
        if i >= k - 1 {
            result.append(nums[deque.first!])   // front is always the window max
        }
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

// Problem (LeetCode 49 — Group Anagrams): given an array of strings, group the strings that
// are anagrams of each other (same letters, different order) into sublists.
// Brute force: compare every pair for anagram equality — O(n² * k log k)
// Best: sort each word to build a canonical key — O(n * k log k) where k = max word length
//
// How it works: two strings are anagrams iff their sorted characters are identical, so sorting
// each word gives a key shared by every anagram in that group. Bucket words into a dictionary
// by that key, then return all the buckets.
func groupAnagrams(_ strs: [String]) -> [[String]] {
    var map: [String: [String]] = [:]   // sorted-letters key → words matching that key
    for s in strs { map[String(s.sorted()), default: []].append(s) }
    return Array(map.values)
}
print(groupAnagrams(["eat","tea","tan","ate","nat","bat"])) // [["eat", "tea", "ate"], ["bat"], ["tan", "nat"]]

// Problem (LeetCode 347 — Top K Frequent Elements): given an integer array `nums` and an
// integer `k`, return the `k` most frequently occurring elements (any order).
// Sort-by-frequency approach: O(n log n)
// Best: count frequencies, then bucket sort by frequency — O(n)
//
// How it works: count how often each number appears, then create `buckets[count]` = list of
// numbers with that exact frequency (frequency can't exceed nums.count, so buckets are sized
// n+1). Walk buckets from highest frequency down, collecting numbers until we have k.
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

 ---

 #### Deep Dive: How Recursion Works (using `isValidBST`)

 **Problem (LeetCode 98 — Validate Binary Search Tree):** given the root of a binary tree,
 determine if it is a valid BST — for every node, ALL values in its left subtree must be
 strictly less than the node's value, and ALL values in its right subtree must be strictly
 greater, recursively (not just the immediate children).

 **Recursion in one sentence:** A function that calls itself on a *smaller* version of the same
 problem, stopping when it hits a **base case**.

 Every recursive function has exactly two parts:
 - **Base case** — the simplest possible input where you return directly (no more recursion)
 - **Recursive case** — break the problem into a smaller piece, call yourself, trust the result

 ---

 **Why naive parent-only checking fails:**

 ```
     5
    / \
   1   4   ← 4 is in the RIGHT subtree of 5, so it MUST be > 5. But 4 < 5 → INVALID
      / \
     3   6
 ```

 Just checking `node.val > node.left.val && node.val < node.right.val` at each node would
 pass node 4 (since 3 < 4 < 6 ✓) — but miss that 4 itself violates its ancestor's constraint.
 The fix: pass **accumulated bounds** down the tree on every call.

 ---

 **Recursive call tree for a valid BST:**

 ```
          4
         / \
        2   6
       / \ / \
      1  3 5  7

 validate(4, min:nil, max:nil)         root — no constraints yet
   ├─ validate(2, min:nil, max:4)      went LEFT  of 4 → tighten max to 4
   │    ├─ validate(1, min:nil, max:2) went LEFT  of 2 → tighten max to 2
   │    │    ├─ validate(nil,...) → true  ← BASE CASE (nil node is valid)
   │    │    └─ validate(nil,...) → true  ← BASE CASE
   │    │  returns true (1 passes nil < 1 < 2)
   │    └─ validate(3, min:2,  max:4)  went RIGHT of 2 → tighten min to 2
   │         ├─ validate(nil,...) → true  ← BASE CASE
   │         └─ validate(nil,...) → true  ← BASE CASE
   │       returns true (3 passes 2 < 3 < 4)
   │  returns true (2 passes nil < 2 < 4)
   └─ validate(6, min:4,  max:nil)     went RIGHT of 4 → tighten min to 4
        ├─ validate(5, min:4,  max:6)  went LEFT  of 6 → tighten max to 6
        │    ├─ validate(nil,...) → true  ← BASE CASE
        │    └─ validate(nil,...) → true  ← BASE CASE
        │  returns true (5 passes 4 < 5 < 6)
        └─ validate(7, min:6,  max:nil) went RIGHT of 6 → tighten min to 6
             ├─ validate(nil,...) → true  ← BASE CASE
             └─ validate(nil,...) → true  ← BASE CASE
           returns true (7 passes 6 < 7 < nil)
      returns true (6 passes 4 < 6 < nil)
 returns true ✓
 ```

 **The rule:** going **left** tightens the **max**. Going **right** tightens the **min**.
 Bounds accumulate — a node deep in the tree must satisfy every ancestor's constraint.

 **Key recursion insight — "trust the recursion":**
 When you write `validate(node.left, min, node.val)`, you don't need to think about what
 happens inside that call. You just need to trust that *if* the subtree is valid, it returns
 `true`, and *if* it's invalid, it returns `false`. Your only job at each call is:
 1. Handle the base case
 2. Check the current node
 3. Delegate the rest to the recursive calls
*/

// Build two test trees
//     4             5
//    / \           / \
//   2   6         1   4   ← INVALID (4 < 5 but in right subtree)
//  / \ / \           / \
// 1  3 5  7         3   6
let bstValid = TreeNode(4)
let bstN2 = TreeNode(2); let bstN6 = TreeNode(6)
let bstN1 = TreeNode(1); let bstN3 = TreeNode(3)
let bstN5 = TreeNode(5); let bstN7 = TreeNode(7)
bstValid.left = bstN2;  bstValid.right = bstN6
bstN2.left = bstN1;     bstN2.right = bstN3
bstN6.left = bstN5;     bstN6.right = bstN7

let bstInvalid = TreeNode(5)
let bstI1 = TreeNode(1); let bstI4 = TreeNode(4)
let bstI3 = TreeNode(3); let bstI6 = TreeNode(6)
bstInvalid.left = bstI1;  bstInvalid.right = bstI4
bstI4.left = bstI3;       bstI4.right = bstI6

// Clean version — O(n) time, O(h) space
func isValidBST(_ root: TreeNode?) -> Bool {
    func validate(_ node: TreeNode?, _ min: Int?, _ max: Int?) -> Bool {
        guard let node = node else { return true }           // base case: nil is always valid
        if let min = min, node.val <= min { return false }   // violates lower bound
        if let max = max, node.val >= max { return false }   // violates upper bound
        return validate(node.left,  min,       node.val) &&  // tighten max going left
               validate(node.right, node.val,  max)          // tighten min going right
    }
    return validate(root, nil, nil)
}
print(isValidBST(bstValid))    // true
print(isValidBST(bstInvalid))  // false

// Traced version — prints every recursive call so you can see the stack live
func isValidBSTTraced(_ root: TreeNode?) -> Bool {
    var depth = 0
    func validate(_ node: TreeNode?, _ min: Int?, _ max: Int?) -> Bool {
        let pad   = String(repeating: "  ", count: depth)
        let minS  = min.map { "min:\($0)" } ?? "min:nil"
        let maxS  = max.map { "max:\($0)" } ?? "max:nil"
        guard let node = node else {
            print("\(pad)nil → true  [base case]")
            return true
        }
        print("\(pad)validate(\(node.val), \(minS), \(maxS))")
        if let min = min, node.val <= min {
            print("\(pad)✗ \(node.val) ≤ \(min) → false")
            return false
        }
        if let max = max, node.val >= max {
            print("\(pad)✗ \(node.val) ≥ \(max) → false")
            return false
        }
        depth += 1
        let leftOk  = validate(node.left,  min,       node.val)
        let rightOk = validate(node.right, node.val,  max)
        depth -= 1
        print("\(pad)✓ \(node.val) → \(leftOk && rightOk)")
        return leftOk && rightOk
    }
    return validate(root, nil, nil)
}

print("\n--- Valid BST trace ---")
_ = isValidBSTTraced(bstValid)

print("\n--- Invalid BST trace (catches 4 violating min bound of 5) ---")
_ = isValidBSTTraced(bstInvalid)

/*:
 ---

 ### Heap / Priority Queue
 - **Insert:** O(log n) — **Get min/max:** O(1) — **Extract min/max:** O(log n)
 - **Build from array:** O(n)

 Swift has no built-in heap; use a manual array-based implementation or `swift-collections`.

 **Use when:** Kth largest/smallest, top-K problems, streaming median, Dijkstra's.
*/

// Problem (LeetCode 215 — Kth Largest Element in an Array): given an integer array `nums`
// and an integer `k`, return the kth largest element in sorted order (not the kth distinct
// element — duplicates count separately).
// Full sort: O(n log n). Min-heap of size k: O(n log k). Simulated with sort here:
//
// How it works (production version): sort descending and index k-1. In production you'd
// instead maintain a min-heap of size k — push each number, and whenever the heap exceeds
// size k, pop the smallest. After processing all numbers, the heap's root is the kth largest.
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

// Problem (LeetCode 208 — Implement Trie): implement a prefix tree supporting insert(word),
// search(word) (exact match), and startsWith(prefix) (does any inserted word start with this?).
//
// How it works: each TrieNode holds a dictionary of child nodes keyed by the next character,
// plus a flag marking "a word ends here." insert walks/creates a chain of nodes, one per
// character, then marks the last node as a word end. search walks the same chain and requires
// both a matching path AND the final node's isEnd flag. startsWith only requires the path to
// exist — it doesn't check isEnd, since a valid prefix need not itself be a complete word.
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

// Problem (LeetCode 200 — Number of Islands): given a 2D grid of '1' (land) and '0' (water),
// count the number of islands, where an island is land connected horizontally/vertically.
// DFS from each unvisited '1', mark visited as '0' — O(m * n)
//
// How it works: scan every cell; whenever we find an unvisited '1', that's a brand-new
// island, so increment the count and flood-fill outward with DFS, turning every connected
// '1' into '0' so it's never counted again.
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

// Problem (LeetCode 323 — Number of Connected Components in an Undirected Graph): given `n`
// nodes labeled 0 to n-1 and a list of undirected edges, count the number of connected
// components.
//
// How it works: start with each node as its own component (parent[x] == x). For every edge,
// find() each endpoint's root (with path compression, flattening the tree for future speed)
// and union() them by rank (attach the shorter tree under the taller one to keep trees flat).
// Merging two previously-separate roots means one fewer component; skip edges whose endpoints
// already share a root.
func countComponents(_ n: Int, _ edges: [[Int]]) -> Int {
    var parent = Array(0..<n), rank = Array(repeating: 0, count: n)
    func find(_ x: Int) -> Int {
        if parent[x] != x { parent[x] = find(parent[x]) }   // path compression
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

 [↑ Back to Top](#top)

 ---

 <a id="part3"></a>
 ## Part 3: Algorithm Patterns

 ### Two Pointers
 - **When:** sorted array, pair/triplet sum, remove duplicates, palindrome check
 - **Complexity:** O(n)
*/

// Problem (LeetCode 11 — Container With Most Water): given an array `height` where
// height[i] is the height of a vertical line at position i, find two lines that, together
// with the x-axis, form a container holding the most water. Return that max area.
// Brute force: every pair — O(n²). Best: shrink from both ends — O(n)
//
// How it works: start with the widest possible container (both ends). Area is limited by the
// SHORTER of the two lines, so moving the taller pointer inward can only lose width without
// ever gaining height — it can't improve the answer. Moving the shorter pointer inward is the
// only move that could find a taller line and possibly a bigger area, so always move it.
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

// Problem (LeetCode 3 — Longest Substring Without Repeating Characters): given a string `s`,
// find the length of the longest contiguous substring with no repeated characters.
// Brute force: check every substring for duplicates — O(n³). Best: sliding window — O(n)
//
// How it works: expand the window by moving `right` forward one character at a time. If that
// character was already seen at-or-after `left` (i.e. inside the current window), jump `left`
// to just past its previous occurrence — this instantly removes the duplicate without
// rescanning. Track the max window size seen at every step.
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

// Problem (LeetCode 33 — Search in Rotated Sorted Array): given an ascending array that was
// rotated at some unknown pivot (e.g. [4,5,6,7,0,1,2]) and a target value, return the
// target's index, or -1 if it isn't present. Must run in O(log n).
// Linear scan: O(n). Modified binary search — determine which half is sorted: O(log n)
//
// How it works: at each step, at least one half of [lo, mid] or [mid, hi] is guaranteed to be
// normally sorted (the rotation point can only be in one half). Check which half is sorted by
// comparing nums[lo] to nums[mid]; if the target falls within that sorted half's range,
// search there — otherwise it must be in the other half.
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

// Problem (LeetCode 127 — Word Ladder): given `beginWord`, `endWord`, and a `wordList`,
// find the length of the shortest transformation sequence from beginWord to endWord where
// each step changes exactly one letter and every intermediate word must exist in wordList.
// Return 0 if no such sequence exists.
// BFS guarantees shortest path; DFS would find a path but not necessarily the shortest
//
// How it works: treat each word as a graph node and each valid one-letter transformation as
// an edge. BFS explores level by level (all words reachable in 1 step, then 2 steps, ...), so
// the first time we dequeue endWord we know it's via the fewest steps. For each word, try
// swapping every position to every letter a-z, checking if the result is still in the
// (shrinking) word set — removing matches immediately prevents revisiting them.
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

// Problem (LeetCode 78 — Subsets): given an array of unique integers, return all possible
// subsets (the power set) — 2^n subsets total, including the empty set and the full array.
//
// How it works: `result.append(curr)` records the current partial subset at every level of
// recursion (not just at the leaves) — that's what captures subsets of every size, not just
// the full-length ones. The loop then tries adding each remaining element in turn, recurses
// with `start = i + 1` so we never reuse an earlier index, and backtracks (`removeLast()`)
// to restore `curr` before trying the next candidate.
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

// Problem (LeetCode 39 — Combination Sum): given an array of distinct positive integers
// `candidates` and a `target`, return all unique combinations that sum to target. The same
// number may be reused unlimited times.
// (with pruning)
//
// How it works: sorting first lets us prune early — once sorted[i] exceeds the remaining
// target, every later (larger) candidate would too, so we `break` out of the loop entirely.
// Passing `i` (not `i + 1`) as the next `start` allows reusing the same element again. When
// `remaining` hits exactly 0, the current combination is recorded.
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

// Problem (LeetCode 322 — Coin Change): given coin denominations `coins` and a target
// `amount`, return the fewest coins needed to make that amount (coins can repeat), or -1 if
// it's impossible.
// Naive recursion: O(amount^coins) — recomputes the same sub-amounts repeatedly
// DP bottom-up: O(amount * coins)
//
// How it works: dp[i] = minimum coins to make amount i, seeded with a sentinel (amount + 1,
// an impossible-to-reach value standing in for "infinity") and dp[0] = 0 (zero coins for zero
// amount). For each amount i, try every coin ≤ i: if we use that coin, we need
// dp[i - coin] + 1 coins — keep the minimum across all coin choices. dp[amount] is the answer,
// unless it never improved past the sentinel, meaning amount is unreachable.
func coinChange(_ coins: [Int], _ amount: Int) -> Int {
    var dp = Array(repeating: amount + 1, count: amount + 1)   // amount+1 = "unreachable" sentinel
    dp[0] = 0
    for i in 1...amount {
        for coin in coins where coin <= i { dp[i] = min(dp[i], dp[i - coin] + 1) }
    }
    return dp[amount] > amount ? -1 : dp[amount]
}
print(coinChange([1,5,10,25], 41))  // 4  (25+10+5+1)
print(coinChange([2], 3))           // -1

// Problem (LeetCode 300 — Longest Increasing Subsequence): given an integer array `nums`,
// return the length of the longest strictly increasing subsequence (elements need not be
// contiguous, just in increasing order and original relative order).
//
// How it works: dp[i] = length of the longest increasing subsequence that ENDS at index i,
// starting at 1 (each element is a subsequence of length 1 by itself). For each i, look back
// at every earlier j; if nums[j] < nums[i], i could extend that subsequence, so
// dp[i] = max(dp[i], dp[j] + 1). The answer is the largest value across all dp[i], since the
// longest subsequence overall could end anywhere.
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

// Problem (LeetCode 55 — Jump Game): given an array `nums` where nums[i] is the max jump
// length from index i, determine if you can reach the last index starting from index 0.
// DP: O(n²). Greedy: O(n)
//
// How it works: track the furthest index reachable so far. At each index i, if i is already
// beyond maxReach, we could never have jumped this far — return false. Otherwise update
// maxReach to the farther of itself or i + nums[i] (how far a jump from here could go).
// Reaching the end of the loop without failing means the last index is reachable.
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

// Problem (LeetCode 435 — Non-overlapping Intervals): given a collection of intervals,
// return the minimum number that must be removed so the rest don't overlap.
// Greedy: sort by end time, greedily keep earliest-ending non-overlapping intervals
//
// How it works: sorting by end time means the first interval always ends soonest, leaving the
// most room for everything after it — the greedy-optimal choice to keep. Walk the sorted list
// keeping a running `end`; if the next interval starts at or after `end` it doesn't overlap,
// so keep it and advance `end`. Otherwise it overlaps the one we kept, so count it as removed
// (and implicitly discard it, since `end` stays put).
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

// Problem (LeetCode 207 — Course Schedule): given `numCourses` and a list of prerequisite
// pairs [a, b] meaning "must take b before a," determine if it's possible to finish all
// courses (i.e. the prerequisite graph has no cycle).
// Detect cycle using Kahn's BFS topological sort algorithm — O(V + E)
//
// How it works: build a graph where edges point from prerequisite → dependent course, and
// track each course's in-degree (number of unmet prerequisites). Start a queue with every
// course that has zero prerequisites — those can be taken immediately. Process the queue:
// "taking" a course decrements its dependents' in-degrees, and any dependent that drops to
// zero becomes takeable, so enqueue it. If every course eventually gets processed, there's no
// cycle; if some remain stuck at in-degree > 0, they're part of an unresolvable cycle.
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

// Problem (LeetCode 560 — Subarray Sum Equals K): given an integer array `nums` and an
// integer `k`, return the total number of contiguous subarrays whose elements sum to k.
// Brute force: check every subarray — O(n²). Prefix sum + hash map: O(n)
//
// How it works: `prefix` is the running sum of everything seen so far — the sum of any
// subarray [i+1, j] equals prefix(j) - prefix(i). So for the current prefix, we ask "was there
// an earlier prefix equal to (current prefix - k)?" — if so, the subarray between that earlier
// point and now sums to exactly k. `freq` counts how many times each prefix value has occurred
// (seeded with prefix 0 occurring once, representing "before the array starts," so subarrays
// starting at index 0 are counted correctly).
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

// Problem (LeetCode 876 — Middle of the Linked List): given the head of a singly linked
// list, return its middle node (the second of the two middles if the length is even).
// One pass, O(1) space. Alternative: count nodes then walk half — two passes
//
// How it works: `fast` moves twice as fast as `slow`. By the time `fast` reaches the end of
// the list, `slow` has covered exactly half the distance — landing on the middle node.
func middleNode(_ head: ListNode?) -> ListNode? {
    var slow = head, fast = head
    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
    }
    return slow
}

// Problem (LeetCode 287 — Find the Duplicate Number): given an array of n+1 integers where
// each value is in [1, n], exactly one value repeats (possibly more than once) — find it
// without modifying the array and using O(1) extra space.
// Hash set: O(n) space. Fast & slow (Floyd's cycle detection): O(1) space
//
// How it works: treat each value nums[i] as a "pointer" to index nums[i] — since a value
// repeats, this implicit linked list must contain a cycle, and the duplicate value is exactly
// the cycle's entry point. First loop: advance slow by 1 and fast by 2 until they meet
// somewhere inside the cycle. Second loop: reset slow to the start and advance both by 1 —
// they're now guaranteed to meet exactly at the cycle's entry point (a classic property of
// Floyd's algorithm), which is the duplicate number.
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

 [↑ Back to Top](#top)

 ---

 <a id="part4"></a>
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

 <a id="tips"></a>
 ## How to use this in an interview

 1. Restate the problem and constraints out loud.
 2. State the brute force and its complexity, even if you won't code it.
 3. Name the pattern that fits and *why* — point to the signal from Part 1.
 4. State target time/space complexity before writing any code.
 5. Code it, then verify against the complexity you promised.

 This sequence alone signals strong CS fundamentals, even before you write a line of code.

 ---

 [↑ Back to Top](#top)
*/

//: [Next](@next)
