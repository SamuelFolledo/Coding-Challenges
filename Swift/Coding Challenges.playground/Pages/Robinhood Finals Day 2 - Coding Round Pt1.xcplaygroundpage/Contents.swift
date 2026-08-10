//: [Previous](@previous)

import Foundation

/*:
 # Robinhood Finals — Day 2: Technical Screen, Part 1 — Approach & Core Patterns

 ## Contents
 - Part 1: The approach that gets graded (not just the answer)
 - Part 2: Code quality & testability talking points
 - Part 3: Problem 1 — Two Sum (hash map)
 - Part 4: Problem 2 — Valid Parentheses (stack)
 - Part 5: Problem 3 — Group Anagrams (hash map of sorted keys)
 - Part 6: Problem 4 — Merge Intervals (sort + sweep)
 - Part 7: Problem 5 — Longest Substring Without Repeating Characters (sliding window)

 ---

 ## Part 1: The approach that gets graded

 Robinhood explicitly grades **how** you get to the answer, not just whether you get it:

 1. **Restate the problem in your own words.** Catches misreads early, shows the interviewer you
    listen.
 2. **Ask 2–3 clarifying questions** even if you think you know the answer:
    - Are inputs sorted? Can they be empty? Negative numbers? Duplicates?
    - What's the expected scale (n)? Does that rule out O(n²)?
    - What should happen on no valid answer — throw, return nil, return empty?
 3. **State a brute force first, out loud, with its complexity.** This shows you can reason about
    correctness before optimizing, and gives the interviewer a checkpoint if you get stuck later.
 4. **Propose the optimized approach and its complexity BEFORE coding.** Wait for a nod/agreement.
    This is the step people skip under pressure — don't.
 5. **Code it.** Narrate as you go, but don't narrate every line — narrate decisions ("I'm using a
    dictionary here because I need O(1) lookup on the complement").
 6. **Test it yourself before the interviewer asks.** Walk through the example by hand, then think
    of an edge case (empty input, single element, all duplicates) and trace it too.
 7. **State final complexity (time & space).**

 ---

 ## Part 2: Code quality & testability talking points

 Robinhood explicitly grades code quality, refactoring, testability and maintainability in the
 CoderPad round — not just Leetcode edge-case bugs. In an interview with no unit test framework
 available, you demonstrate this *verbally* and *structurally*:

 - **Small, named functions over one giant blob.** Even under time pressure, pull out a helper if it
   has a clear single responsibility — it signals you'd do this in a real PR.
 - **No force-unwraps in "production-style" code.** Use `guard let`, provide a clear failure path.
 - **Name things for what they mean, not their type** (`remaining` not `arr2`, `seen` not `set1`).
 - **Say the word "testable" out loud when it's relevant** — e.g. "I'm keeping this pure (no shared
   mutable state) so it's trivial to unit test in isolation."
 - **If asked to refactor**, look for: duplicated logic to extract, a function doing two things to
   split, a magic number to name as a constant, an opportunity to use a `protocol` to decouple a
   concrete dependency (this is a very iOS-flavored refactor and plays well here).

 ---

 ## Part 3: Problem 1 — Two Sum

 > **Problem:** Given an array of integers `nums` and a target, return the indices of the two
 > numbers that add up to `target`. Assume exactly one solution, and you cannot use the same element
 > twice.

 Brute force: check every pair, O(n²) time, O(1) space. Optimized: single pass with a dictionary
 mapping value → index, O(n) time, O(n) space — because for each element you only need to know if
 its complement was *already seen*.
*/

func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var seen: [Int: Int] = [:]              // value -> index
    for (index, value) in nums.enumerated() {
        let complement = target - value
        // Look up BEFORE inserting the current value. This is what stops an element from
        // pairing with itself in the same iteration (e.g. target = 2*value): `value` isn't in
        // `seen` yet when we check. A genuine earlier occurrence of the same value still matches,
        // because it was inserted on a prior loop iteration.
        if let complementIndex = seen[complement] {
            return [complementIndex, index]
        }
        seen[value] = index
    }
    return []                                // no valid pair, per constraints shouldn't happen
}

twoSum([2, 7, 11, 15], 9)   // [0, 1]
twoSum([3, 2, 4], 6)        // [1, 2]

/*:
 ---

 ## Part 4: Problem 2 — Valid Parentheses

 > **Problem:** Given a string containing `(){}[]`, determine if the brackets are balanced and
 > correctly nested.

 Classic stack problem: push opens, and on a close, pop and check it matches. Clarifying question
 worth asking: "does the string contain characters other than brackets?" (affects whether you
 filter or just ignore them).
*/

