//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 7: Final Review, Questions to Ask & Countdown Checklist

 Last page — pulls together the questions worth asking across the loop (not just the 30-min call from
 Day 1) and a countdown checklist for the days before each round.

 ## Contents
 - Part 1: Questions to ask in the technical/iOS rounds specifically
 - Part 2: The three-sentence answer to the question you'll get in every round
 - Part 3: Red flags / green flags to listen for
 - Part 4: Countdown checklist
 - Part 5: One-page cheat sheet — cross-reference to every Day

 ---

 ## Part 1: Questions to ask in the technical/iOS rounds specifically

 Day 1, Part 3 covers the 30-min call. These are different — better suited to a technical interviewer
 who can actually answer them with real detail, not a recruiter:

 - "How is the shared KMP module versioned and delivered to iOS today — rebuilt as part of the iOS
   build, or consumed as a published xcframework?" *(Day 6, Part 3 — genuinely useful info, not just a
   rapport question)*
 - "Does the Credit Card team share business logic only, or UI too via Compose Multiplatform?"
   *(Day 0, Part 4)*
 - "What does the SDUI rendering engine look like today — is there an existing component library, or
   would building it out be part of this role?" *(directly shapes what "day one" looks like)*
 - "Is there a second iOS hire planned, or is single-iOS-owner the long-term shape of this team?"
   *(Day 1, Part 3 — worth asking again here if a technical interviewer can give a more informed answer
   than the recruiter could)*
 - "What does the current test coverage/CI setup look like for iOS specifically?" — shows genuine
   engineering-practice interest, not just feature-building interest.

 ---

 ## Part 2: The three-sentence answer to the question you'll get in every round

 Across a 30-min call, a coding round, and an iOS round, some version of **"why this role"** will come
 up more than once — having one consistent, compressed answer prevents sounding like a different person
 each time:

 > "This is a credit-card product, which is directly the domain I already work in at PayPal. It's also
 > a role where I'd be the sole iOS owner on a Kotlin Multiplatform and Go team, which is exactly the
 > kind of platform-ownership I want next rather than another feature-engineer seat on a large iOS team.
 > And I already think the way this role needs someone to think — I flagged to your recruiter, before
 > we'd even discussed architecture, that Add to Apple Wallet has to be native because PassKit has no
 > cross-platform surface."

 ---

 ## Part 3: Red flags / green flags to listen for

 Since this is genuinely a different kind of role (sole owner, not team member) — worth actively
 listening for signal on whether the *actual* day-to-day matches the Day 0, Part 2 picture, not just
 assuming it does:

 **Green flags**: a technical interviewer who can clearly explain the `expect`/`actual` boundary
 already in place (means real architecture exists, not "figure it out yourself"); a clear answer on who
 reviews iOS PRs today; a stated plan (even informal) for a second iOS hire; specific SDUI component
 library already in progress rather than "we're thinking about it."

 **Yellow/red flags worth probing, not panicking over**: "we haven't really thought about iOS-specific
 CI yet" (fine if framed as "you'd help set it up," concerning if framed as "no one's owned this"); no
 clear answer on backup/escalation coverage when you're out; a KMP-first team that seems to expect iOS
 to just consume whatever the shared module produces without genuine cross-platform architecture
 conversation (contradicts "point of contact for the iOS side" framing from the recruiter).

 ---

 ## Part 4: Countdown checklist

 **A few days before:**
 - [ ] Re-read Day 0 in full — the day-to-day reasoning (Part 2) and the Wallet story (Part 4) are the
       two things most worth having word-for-word ready.
 - [ ] Time the pitch (Day 0, Part 6 / Day 1) out loud — under 60 seconds.
 - [ ] Confirm with the recruiter what the LeetCode-style and iOS-style rounds actually look like, if
       you haven't already (Day 1, Part 5 — the single highest-leverage open item).

 **Day before:**
 - [ ] Re-run Days 2–3's code snippets mentally (or actually run them in this playground) — Word Ladder
       and the sliding-window pattern especially.
 - [ ] Re-read Day 4 and Day 5 once each — not to memorize, just to refresh the vocabulary
       (`expect`/`actual`, SDUI component tree, Coordinator/publisher testability) so it's fluent, not
       reconstructed live.
 - [ ] Confirm CoderPad/whatever platform works in your browser, and that Xcode launches a blank
       project cleanly, in case either round is live-coding.

 **Morning of:**
 - [ ] Re-read your own resume bullets — assume every one is fair game, especially the PayPal
       Credit Card mobile team specifics.
 - [ ] Have a notepad ready to note each interviewer's name and what they emphasized.
 - [ ] Re-read Part 2 above one more time — the compressed "why this role" answer.

 ---

 ## Part 5: One-page cheat sheet — cross-reference to every Day

 ```
 Day | Topic                                    | Pull this out for...
 ----+-------------------------------------------+----------------------------------------------
 0   | JD deep dive, day-to-day, pitch, Wallet    | Any round — the throughline for everything
 1   | 30-min foundation call                     | The first call
 2   | Arrays/strings/hashmaps                    | LeetCode-style round, easier half
 3   | Graphs/BFS (Word Ladder), trees            | LeetCode-style round, harder half
 4   | MVVM/Coordinator/publishers/DI/concurrency | iOS round, conceptual/trivia-flavored version
 5   | SDUI, KMP boundary, live-build, profiling  | iOS round, hands-on/system-design version
 6   | CI/CD, on-call, review, mentoring          | Any round that goes into engineering practice
 7   | This page                                  | The night before / morning of every round
 ```

 [↑ Back to Top](#top)
*/
