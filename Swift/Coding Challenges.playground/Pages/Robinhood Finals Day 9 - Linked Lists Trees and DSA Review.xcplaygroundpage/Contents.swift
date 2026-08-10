//: [Previous](@previous)

import Foundation

/*:
 # Robinhood Finals — Day 9: Linked Lists vs. Trees, and a Full DS&A Review

 ## Contents
 - Part 1: Singly Linked List — when to use it, code
 - Part 2: Doubly Linked List — when to use it, code
 - Part 3: When a tree beats a linked list entirely
 - Part 4: Binary Search Tree — code
 - Part 5: Trie (prefix tree) — code, and why it's an iOS-relevant one
 - Part 6: Heap / priority queue — code
 - Part 7: Big-O cheat sheet across every structure above
 - Part 8: Full DS&A pattern review — what's covered where, and how to drill it

 ---

 ## Part 1: Singly Linked List

 Each node knows only what comes **after** it — no `prev` pointer.

 **Use it when:** you only ever traverse forward, and you either don't need to delete/insert given
 just a node reference, or you're always operating at the head. Saves one pointer's worth of memory
 per node versus doubly linked — small, but real at scale.

 **Classic real uses:** the backing structure for a `Stack` (push/pop only ever touch the head, O(1),
 never need to look backward), a singly linked implementation of an undo-only (not redo) history,
 representing a polynomial or a simple sequence you only walk one direction.
*/

final class SinglyNode<T> {
    var value: T
    var next: SinglyNode<T>?
    init(_ value: T) { self.value = value }
}

// Classic interview question: reverse a singly linked list in place, O(n) time, O(1) space.
func reverseLinkedList<T>(_ head: SinglyNode<T>?) -> SinglyNode<T>? {
    var previous: SinglyNode<T>? = nil
    var current = head

    while let node = current {
        let next = node.next   // save before overwriting, or the rest of the list is lost
        node.next = previous
        previous = node
        current = next
    }
    return previous   // previous ends up as the new head
}

let a = SinglyNode(1)
let b = SinglyNode(2)
let c = SinglyNode(3)
a.next = b; b.next = c
var walk = reverseLinkedList(a)   // head of the reversed list: 3 -> 2 -> 1
var reversedValues: [Int] = []
while let node = walk { reversedValues.append(node.value); walk = node.next }
reversedValues   // [3, 2, 1]

/*:
 ---

 ## Part 2: Doubly Linked List

 Each node knows both `prev` and `next`. You already built one of these for the LRU Cache (Day 3,
 Part 1) — that's the canonical use case, so this section is deliberately short; go re-run Day 3's
 instrumented version if the mechanics are still fuzzy.

 **Use it when:** you need O(1) removal or reordering of a node **given a direct reference to it**,
 without re-traversing the list to find its neighbors. A singly linked list can't do this in O(1) —
 to unlink a node you need its predecessor, and finding that predecessor means walking from the head.

 **Classic real uses:** LRU/MRU caches (Day 3), browser back/forward history, undo/redo (both
 directions, unlike the singly linked undo-only case above), a music player's "next/previous track"
 with the ability to jump to an arbitrary track and still navigate both ways from there.

 ---

 ## Part 3: When a tree beats a linked list entirely

 A linked list — singly or doubly — is fundamentally **linear**: finding anything by value is always
 O(n), because there's exactly one path through the data and you have to walk it. A tree branches,
 which is what makes search faster than linear when the data has an order or hierarchy to exploit.

 ```
 Reach for...        | When...
 ----------------------+---------------------------------------------------------------------
 Linked list (S or D)  | You mainly insert/delete at known positions (front/back/given a node) and
                       | don't need fast search by value — order of insertion IS the structure.
 Binary Search Tree    | Data has a natural ORDER and you need fast search + fast insert + the
                       | ability to walk it in sorted order (inorder traversal).
 Trie (prefix tree)    | Keys are strings/sequences and you need fast PREFIX lookup — autocomplete,
                       | search-as-you-type, spell-check.
 Heap                  | You repeatedly need the min or max of a changing collection — a priority
                       | queue, "top K," a scheduler picking the next task by priority.
 Hash map              | You need O(1) average lookup by key and don't care about ORDER at all.
 Plain tree / general   | Data is genuinely hierarchical — a file system, a UI view hierarchy, an
 (non-binary)           | org chart, nested comment threads.
 ```

 A useful gut-check question in an interview: *"does this data have an order or hierarchy I can
 exploit to avoid checking every element?"* If yes, a tree-shaped structure is probably right. If the
 answer is "no, I just need to insert/remove at the ends fast," a linked list is enough — reaching
 for a tree there is over-engineering.

 ---

 ## Part 4: Binary Search Tree

 > Left subtree < node < right subtree, recursively. Search/insert are O(log n) *if balanced* — an
 > unbalanced BST (e.g. inserting already-sorted data) degrades to O(n), effectively becoming a
 > linked list. Worth saying out loud if asked: "a self-balancing variant like an AVL or red-black
 > tree guarantees O(log n) even in the worst case; this is the simple, unbalanced version."
*/

