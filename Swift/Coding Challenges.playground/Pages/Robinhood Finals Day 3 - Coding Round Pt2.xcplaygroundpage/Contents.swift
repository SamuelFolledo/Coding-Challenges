//: [Previous](@previous)

import Foundation

/*:
 # Robinhood Finals — Day 3: Technical Screen, Part 2 — iOS-Flavored Problems & Debugging

 ## Contents
 - Part 1: Problem 1 — LRU Cache (design, very relevant to iOS image/data caching)
 - Part 2: Problem 2 — Linked List Cycle Detection (Floyd's)
 - Part 3: Problem 3 — Binary Tree Level Order Traversal (BFS)
 - Part 4: Problem 4 — Top K Frequent Elements (heap / bucket sort)
 - Part 5: Problem 5 — Debounce (directly reusable in the project call)
 - Part 6: Live debugging drill — find the bug
 - Part 7: How to talk about execution & debugging out loud

 ---

 ## Part 1: Problem 1 — LRU Cache

 > **Problem:** Design a cache with a fixed capacity. `get(key)` returns the value or -1 if absent,
 > and marks the key as most-recently-used. `put(key, value)` inserts/updates and evicts the least
 > recently used entry when over capacity. Both operations must be O(1).

 This is the single most "real iOS" Leetcode problem — it's the mental model behind `NSCache`,
 image caches, and any bounded in-memory cache. Say that out loud; it's a strong signal.

 The O(1) trick: a dictionary for O(1) lookup, plus a doubly linked list to track recency in O(1)
 (arrays would be O(n) to move an element to the front/back).

 **This version is instrumented with `print` statements** — run this playground page in Xcode and
 watch the console. Every `get`/`put` prints what kind of operation it did (CREATE / UPDATE / MOVE /
 EVICT / MISS) and the full list state, head to tail, afterward. Trace it against the walkthrough
 discussed earlier until the pointer movements stop feeling fuzzy.
*/

final class LRUCache {
    private final class Node {
        let key: Int
        var value: Int
        var prev: Node?
        var next: Node?
        init(key: Int, value: Int) {
            self.key = key
            self.value = value
        }
    }

    private let capacity: Int
    private var map: [Int: Node] = [:]
    private let head = Node(key: -1, value: -1)   // dummy, most-recently-used side
    private let tail = Node(key: -1, value: -1)   // dummy, least-recently-used side

    init(_ capacity: Int) {
        self.capacity = capacity
        head.next = tail
        tail.prev = head
        print("CREATE LRUCache(capacity: \(capacity))")
        print("   \(snapshot())\n")
    }

    func get(_ key: Int) -> Int {
        guard let node = map[key] else {
            print("GET(\(key)) → MISS, not in cache, returns -1")
            print("   \(snapshot())\n")
            return -1
        }
        moveToFront(node)
        print("GET(\(key)) → HIT, value=\(node.value); MOVE to front (now most-recently-used)")
        print("   \(snapshot())\n")
        return node.value
    }

    func put(_ key: Int, _ value: Int) {
        if let existing = map[key] {
            existing.value = value
            moveToFront(existing)
            print("PUT(\(key), \(value)) → UPDATE existing key's value; MOVE to front (MRU)")
            print("   \(snapshot())\n")
            return
        }

        let node = Node(key: key, value: value)
        map[key] = node
        insertAtFront(node)
        print("PUT(\(key), \(value)) → CREATE new node, insert at front (MRU)")
        print("   \(snapshot())")

        if map.count > capacity {
            // `lru !== head` is a defensive guard, not normal-path logic: it stops the eviction
            // from ever unlinking the sentinel itself. It should never actually trigger given
            // insertAtFront always runs first (so there's at least one real node), but it's what
            // keeps a capacity-0 cache or a future refactor from corrupting the sentinel links.
            guard let lru = tail.prev, lru !== head else { return }
            let evictedKey = lru.key
            remove(lru)
            map[lru.key] = nil
            print("   over capacity (\(map.count + 1) > \(capacity)) → DELETE/EVICT key \(evictedKey) (was tail.prev, the LRU entry)")
            print("   \(snapshot())\n")
        } else {
            print("")
        }
    }

    // Walks head -> tail printing each real node, so you can see the exact list shape after
    // every operation instead of having to trace pointers in your head.
    private func snapshot() -> String {
        var parts: [String] = []
        var current = head.next
        while let node = current, node !== tail {
            parts.append("[\(node.key):\(node.value)]")
            current = node.next
        }
        let middle = parts.isEmpty ? "" : parts.joined(separator: " <-> ") + " <-> "
        return "head <-> " + middle + "tail"
    }

