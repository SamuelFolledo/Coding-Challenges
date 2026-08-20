//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 3: Coding Round Pt 2 — Graphs, BFS & Trees

 One candidate report specifically named a **LeetCode BFS question, "similar to Word Ladder"** as an
 actual asked Fanatics question (general SWE round, not confirmed iOS-specific — see Day 0, Part 7's
 confidence tags). That's the single most concrete data point available, so it gets full treatment
 here. Trees are added as a standard senior-level rounding-out, since BFS and tree traversal share the
 same mental model (level-order processing via a queue).

 ## Contents
 - Part 1: Word Ladder — the confirmed pattern, worked in full
 - Part 2: Generic graph BFS template (what to reach for if the exact problem differs)
 - Part 3: Binary tree level-order traversal
 - Part 4: Two other reported questions (different/lower-confidence role) — brief awareness only

 ---

 ## Part 1: Word Ladder — the confirmed pattern

 > **Problem:** Given a `beginWord`, an `endWord`, and a `wordList`, return the length of the shortest
 > transformation sequence from `beginWord` to `endWord`, changing exactly one letter at a time, where
 > every intermediate word must exist in `wordList`. Return 0 if no such sequence exists.

 The key insight: treat every word as a graph node, with an edge between two words if they differ by
 exactly one letter. The shortest transformation sequence is then just **BFS shortest path** — which is
 the whole reason this is a "BFS question" and not a string-manipulation question.
*/

func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
    var wordSet = Set(wordList)
    guard wordSet.contains(endWord) else { return 0 }

    var queue: [(word: String, steps: Int)] = [(beginWord, 1)]
    let alphabet = Array("abcdefghijklmnopqrstuvwxyz")

    while !queue.isEmpty {
        let (current, steps) = queue.removeFirst()
        if current == endWord { return steps }

        var chars = Array(current)
        for i in chars.indices {
            let original = chars[i]
            for letter in alphabet where letter != original {
                chars[i] = letter
                let candidate = String(chars)
                // Removing from wordSet the moment it's enqueued — not after it's dequeued — is
                // what prevents the SAME candidate word from being pushed onto the queue multiple
                // times by different words in this same level, which would blow up the queue size
                // without ever changing the answer.
                if wordSet.contains(candidate) {
                    wordSet.remove(candidate)
                    queue.append((candidate, steps + 1))
                }
            }
            chars[i] = original   // restore before trying the next letter position
        }
    }
    return 0
}

ladderLength("hit", "cog", ["hot", "dot", "dog", "lot", "log", "cog"])   // 5: hit->hot->dot->dog->cog
ladderLength("hit", "cog", ["hot", "dot", "dog", "lot", "log"])          // 0: "cog" not in wordList

/*:
 **Why BFS and not DFS:** BFS explores level by level, so the *first* time you reach `endWord` is
 guaranteed to be via the shortest path — DFS would find *a* path first, not necessarily the shortest
 one, and would need extra bookkeeping to guarantee minimality. This "BFS = shortest path in an
 unweighted graph" fact is worth stating out loud unprompted — it's the actual reason to reach for BFS
 here rather than something you back into by trial and error.

 **Complexity worth stating:** for each word (length L) popped from the queue, trying all 26 letters at
 each of the L positions is O(26 · L) work, against up to N words — O(26 · L² · N) worst case, since
 building each candidate string is itself O(L).

 ---

 ## Part 2: Generic graph BFS template

 If the exact problem differs from Word Ladder but still smells like "shortest path / fewest steps /
 minimum transformations," this is the template to reach for — Word Ladder above is one instance of it,
 with "neighbors" defined implicitly (one-letter-different words) instead of an explicit adjacency list.
*/

func bfsShortestPath(from start: Int, to target: Int, graph: [Int: [Int]]) -> Int {
    guard start != target else { return 0 }

    var visited: Set<Int> = [start]
    var queue: [(node: Int, dist: Int)] = [(start, 0)]

    while !queue.isEmpty {
        let (node, dist) = queue.removeFirst()
        for neighbor in graph[node, default: []] {
            if neighbor == target { return dist + 1 }
            if !visited.contains(neighbor) {
                visited.insert(neighbor)
                queue.append((neighbor, dist + 1))
            }
        }
    }
    return -1   // unreachable
}

let sampleGraph = [0: [1, 2], 1: [0, 3], 2: [0, 3], 3: [1, 2, 4], 4: [3]]
bfsShortestPath(from: 0, to: 4, graph: sampleGraph)   // 3

/*:
 The three ingredients that stay constant across every BFS-shortest-path variant: a **queue** (not a
 stack — that's DFS), a **visited set marked at enqueue time** (not at dequeue time — same double-enqueue
 bug the `wordSet.remove` line above guards against), and **level/distance tracked alongside each node**.

 ---

 ## Part 3: Binary tree level-order traversal

 Trees weren't specifically reported for Fanatics, but they're a standard senior-level rounding-out
 question, and level-order traversal is literally BFS on a tree — the same queue-based mental model as
 Parts 1–2, just with a tree's `left`/`right` children standing in for graph neighbors.
*/

class TreeNode {
    let value: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ value: Int, left: TreeNode? = nil, right: TreeNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

func levelOrder(_ root: TreeNode?) -> [[Int]] {
    guard let root else { return [] }

    var result: [[Int]] = []
    var queue: [TreeNode] = [root]

    while !queue.isEmpty {
        // Snapshotting queue.count BEFORE the inner loop is what separates one tree LEVEL from the
        // next — without it, nodes appended to `queue` for the NEXT level would get consumed by
        // this same inner loop, collapsing every level into one flat list instead of one list per row.
        let levelSize = queue.count
        var currentLevel: [Int] = []

        for _ in 0..<levelSize {
            let node = queue.removeFirst()
            currentLevel.append(node.value)
            if let left = node.left { queue.append(left) }
            if let right = node.right { queue.append(right) }
        }
        result.append(currentLevel)
    }
    return result
}

let sampleTree = TreeNode(3, left: TreeNode(9), right: TreeNode(20, left: TreeNode(15), right: TreeNode(7)))
levelOrder(sampleTree)   // [[3], [9, 20], [15, 7]]

/*:
 **What to say out loud:** "I'm snapshotting `queue.count` before draining the current level, so
 children I append during this pass don't get pulled into the same row — that's what turns plain BFS
 into *level-order* BFS."

 ---

 ## Part 4: Two other reported questions (different/lower-confidence role) — brief awareness only

 From a September 2025 SDE3 Full Stack (Hyderabad) report — different role, different location, lower
 relevance, but cheap to know exist:

 - **Angle Between Clock Hands** — compute the angle between hour/minute hands at a given time.
   Formula-based: minute hand moves 6°/minute, hour hand moves 0.5°/minute (30°/hour +
   0.5°-per-minute-within-the-hour); take `abs(difference)`, then `min(angle, 360 - angle)` for the
   smaller angle.
 - **Mirror of a Palindrome String** — check whether a string, when each character is mapped to its
   "mirror" (e.g. on a 7-segment/reflective alphabet subset like `A H I M O T U V W X Y`), reads the
   same reversed. A string/set-membership problem, not algorithmically deep — the trick is just
   correctly defining which characters have valid mirrors.

 Not worth deep prep given the low confidence they apply to an iOS-specific loop — noted here only so
 they're not a total surprise if raised.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