final class BSTNode {
    let value: Int
    var left: BSTNode?
    var right: BSTNode?
    init(_ value: Int) { self.value = value }
}

final class BinarySearchTree {
    private var root: BSTNode?

    func insert(_ value: Int) {
        root = insert(root, value)
    }

    private func insert(_ node: BSTNode?, _ value: Int) -> BSTNode {
        guard let node = node else { return BSTNode(value) }
        if value < node.value {
            node.left = insert(node.left, value)
        } else if value > node.value {
            node.right = insert(node.right, value)
        }
        // equal values are ignored here — a real implementation would define duplicate policy explicitly
        return node
    }

    func contains(_ value: Int) -> Bool {
        var current = root
        while let node = current {
            if value == node.value { return true }
            current = value < node.value ? node.left : node.right
        }
        return false
    }

    // Inorder traversal of a BST visits nodes in ascending sorted order — that's the structural
    // guarantee a BST gives you for free, which a plain hash map never can.
    func sortedValues() -> [Int] {
        var result: [Int] = []
        func visit(_ node: BSTNode?) {
            guard let node = node else { return }
            visit(node.left)
            result.append(node.value)
            visit(node.right)
        }
        visit(root)
        return result
    }
}

let bst = BinarySearchTree()
[5, 3, 8, 1, 4, 7, 9].forEach { bst.insert($0) }
bst.contains(7)          // true
bst.contains(6)          // false
bst.sortedValues()       // [1, 3, 4, 5, 7, 8, 9] — sorted, "for free," from tree shape alone

/*:
 ---

 ## Part 5: Trie (prefix tree)

 The one tree variant most directly relevant to an iOS role: a Trie is what powers autocomplete and
 search-as-you-type — exactly the kind of feature likely in a Watchlist search bar (Day 4) if it
 needed to suggest ticker symbols as the user types, instead of just filtering an already-fetched
 list. Each node represents one character; a path from root to a marked node spells a stored word.
*/

final class TrieNode {
    var children: [Character: TrieNode] = [:]
    var isEndOfWord = false
}

final class Trie {
    private let root = TrieNode()

    func insert(_ word: String) {
        var node = root
        for char in word {
            // Only creates a child node the FIRST time this character is reached at this
            // position — every later insert that shares a prefix (e.g. "APPL" after "APP" already
            // exists) reuses the existing chain instead of duplicating it. That sharing is the
            // whole point of a Trie: common prefixes are stored once, not once per word.
            if node.children[char] == nil {
                node.children[char] = TrieNode()
            }
            node = node.children[char]!
        }
        node.isEndOfWord = true
    }

    func contains(_ word: String) -> Bool {
        guard let node = walk(word) else { return false }
        return node.isEndOfWord
    }

    // Distinct from `contains`: a prefix doesn't need to BE a stored word, just a valid path —
    // this is the query that actually powers autocomplete ("APP" should match without "APP" itself
    // ever having been inserted as a word).
    func hasPrefix(_ prefix: String) -> Bool {
        walk(prefix) != nil
    }

