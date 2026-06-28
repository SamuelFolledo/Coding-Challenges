//: [Previous](@previous)

/*:
 # Data Structure & Algorithm Recognition Guide

 ---

 ## Part 1: How to recognize which one to use

 Before reaching for a specific structure, scan the problem for these signal words and constraints. This is the actual decision process experienced interviewers expect to see you run through out loud.

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
 - **"Parent-child", "hierarchy", "ancestor"** → Tree, often DFS recursion
 - **"Prefix matching", "autocomplete"** → Trie
 - **"LRU/LFU cache"** → Hash Map + Doubly Linked List
 - **"Range queries", "cumulative sum"** → Prefix Sum, Fenwick Tree, Segment Tree
 - **Need order preserved AND fast lookup** → Hash Map (ordered variants: LinkedHashMap-style)
 - **"Merge intervals", "insert interval"** → Sort first, then linear scan

 **Quick mental checklist when you see a new problem:**
 1. What's being asked: existence, count, order, optimal value, or all possibilities?
 2. What are the constraints? n ≤ 10 → brute force fine. n ≤ 10⁴ → O(n²) fine. n ≤ 10⁶+ → need O(n) or O(n log n).
 3. Is the input sorted, or can I sort it without breaking the problem?
 4. Do I need to look something up repeatedly? → Hash Map.
 5. Do I need min/max repeatedly as things change? → Heap.
 6. Is there a graph/tree relationship implied? → Graph traversal.

 ---

 ## Part 2: Data Structures — operations, complexity, and usage

 ### Array / Dynamic Array (Swift: `Array`)

 - **Access by index:** O(1)
 - **Update by index:** O(1)
 - **Insert at end:** O(1) amortized
 - **Insert at arbitrary index:** O(n)
 - **Delete at end:** O(1)
 - **Delete at arbitrary index:** O(n)
 - **Search (unsorted):** O(n)
 - **Search (sorted, binary search):** O(log n)

 **Use when:** you need fast random access, the size is somewhat predictable, or you're doing index math (two pointers, sliding window, prefix sums).

 ---

 ### Linked List (Singly/Doubly)

 - **Access by index:** O(n)
 - **Insert/Delete at head:** O(1)
 - **Insert/Delete at tail** (singly, no tail pointer): O(n)
 - **Insert/Delete at tail** (doubly, with tail pointer): O(1)
 - **Search:** O(n)

 **Use when:** frequent insertions/deletions at the ends or middle (given a reference node), you don't need random access, or you're building something like an LRU cache (paired with a hash map).

 ---

 ### Stack (LIFO)

 - **Push:** O(1)
 - **Pop:** O(1)
 - **Peek:** O(1)

 **Use when:** "undo" behavior, matching brackets/parentheses, monotonic stack problems (next greater element), DFS implemented iteratively, expression evaluation.

 ---

 ### Queue (FIFO) / Deque

 - **Enqueue:** O(1)
 - **Dequeue:** O(1)
 - **Peek:** O(1)

 **Use when:** BFS, task scheduling, sliding window maximum (with a deque), rate limiting.

 ---

 ### Hash Map / Hash Set (Swift: `Dictionary` / `Set`)

 - **Insert:** O(1) average, O(n) worst case
 - **Lookup:** O(1) average, O(n) worst case
 - **Update:** O(1) average, O(n) worst case
 - **Delete:** O(1) average, O(n) worst case

 **Use when:** you need O(1) existence checks, counting frequencies, caching/memoization, grouping (anagrams, by key), two-sum style problems.

 ---

 ### Tree — Binary Search Tree (balanced, e.g. AVL/Red-Black)

 - **Insert:** O(log n)
 - **Search:** O(log n)
 - **Delete:** O(log n)
 - **In-order traversal** (gives sorted order): O(n)

 **Use when:** you need sorted order maintained dynamically with fast insert/search/delete. Most standard library "sorted map/set" types are balanced BSTs under the hood.

 ---

 ### Heap / Priority Queue

 - **Insert:** O(log n)
 - **Get min/max:** O(1)
 - **Extract min/max:** O(log n)
 - **Build from array:** O(n)

 Swift has no built-in heap, but you can use a manual array-based implementation or the `Heap` type from swift-collections.

 **Use when:** "Kth largest/smallest," merging K sorted lists, scheduling by priority, running median, Dijkstra's algorithm.

 ---

 ### Trie (Prefix Tree)

 All operations are **O(L)** where L is the length of the word/prefix.

 - **Insert word**
 - **Search word**
 - **Search prefix**
 - **Delete word**

 **Use when:** autocomplete, spell checkers, prefix matching, word search puzzles with many queries.

 ---

 ### Graph (Adjacency List)

 - **Add vertex/edge:** O(1)
 - **Remove edge:** O(degree)
 - **Remove vertex:** O(V + E)
 - **BFS/DFS traversal:** O(V + E)

 **Use when:** relationships/connections between entities — networks, dependency graphs, maps, social graphs, state machines.

 ---

 ### Union-Find (Disjoint Set)

 With path compression + union by rank, both operations are effectively **O(1) amortized**:

 - **Find** (which set does this node belong to?)
 - **Union** (connect two nodes)

 **Use when:** dynamic connectivity — "are these two nodes connected," counting connected components, detecting cycles in undirected graphs, Kruskal's MST.

 ---

 ## Part 3: Algorithm Patterns — when and why

 ### Two Pointers
 - **When:** sorted array, pair/triplet sum, removing duplicates in place
 - **Complexity:** O(n)

 ### Sliding Window
 - **When:** contiguous subarray/substring with a sum/count condition
 - **Complexity:** O(n)

 ### Binary Search
 - **When:** sorted data, or the search space can be binary-searched (minimize/maximize a value)
 - **Complexity:** O(log n)

 ### BFS
 - **When:** shortest path in unweighted graph, level-order processing
 - **Complexity:** O(V + E)

 ### DFS / Backtracking
 - **When:** explore all paths/combinations, constraint satisfaction (N-Queens, Sudoku), tree traversal
 - **Complexity:** O(branching^depth) typically

 ### Dynamic Programming
 - **When:** optimal value with overlapping subproblems and optimal substructure (knapsack, LCS, edit distance)
 - **Complexity:** often O(n) to O(n²)

 ### Greedy
 - **When:** locally optimal choice provably leads to globally optimal result (interval scheduling, Huffman coding)
 - **Complexity:** often O(n log n)

 ### Divide and Conquer
 - **When:** problem splits into independent subproblems (merge sort, quick sort, binary search)
 - **Complexity:** O(n log n) typically

 ### Topological Sort
 - **When:** ordering with dependencies (course schedules, build systems)
 - **Complexity:** O(V + E)

 ### Prefix Sum
 - **When:** repeated range-sum queries on a static array
 - **Complexity:** O(1) per query after O(n) build

 ### Fast & Slow Pointers
 - **When:** cycle detection in linked lists, finding the middle of a list
 - **Complexity:** O(n)

 ---

 ## Part 4: Sorting Algorithms Quick Reference

 ### Quick Sort
 - **Average:** O(n log n) — **Worst:** O(n²) — **Space:** O(log n) — **Stable:** No
 - Fast in practice, in-place. Worst case avoidable with randomized pivot.

 ### Merge Sort
 - **Average:** O(n log n) — **Worst:** O(n log n) — **Space:** O(n) — **Stable:** Yes
 - Predictable performance, good for linked lists and external sorting.

 ### Heap Sort
 - **Average:** O(n log n) — **Worst:** O(n log n) — **Space:** O(1) — **Stable:** No
 - In-place with guaranteed O(n log n), but poor cache locality in practice.

 ### Insertion Sort
 - **Average:** O(n²) — **Worst:** O(n²) — **Space:** O(1) — **Stable:** Yes
 - Best for small or nearly-sorted arrays; adaptive (O(n) when nearly sorted).

 ### Bubble Sort
 - **Average:** O(n²) — **Worst:** O(n²) — **Space:** O(1) — **Stable:** Yes
 - Rarely used in practice; understand it conceptually.

 In most interviews you won't implement sort from scratch unless asked — but knowing these tradeoffs comes up when you justify "I'll sort first" as part of your approach.

 ---

 ## How to use this in an interview

 1. Restate the problem and constraints out loud.
 2. State the brute force and its complexity, even if you won't code it.
 3. Name the pattern you think fits, and *why* (point to the signal from Part 1).
 4. State the target time/space complexity before coding.
 5. Code it, then verify against the complexity you promised.

 This sequence alone — even before you write code — signals strong CS fundamentals to most interviewers.
 */

import Foundation

//: [Next](@next)