    private func remove(_ node: Node) {
        // Only rewires node's NEIGHBORS to point around it — node's own prev/next are left
        // dangling on purpose, since every caller immediately re-links `node` elsewhere
        // (insertAtFront in moveToFront, or drops the node entirely on eviction).
        node.prev?.next = node.next
        node.next?.prev = node.prev
    }

    private func insertAtFront(_ node: Node) {
        // Order matters here: steps 1 and 3 both read `head.next` to find the CURRENT front
        // node, so both must run before step 4 overwrites it. If step 4 ran first, `head.next`
        // would already be `node`, and step 3 would set `node.prev = node` — a self-reference bug.
        node.next = head.next          // 1: capture the current front before it's overwritten
        node.prev = head               // 2: order-independent, doesn't touch head.next
        head.next?.prev = node         // 3: must run before 4 — relinks the OLD front's prev
        head.next = node               // 4: now safe to make `node` the new front
    }

    private func moveToFront(_ node: Node) {
        // Reuses the same Node instance rather than allocating a new one, so `map[key]` doesn't
        // need updating — only the linked-list position changes, the dictionary entry is untouched.
        remove(node)
        insertAtFront(node)
    }
}

// Run this page — the console will print CREATE/UPDATE/MOVE/EVICT/MISS plus the full list shape
// after every single line below.
let cache = LRUCache(2)
cache.put(1, 1)
cache.put(2, 2)
cache.get(1)          // 1, and 1 becomes most-recently-used
cache.put(3, 3)        // evicts key 2 (least recently used)
cache.get(2)          // -1, evicted
cache.put(4, 4)        // evicts key 1
cache.get(1)          // -1, evicted
cache.get(3)          // 3
cache.get(4)          // 4

/*:
 ---

 ## Part 2: Problem 2 — Linked List Cycle Detection

 > **Problem:** Given the head of a linked list, determine if it contains a cycle, using O(1) space.

 Floyd's tortoise & hare: a slow pointer moves 1 step, a fast pointer moves 2. If there's a cycle,
 fast eventually laps slow and they meet. If fast hits `nil`, there's no cycle.
*/

final class ListNode {
    var val: Int
    var next: ListNode?
    init(_ val: Int) { self.val = val }
}

func hasCycle(_ head: ListNode?) -> Bool {
    var slow = head
    var fast = head

    while fast != nil && fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
        // `===` (reference identity), not `==` (value equality) — ListNode is a class, so two
        // variables can point at the exact same node instance. Value equality would need `Equatable`
        // conformance and would compare `.val`, which is wrong: two different nodes could
        // legitimately hold equal values without the list actually having a cycle.
        if slow === fast { return true }
    }
    return false
}

// quick manual test: build 1 -> 2 -> 3 -> back to 2
let n1 = ListNode(1), n2 = ListNode(2), n3 = ListNode(3)
n1.next = n2; n2.next = n3; n3.next = n2
hasCycle(n1)   // true

let m1 = ListNode(1), m2 = ListNode(2)
m1.next = m2
hasCycle(m1)   // false

/*:
 ---

 ## Part 3: Problem 3 — Binary Tree Level Order Traversal

 > **Problem:** Return the values of a binary tree level by level.

 Standard BFS with a queue. The trick worth narrating: capture `queue.count` at the *top* of each
 while-loop iteration before mutating the queue, so you know exactly how many nodes belong to the
 current level.
*/

final class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ val: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.val = val
        self.left = left
        self.right = right
    }
}