    private func walk(_ string: String) -> TrieNode? {
        var node = root
        for char in string {
            guard let next = node.children[char] else { return nil }
            node = next
        }
        return node
    }
}

let trie = Trie()
["AAPL", "AMZN", "AMD", "APP"].forEach { trie.insert($0) }
trie.contains("AAPL")     // true
trie.contains("AA")       // false — "AA" was never inserted as a complete word
trie.hasPrefix("AA")      // true — "AA" is a valid prefix path (leads toward "AAPL")
trie.hasPrefix("TSLA")    // false — no stored word starts this way

/*:
 Search cost is **O(k)**, where k is the length of the search string — not O(n) where n is the
 number of stored words. That's the pitch if asked "why not just filter an array of strings":
 filtering is O(n·k) (check every word's prefix), a Trie lookup is O(k) regardless of how many
 words are stored.

 ---

 ## Part 6: Heap / priority queue

 A binary heap keeps the min (or max) accessible in O(1), with O(log n) insert/remove. Swift's
 standard library has no built-in heap type — Apple's swift-collections package has `Heap`, but if
 asked to implement one from scratch (a real possibility), here's the minimal array-backed version.
 The core trick: a complete binary tree stored flat in an array, where for index `i`, children live
 at `2i+1` and `2i+2` — no pointers needed at all.
*/

struct MinHeap {
    private var storage: [Int] = []

    var isEmpty: Bool { storage.isEmpty }
    var peekMin: Int? { storage.first }

    mutating func insert(_ value: Int) {
        storage.append(value)
        siftUp(from: storage.count - 1)
    }

    mutating func popMin() -> Int? {
        guard !storage.isEmpty else { return nil }
        storage.swapAt(0, storage.count - 1)   // move the min to the end so it's cheap to remove
        let min = storage.removeLast()
        if !storage.isEmpty { siftDown(from: 0) }
        return min
    }

    private mutating func siftUp(from index: Int) {
        var child = index
        while child > 0 {
            let parent = (child - 1) / 2
            guard storage[child] < storage[parent] else { break }
            storage.swapAt(child, parent)
            child = parent
        }
    }

    private mutating func siftDown(from index: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = 2 * parent + 2
            var smallest = parent
            if left < storage.count, storage[left] < storage[smallest] { smallest = left }
            if right < storage.count, storage[right] < storage[smallest] { smallest = right }
            guard smallest != parent else { break }
            storage.swapAt(parent, smallest)
            parent = smallest
        }
    }
}

var heap = MinHeap()
[5, 1, 8, 2, 9, 3].forEach { heap.insert($0) }
heap.peekMin        // 1
var poppedInOrder: [Int] = []
while let min = heap.popMin() { poppedInOrder.append(min) }
poppedInOrder        // [1, 2, 3, 5, 8, 9] — popped out in ascending order

