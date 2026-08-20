//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 2: Coding Round Pt 1 — Arrays, Strings, Hashmaps

 Public candidate reports (general SWE roles, not iOS-specific, possibly a different/older process —
 see Day 0, Part 7) describe the coding round as **1 hour, remote, "not LeetCode medium/hard"
 difficulty**. Read that as a signal to prioritize speed, clean code, and clear communication over
 knowing an obscure algorithm — for a *senior* role, the bar is less "can you solve it at all" and
 more "do you solve it fast, cleanly, and explain your tradeoffs like someone who'd review someone
 else's PR for the same problem."

 ## Contents
 - Part 1: The approach — narrate before you type
 - Part 2: Two Sum (hashmap warm-up)
 - Part 3: Group Anagrams
 - Part 4: Longest Substring Without Repeating Characters (sliding window)
 - Part 5: [public-reported] An ASCII chart-plotting problem — an actual Fanatics report
 - Part 6: Senior-level follow-ups to expect after "the right answer"

 ---

 ## Part 1: The approach — narrate before you type

 Same advice that applies everywhere in this format (it's explicitly graded in most companies' rubrics,
 not just implied): restate the problem in your own words, ask 1–2 clarifying questions (empty input?
 duplicates? sorted?), state the brute-force complexity, then state the better approach *before* typing
 it. For "not medium/hard" problems specifically, resist the urge to rush straight to code just because
 it feels easy — the narration is graded independently of correctness.

 ---

 ## Part 2: Two Sum

 > **Problem:** Given an array of integers and a target, return the indices of the two numbers that
 > add up to the target. Assume exactly one solution exists.

 The canonical "do you reach for a hashmap instead of nested loops" warm-up.
*/

func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
    var seen: [Int: Int] = [:]   // value -> index

    for (index, num) in nums.enumerated() {
        let complement = target - num
        // Check BEFORE inserting the current number — otherwise a value that happens to equal
        // its own complement (e.g. target 6, num 3) would incorrectly pair an index with itself.
        if let complementIndex = seen[complement] {
            return [complementIndex, index]
        }
        seen[num] = index
    }
    return []
}

twoSum([2, 7, 11, 15], 9)   // [0, 1]
twoSum([3, 3], 6)           // [0, 1] — the self-complement case the ordering above guards against

/*:
 **What to say out loud:** "brute force is O(n²) checking every pair; a hashmap gets this to O(n) time
 / O(n) space by trading the second loop for a lookup — and I'm checking for the complement before I
 insert the current value, so a number that pairs with itself doesn't match against its own index."

 ---

 ## Part 3: Group Anagrams

 > **Problem:** Given an array of strings, group the ones that are anagrams of each other.

 The pattern-recognition test here: anagrams share a **sorted-character signature**, so that signature
 is the natural hashmap key.
*/

func groupAnagrams(_ strs: [String]) -> [[String]] {
    var groups: [String: [String]] = [:]

    for str in strs {
        // Sorting each string into a canonical key is what makes "eat"/"tea"/"ate" collide into the
        // same bucket — any two anagrams sort to the identical character sequence.
        let key = String(str.sorted())
        groups[key, default: []].append(str)
    }
    return Array(groups.values)
}

groupAnagrams(["eat", "tea", "tan", "ate", "nat", "bat"])
// [["eat","tea","ate"], ["tan","nat"], ["bat"]] (order of groups/within groups not guaranteed)

/*:
 **Complexity worth stating:** O(n · k log k) where n is the array length and k is the max string
 length — sorting each string dominates. A follow-up worth anticipating: "can you avoid the sort?" —
 yes, a character-frequency count (26-length array or dictionary) as the key gets this to O(n · k), a
 good senior-level optimization to volunteer if there's time.

 ---

 ## Part 4: Longest Substring Without Repeating Characters

 > **Problem:** Given a string, find the length of the longest substring without repeating characters.

 The classic sliding-window pattern — worth having crisp, since it generalizes to a large family of
 "longest/shortest substring/subarray satisfying a condition" problems.
*/