func levelOrder(_ root: TreeNode?) -> [[Int]] {
    guard let root = root else { return [] }
    var result: [[Int]] = []
    var queue: [TreeNode] = [root]

    while !queue.isEmpty {
        // Snapshotting `queue.count` here, before the loop appends children into the same
        // queue, is what separates "this level" from "the next level" — without it, children
        // enqueued mid-loop would get consumed as if they belonged to the current level.
        let levelSize = queue.count
        var level: [Int] = []
        for _ in 0..<levelSize {
            let node = queue.removeFirst()   // O(n) on Array — see note below
            level.append(node.val)
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        result.append(level)
    }
    return result
}

let tree = TreeNode(3, left: TreeNode(9), right: TreeNode(20, left: TreeNode(15), right: TreeNode(7)))
levelOrder(tree)   // [[3], [9, 20], [15, 7]]

/*:
 Worth mentioning out loud: `queue.removeFirst()` on a Swift `Array` is O(n). In an interview, saying
 *"in production I'd back this with a proper deque for O(1) dequeue, but I'll use `removeFirst` here
 for clarity"* is exactly the kind of tradeoff-awareness they're grading.

 ---

 ## Part 4: Problem 4 — Top K Frequent Elements

 > **Problem:** Given an array, return the k most frequent elements.

 Two valid approaches worth mentioning: a heap (O(n log k)), or bucket sort by frequency
 (O(n), since frequency is bounded by array length). Bucket sort is the sharper answer — say why:
 frequency can never exceed `nums.count`, so you can index buckets by frequency directly.
*/

func topKFrequent(_ nums: [Int], _ k: Int) -> [Int] {
    var counts: [Int: Int] = [:]
    for n in nums { counts[n, default: 0] += 1 }

    // Sized to `nums.count + 1`, not the number of distinct values: the highest POSSIBLE
    // frequency is every element being the same value, i.e. `nums.count`. Indexing buckets
    // directly by frequency (rather than sorting) is what makes this O(n) instead of O(n log n).
    var buckets = [[Int]](repeating: [], count: nums.count + 1)
    for (value, count) in counts {
        buckets[count].append(value)
    }

    var result: [Int] = []
    // Walk buckets from highest frequency down — that ordering is the whole trick, since it
    // means the first k values encountered are necessarily the k most frequent.
    for count in stride(from: buckets.count - 1, through: 0, by: -1) {
        for value in buckets[count] {
            result.append(value)
            if result.count == k { return result }   // stop early, don't drain lower buckets needlessly
        }
    }
    return result
}

topKFrequent([1, 1, 1, 2, 2, 3], 2)   // [1, 2]

/*:
 ---

 ## Part 5: Problem 5 — Debounce

 > **Problem:** Implement a debounce function: given a closure and a delay, calling the debounced
 > function repeatedly should only invoke the underlying closure once, after `delay` has passed
 > since the *last* call.

 This is worth having cold — it's the algorithmic core of a search-as-you-type field, which is very
 likely to show up in the **project call** (Day 4). Bring it up unprompted if you build a search bar
 there; it's a strong signal of production experience.
*/

final class Debouncer {
    private let delay: TimeInterval
    private var workItem: DispatchWorkItem?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func call(_ action: @escaping () -> Void) {
        // Cancel the PENDING work item, not any work already in flight — DispatchWorkItem.cancel()
        // only prevents a not-yet-started block from running; it can't interrupt one mid-execution.
        // That's fine here since these are cheap closures, but it's the detail that would matter
        // if `action` ever did something non-trivial (e.g. a network call already in flight).
        workItem?.cancel()
        let newWorkItem = DispatchWorkItem(block: action)
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
}

// Usage in a search field's onChange:
// let debouncer = Debouncer(delay: 0.3)
// debouncer.call { performSearch(query) }

/*:
 ---

 ## Part 6: Live debugging drill — find the bug

 Robinhood explicitly grades "debug and execution." Here's a self-contained buggy snippet — read it
 cold, predict the output, then run it. The exercise is to practice narrating *how* you'd find the
 bug (add print statements, check off-by-one boundaries, check reference vs. value semantics) rather
 than just staring until it clicks.

 **Bug:** an off-by-one in a binary search causes an infinite loop on a two-element array.
*/

func buggyBinarySearch(_ nums: [Int], _ target: Int) -> Int? {
    var low = 0
    var high = nums.count - 1

    while low <= high {
        let mid = (low + high) / 2
        if nums[mid] == target {
            return mid
        } else if nums[mid] < target {
            low = mid          // BUG: should be `mid + 1` — without this, low can stop advancing
        } else {
            high = mid - 1
        }
    }
    return nil
}

// buggyBinarySearch([1, 3], 3) would infinite-loop before the fix: mid stays 0, low never reaches 1.
// Fixed version:
func binarySearch(_ nums: [Int], _ target: Int) -> Int? {
    var low = 0
    var high = nums.count - 1

    while low <= high {
        // `(low + high) / 2` can overflow in fixed 32-bit-int languages for huge arrays — the
        // classic fix is `low + (high - low) / 2`. Swift's `Int` is 64-bit on all modern targets,
        // so this isn't a practical risk here, but naming the tradeoff out loud is the signal.
        let mid = (low + high) / 2
        if nums[mid] == target {
            return mid
        } else if nums[mid] < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}

binarySearch([1, 3], 3)              // 1
binarySearch([1, 3, 5, 7, 9], 5)     // 2
binarySearch([1, 3, 5, 7, 9], 4)     // nil

/*:
 ---

 ## Part 7: How to talk about execution & debugging out loud

 - **Trace by hand before assuming.** State the variable values at each iteration rather than
   guessing.
 - **Narrate the boundary conditions specifically**: "let me check what happens when the array has
   0 or 1 elements" — most real bugs live there.
 - **If stuck for more than ~30 seconds silently, say what you're checking.** Silence reads as being
   lost; narrating a systematic check ("let me verify the loop invariant holds after each iteration")
   reads as being methodical even if you haven't found it yet.
 - **When you find the bug, say what class of bug it was** ("that was an off-by-one on the loop
   advance") — this shows you're building a mental taxonomy, not just pattern-matching this one case.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