/*:
 This is the "textbook" way to solve Day 3's Top K Frequent problem too — a size-k min-heap of
 (value, frequency) pairs, O(n log k), versus the bucket-sort approach used there (O(n), but only
 works because frequency is bounded by array length). Worth mentioning both if asked — bucket sort
 is the sharper answer for that *specific* problem, but the heap approach generalizes to cases where
 the bound trick doesn't apply (e.g. frequencies that aren't integer counts).

 ---

 ## Part 7: Big-O cheat sheet

 ```
 Structure           | Access    | Search   | Insert (end)  | Insert/Delete (ref known) | Notes
 ----------------------+-----------+----------+----------------+------------------------------+------------------------------
 Array                | O(1)      | O(n)     | O(1) amortized | O(n) — must shift elements   | Best for index-based access
 Singly Linked List   | O(n)      | O(n)     | O(n), no tail  | O(1) insert after ref;       | Can't delete a node given
                      |           |          | ref (O(1) if   | O(n) delete (need prev,      | only its own reference —
                      |           |          | you keep one)  | must re-traverse to find it) | no way back to predecessor
 Doubly Linked List   | O(n)      | O(n)     | O(1)           | O(1) — prev is already known | LRU cache's structure
 Hash Map/Set         | O(1) avg  | O(1) avg | O(1) avg       | O(1) avg                     | No ordering guarantee at all
 BST (balanced)       | O(log n)  | O(log n) | O(log n)       | O(log n)                     | Gives sorted order for free
 Trie                 | O(k)      | O(k)     | O(k)           | O(k)                         | k = key length, not n
 Heap                 | O(1) min/max only | O(n) arbitrary | O(log n)     | O(log n)          | Only cheap for min/max, not
                      |           |          |                |                              | arbitrary lookup
 ```

 ---

 ## Part 8: Full DS&A pattern review — what's covered where

 A pattern-first way to review, since Robinhood's technical screen is explicitly about *approach*
 (Day 2, Part 1) — recognizing which pattern applies is most of the battle. Everything below already
 has working code in this playground; this is the index.

 ```
 Pattern                          | Where it's covered           | When to reach for it
 -----------------------------------+-------------------------------+------------------------------------
 Hash map for O(1) lookup           | Day 2: Two Sum, Group Anagrams| Need to check "have I seen this?"
                                    |                               | or count occurrences, fast
 Stack                              | Day 2: Valid Parentheses      | Matching/nesting, undo history,
                                    |                               | "most recent unmatched thing"
 Sort + single sweep                | Day 2: Merge Intervals        | Overlap/ordering problems where
                                    |                               | sorting first makes one pass enough
 Sliding window                     | Day 2: Longest Substring      | Contiguous subarray/substring with
                                    |                               | a constraint (no repeats, sum ≤ k)
 Doubly linked list + hash map      | Day 3: LRU Cache              | O(1) access AND O(1) reordering by
                                    |                               | recency — the two together are key
 Fast/slow pointers                 | Day 3: Cycle Detection        | Detect a cycle, or find a midpoint,
                                    |                               | in a linked list, in O(1) space
 BFS with level tracking            | Day 3: Level Order Traversal  | Shortest path / level-by-level
                                    |                               | processing in a tree or graph
 Bucket sort / heap for top-K       | Day 3: Top K Frequent         | "Give me the k most/least X" where
                                    |                               | a full sort would be overkill
 Debounce / cancel-and-reschedule   | Day 3: Debounce               | Rate-limit reactive UI work
                                    |                               | (search-as-you-type)
 Binary search                      | Day 3: buggyBinarySearch      | Search a SORTED collection in
                                    |                               | O(log n); watch the boundary math
 Two pointers (min-so-far)          | Day 8: Best Time to Buy/Sell  | Track a running extreme while
                                    |                               | scanning once, no nested loop
 Reverse in place                   | Day 9, Part 1                 | Reverse a linked list / array with
                                    |                               | O(1) extra space
 BST insert/search/inorder          | Day 9, Part 4                 | Ordered data needing fast search
                                    |                               | AND the ability to walk it sorted
 Trie insert/search/prefix          | Day 9, Part 5                 | Prefix search — autocomplete,
                                    |                               | search-as-you-type at scale
 Heap push/pop                      | Day 9, Part 6                 | Repeated min/max extraction,
                                    |                               | priority-based scheduling
 ```

 **Lower priority for this specific loop** (per Day 0's research, these skew toward Robinhood's
 general SWE/backend interviews more than the iOS IC3 loop, but a quick refresher doesn't hurt):
 graph traversal on an adjacency list/general graph (not just a tree), backtracking (permutations/
 combinations), and basic dynamic programming (climbing stairs / coin change style problems).

 **How to drill this in the time you have left:**
 1. Cover the table top to bottom once, out loud, explaining *when* each pattern applies — not the
    code. Recognizing the pattern is the actual skill being graded.
 2. Re-implement 2-3 at random from a blank editor, timed, without looking — the LRU Cache and one
    sliding-window problem are the highest-value pair given the confirmed real questions (Day 0).
 3. For each one, say the brute-force approach and its complexity FIRST, out loud, before the
    optimized one — this is the exact behavior graded per Day 2, Part 1, and it's a habit that only
    forms through repetition, not by reading about it.

 [↑ Back to Top](#top)
*/