func isValidParentheses(_ s: String) -> Bool {
    let pairs: [Character: Character] = [")": "(", "}": "{", "]": "["]
    var stack: [Character] = []

    for char in s {
        if pairs.values.contains(char) {
            stack.append(char)
        } else if let opener = pairs[char] {
            // popLast() returns nil on an empty stack, and nil never equals a real Character,
            // so an unmatched closer (e.g. a lone ")") fails this check for free — no separate
            // "is the stack empty" guard needed before popping.
            guard stack.popLast() == opener else { return false }
        }
    }
    return stack.isEmpty   // catches unclosed openers, e.g. "(()" — stack isn't empty at the end
}

isValidParentheses("()[]{}")   // true
isValidParentheses("(]")       // false
isValidParentheses("([)]")     // false
isValidParentheses("{[]}")     // true

/*:
 ---

 ## Part 5: Problem 3 — Group Anagrams

 > **Problem:** Group an array of strings into anagram clusters.

 Key insight to say out loud: two strings are anagrams iff their **sorted characters** are equal —
 so the sorted string is a natural dictionary key. O(n · k log k) where k is the max string length.
*/

func groupAnagrams(_ strs: [String]) -> [[String]] {
    var groups: [String: [String]] = [:]
    for word in strs {
        let key = String(word.sorted())
        // `default:` gives a single-lookup read-modify-write: no separate "does this key exist
        // yet" branch, so there's no window where you'd check-then-insert against a stale value.
        groups[key, default: []].append(word)
    }
    return Array(groups.values)
}

groupAnagrams(["eat", "tea", "tan", "ate", "nat", "bat"])
// [["eat","tea","ate"], ["tan","nat"], ["bat"]]  (order may vary)

/*:
 ---

 ## Part 6: Problem 4 — Merge Intervals

 > **Problem:** Given a list of intervals, merge all overlapping ones.

 Sort by start time first — this is the trick that makes the rest linear. Then sweep once: if the
 current interval's start is ≤ the last merged interval's end, extend it; otherwise start a new one.
*/

func mergeIntervals(_ intervals: [[Int]]) -> [[Int]] {
    guard !intervals.isEmpty else { return [] }
    let sorted = intervals.sorted { $0[0] < $1[0] }
    var merged: [[Int]] = [sorted[0]]

    for interval in sorted.dropFirst() {
        if interval[0] <= merged[merged.count - 1][1] {
            // max(), not a plain assignment: a fully-contained interval (e.g. [2,3] inside an
            // already-merged [1,10]) has a smaller end than the merged range. Assigning
            // interval[1] directly would wrongly shrink the merged end back down to 3.
            merged[merged.count - 1][1] = max(merged[merged.count - 1][1], interval[1])
        } else {
            merged.append(interval)
        }
    }
    return merged
}

mergeIntervals([[1, 3], [2, 6], [8, 10], [15, 18]])   // [[1,6],[8,10],[15,18]]
mergeIntervals([[1, 4], [4, 5]])                       // [[1,5]]

/*:
 ---

 ## Part 7: Problem 5 — Longest Substring Without Repeating Characters

 > **Problem:** Find the length of the longest substring without repeating characters.

 Sliding window with a dictionary of last-seen index. When you hit a repeat *inside* the current
 window, jump the window's left edge past the previous occurrence — don't reset to 0, that's the
 O(n²) version people default to under pressure.
*/

func lengthOfLongestSubstring(_ s: String) -> Int {
    let chars = Array(s)
    var lastSeenIndex: [Character: Int] = [:]
    var windowStart = 0
    var longest = 0

    for (i, char) in chars.enumerated() {
        // The `previous >= windowStart` guard is the part that's easy to miss: `lastSeenIndex`
        // can hold a stale index from BEFORE the window already advanced past it (the char
        // appeared once, windowStart moved on for a different repeat, then this char reappears).
        // Without the guard, windowStart could jump backward on that stale index, which would
        // silently widen the window past characters that are actually still repeats within it.
        if let previous = lastSeenIndex[char], previous >= windowStart {
            windowStart = previous + 1
        }
        lastSeenIndex[char] = i
        longest = max(longest, i - windowStart + 1)
    }
    return longest
}

lengthOfLongestSubstring("abcabcbb")   // 3 ("abc")
lengthOfLongestSubstring("bbbbb")      // 1 ("b")
lengthOfLongestSubstring("pwwkew")     // 3 ("wke")

/*:
 ---

 **Drill for today:** re-derive all five from a blank CoderPad-like editor (Xcode playground with no
 autocomplete hints, or just a plain text editor) in under 45 minutes total, narrating out loud as
 if an interviewer were listening — including the clarifying questions and complexity statements.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