func lengthOfLongestSubstring(_ s: String) -> Int {
    var lastSeenIndex: [Character: Int] = [:]
    var windowStart = 0
    var longest = 0

    for (i, char) in s.enumerated() {
        // Only jump windowStart forward if the previous occurrence is INSIDE the current window —
        // a stale index from before windowStart would incorrectly shrink a window that's already
        // valid (e.g. "abba": when the second 'a' is seen, its stored index 0 is before the
        // window's current start, so it must NOT yank windowStart backward).
        if let seenAt = lastSeenIndex[char], seenAt >= windowStart {
            windowStart = seenAt + 1
        }
        lastSeenIndex[char] = i
        longest = max(longest, i - windowStart + 1)
    }
    return longest
}

lengthOfLongestSubstring("abcabcbb")   // 3 ("abc")
lengthOfLongestSubstring("bbbbb")      // 1 ("b")
lengthOfLongestSubstring("pwwkew")     // 3 ("wke")
lengthOfLongestSubstring("abba")       // 2 ("ab" or "ba") — the stale-index guard above matters here

/*:
 **What to say out loud:** "I'm keeping a window `[windowStart, i]` that's always duplicate-free —
 when I hit a repeat, I only advance the start past the *previous* occurrence if that occurrence is
 still inside the current window, otherwise I'd shrink a window that's already valid."

 ---

 ## Part 5: [public-reported] An ASCII chart-plotting problem

 A real reported Fanatics interview question (December 2025, role unspecified — treat with the same
 caution as any single-report question): *"Write a program that displays an ASCII chart given data
 like `{(1,2), (2,3), (3,1), (4,6), (5,8)}`."* Low-confidence as a *current* question, but worth a fast
 runnable version since it's cheap prep and tests a different skill than the algorithms above — careful
 2D-grid/string-building logic under ambiguous spec, which rewards clarifying questions (bar chart or
 scatter? oriented which way? 1-indexed?) more than cleverness.
*/

func asciiBarChart(_ points: [(x: Int, y: Int)]) -> String {
    guard let maxY = points.map(\.y).max(), maxY > 0 else { return "" }

    var lines: [String] = []
    // Iterate top-down (maxY first) since a bar chart's tallest row prints FIRST — each row asks
    // "which points reach at least this height," which is the mirror image of building bottom-up.
    for row in stride(from: maxY, through: 1, by: -1) {
        var line = ""
        for point in points.sorted(by: { $0.x < $1.x }) {
            line += point.y >= row ? "*  " : "   "
        }
        lines.append(line)
    }
    lines.append(points.sorted(by: { $0.x < $1.x }).map { "\($0.x)  " }.joined())   // x-axis labels
    return lines.joined(separator: "\n")
}

print(asciiBarChart([(1, 2), (2, 3), (3, 1), (4, 6), (5, 8)]))

/*:
 **What to say out loud if given a vague spec like this live:** ask first — bar chart vs. scatter plot,
 whether the x-values are guaranteed contiguous/sorted/1-indexed, and what should happen with negative
 or zero values — this kind of problem is testing whether you interrogate an ambiguous spec before
 building the wrong thing, more than whether you know a specific algorithm.

 ---

 ## Part 6: Senior-level follow-ups to expect after "the right answer"

 Given the "not medium/hard" difficulty signal, expect the bar to shift to **follow-up depth** once
 you've solved the base problem — this is where senior candidates separate from mid-level ones:

 - "How would you test this?" — have a real answer: edge cases (empty input, single element, all
   duplicates), not just "I'd write a unit test."
 - "How would you change this if the input were a stream instead of a fixed array?" (Two Sum → running
   hashmap without a fixed end; sliding window → naturally already stream-friendly.)
 - "What if the input were too large to fit in memory?" — a fair question for any of these; know when
   to say "I'd need to chunk/stream it and this exact approach wouldn't scale as-is" rather than forcing
   an in-memory answer to fit.
 - "Refactor this for readability" — given the JD's explicit call-out of "code quality/refactoring" as
   a graded dimension, be ready to clean up your own first-pass code once it's correct, not just leave
   it as the fastest thing that compiled.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
