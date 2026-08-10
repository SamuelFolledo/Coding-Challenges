//: [Previous](@previous)

import Foundation

/*:
 # Robinhood Finals — Day 5: Foundation Call — Project Deep-Dive

 ## TODO — confirm or correct before you rely on this

 Everything in Part 3-5 below is a **plausible, invented telling** of the PayPal Make-A-Payment
 story — filled in to give you a concrete draft to react to and adjust, not a transcript of what
 actually happened. Read it, then tell me what's wrong so I can update it to what's real. Specific
 things to check:

 1. Team size/composition — guessed 4 iOS engineers + 1 backend engineer + 1 PM + 1 designer (~7
    total). Adjust to the real number.
 2. Duration — guessed ~3.5 months, tied to a Q-end launch deadline. Adjust.
 3. Your specific ownership — guessed you designed the shared-view architecture *and* built it
    yourself. If a teammate owned part of this, say which part.
 4. Tech stack — guessed SwiftUI (mid-migration off UIKit), a TCA/MVI-style architecture (Combine +
    a use-case layer), GraphQL via a client like Apollo. Adjust to what PayPal actually used.
 5. The specific navigation complexity — guessed: different funding-source rules per flow (PayPal
    balance allowed for one-time, not for Autopay), different step counts (one-time is 3 steps,
    Autopay is a multi-step wizard with draft-state restoration if the app backgrounds mid-setup).
    Adjust to the real technical wrinkle if different.
 6. The rejected approach — guessed the team first considered duplicating the view, then a
    boolean `isAutopay` flag baked into it, both rejected in review. Adjust if the real story differs.
 7. The final approach — guessed a `PaymentFlowContext` protocol injected into the shared
    view/reducer, with a separate `FlowCopyProvider` for flow-specific copy after a disagreement
    about where that boundary should live. Adjust.
 8. The metric — guessed: reused-view Autopay setup completion rate improved, navigation-bug reports
    dropped versus the prior UIKit-based Autopay screen, and the shared component saved rework on a
    later design-system update. Replace with a real number/outcome if you have one, even
    approximate.
 9. The hardest bug — invented a missed-case bug where changing funding source mid-review didn't
    re-trigger fee recalculation. Replace with a real bug if you remember one, even roughly.
 10. Backup story — guessed FuFight (your own app) and a client-authoritative-vs-server-authoritative
     disagreement over real-time match state. Confirm or swap for a different second project.
 11. Day 0's "tell me about a mistake" answer invents a separate incident — a funding-source
     currency-mismatch validation bug caught via monitoring, fixed with a hotfix plus a new
     combinatorial test matrix. Confirm/replace that one too; it's tracked here since it's the same
     kind of invented specific.

 Once you've corrected these, let me know and I'll update this page (and Day 0's matching answer) to
 match reality.

 ## Contents
 - Part 0: Why this story is a strong match for this specific req
 - Part 1: What's actually graded
 - Part 2: The framework
 - Part 3: Your story — PayPal Make-A-Payment (draft telling — verify against TODOs above)
 - Part 4: Anticipated follow-up questions + example answers
 - Part 5: Backup story — FuFight (draft — verify against TODO 10)

 ---

 ## Part 0: Why this story is a strong match for this specific req

 The JD (see Day 0) lists "experience working on financial systems, payments, or account-related
 platforms" as **preferred** — not a generic nice-to-have, a direct hit for a payments deep-dive.
 Don't assume the interviewer will connect PayPal-payments-experience to this team's
 account/retirement domain themselves — say it explicitly early in the telling: *"This is a payments
 flow specifically, which is close to the account-management and long-term-investing domain this
 team works in — money movement and account state both carry the same bar for correctness."* Also
 worth having ready: **"Why fintech?"** is a commonly reported behavioral question (Day 0, Part 6) —
 this story doubles as the answer to that too.

 ---

 ## Part 1: What's actually graded

 - **Clarity on tech/tools** — can you name the actual stack precisely (not "we used SwiftUI" but
   *which* navigation approach, *which* state layer, *why*)?
 - **Impact & customer value** — not just "it shipped," but who it helped and how you know.
 - **Scale signals** — team size, duration, deadline pressure. A 2–4 month, multi-person project is
   the sweet spot; a solo 2–3 week project reads as too small for this level.
 - **How success was measured** — a number, even an approximate one, beats "it went well."
 - **Your specific contribution** — interviewers will probe to separate what *you* did from what the
   team did. Be ready to say "I designed X, a teammate built Y, together we Z."

 ---

 ## Part 2: The framework

 Use STAR, but weighted toward the two things this call grades hardest: **Task** (scope/tech) and
 **Result** (impact/metric). Don't let Situation eat your time budget.

 ```
 Situation  | 1-2 sentences: what the product surface was, why it needed to exist
 Task       | The technical challenge specifically, and your role in it
 Action     | What you did — including the wrong turn you almost took and why you didn't
 Result     | The metric or concrete outcome, plus what you'd change in hindsight
 ```

 Budget roughly: 15% Situation, 35% Task, 35% Action, 15% Result — the middle two are where the
 signal is.

 ---

 ## Part 3: Your story — PayPal Make-A-Payment

 A full draft telling, in the shape you'd actually say it out loud. Read it once, then rewrite it in
 your own words — the goal is to internalize the *structure*, not recite this script.

 **Situation** *(~20 seconds)*
 > "At PayPal I worked on the Payments team, on a feature called Make-A-Payment — the one-time
 > payment flow. Partway through, product decided Autopay, our recurring-payment setup, should reuse
 > the same amount-entry-and-review screen instead of maintaining a separate one, mainly to keep the
 > experience consistent and cut down on duplicated UI work across two flows that were fundamentally
 > doing the same core thing."

 **Task** *(~45 seconds)*
 > "This was about a 3.5-month project, a team of four iOS engineers plus one backend engineer, a PM,
 > and a designer. I owned the navigation and state architecture for the shared screen specifically —
 > designed it and built the core of it, with two teammates building out the flow-specific screens on
 > either side of it. The hard part was that 'reuse' wasn't free: one-time payments allowed paying
 > from a linked bank account, a card, or PayPal balance, each with different fee rules, while Autopay
 > required a stable funding source, so PayPal balance wasn't a valid option there — and Autopay's
 > setup was a multi-step wizard where a user could background the app mid-setup and needed to come
 > back to an intact draft, while one-time payment was a simple three-step flow with no persistence
 > need at all. So the same screen had to behave differently depending on which flow launched it,
 > without becoming a screen full of `if isAutopay` branches."

 **Action** *(~90 seconds)*
 > "Our first instinct, given a launch deadline tied to a marketing push, was to just duplicate the
 > screen for Autopay — fastest path, ship on time. I pushed back on that in design review, because we
 > had a design-system refresh already planned for the following quarter, and duplicating meant every
 > future visual change had to be made and QA'd twice. A teammate then proposed a middle ground — keep
 > one view, but thread an `isAutopay` boolean through it. I didn't love that either: it meant the view
 > itself had to know about both flows, which made almost every unit test branch on that flag, and it
 > would only get worse if a third flow ever reused the screen. What we landed on was a
 > `PaymentFlowContext` protocol — each flow supplies its own funding sources, fee rules, and
 > validation, and the shared reducer just consumes whatever context it's given, with zero knowledge
 > of which concrete flow it's in. There was a real disagreement along the way: I wanted that protocol
 > to also own the screen's copy — button labels, error strings — but our tech lead felt that mixed
 > business logic with presentation concerns. We resolved it by splitting it: the `PaymentFlowContext`
 > protocol stayed strictly business rules — funding sources, fee calculation, validation — and a
 > separate, lightweight `FlowCopyProvider` handled copy. That review, and the tech lead's sign-off on
 > the split, is honestly what made the design hold up as more flows got added later."

 **Result** *(~30 seconds)*
 > "It shipped on time for the launch. Because Autopay reused an already-hardened screen instead of a
 > freshly built one, its setup-completion rate came in noticeably higher than our early estimates —
 > fewer users dropped off mid-setup than the team expected based on the old UIKit Autopay flow's
 > numbers. Navigation-related bug reports against the payment flow, which had been one of the more
 > commonly filed categories against the old Autopay screen, dropped close to zero in the release
 > cycle after launch. And when the design-system refresh landed the next quarter, updating one shared
 > screen instead of two saved real engineering time that the team had budgeted for and didn't end up
 > needing."

 ---

 ## Part 4: Anticipated follow-up questions + example answers

 - **"Why not just duplicate the view for Autopay instead of sharing it?"**
   > "We actually started down that path, given the deadline — it was the fastest option. What
   > changed my mind was the design-system refresh already on the roadmap for the next quarter: two
   > views meant every visual change got made and QA'd twice, and they'd drift apart over time as each
   > got independent bug fixes. The tradeoff is real, though — a shared view needs more discipline
   > about what's flow-specific versus shared, and it's a slightly harder mental model for someone new
   > to the code."

 - **"How would this scale to a third payment flow reusing the same view?"**
   > "Cleanly, for the business-logic side — a third flow just supplies its own
   > `PaymentFlowContext` conformance, and the shared reducer doesn't change. Where it wouldn't scale
   > cleanly as-is: the Router only knew about two exit destinations, a confirmation screen or a
   > cancel path. A third flow with a genuinely different completion step — say, one that needed a
   > follow-up verification screen — would need the Router's contract extended. That was a known,
   > scoped gap we didn't solve because we didn't have a third flow yet."

 - **"What was the hardest bug you hit building this?"**
   > "A funding-source switch bug. If a user changed their funding source while reviewing the payment
   > — say from a bank account to a card — the fee display didn't update. It turned out the reducer's
   > fee recalculation was only wired to a subset of the state-change cases, and switching funding
   > source wasn't one of them, so the UI kept showing the old fee. A beta tester caught it, not our
   > tests, which was the real problem. Once fixed, I added a state-derivation test that explicitly
   > covered funding-source changes, since that was the exact class of bug our existing tests missed."

 - **"If you had another month, what would you improve?"**
   > "Two things. I'd have pushed for the `FlowCopyProvider` split from day one instead of adding it
   > mid-project once the disagreement came up — it was the right call, just later than it should've
   > been. And I'd have written the state-derivation tests, like the fee-recalculation one, proactively
   > for every case in the reducer rather than reactively after a bug surfaced."

 - **"How was this decision reviewed — did you get sign-off from anyone, or was it your call?"**
   > "It went through a design review with our tech lead and one senior peer, and the PM signed off on
   > the scope/timeline tradeoff of doing the shared-view approach instead of the faster duplicate-view
   > option. The copy-versus-business-logic split specifically was the tech lead's call after I raised
   > it — I drove the proposal, but it wasn't a unilateral decision."

 ---

 ## Part 5: Backup story — FuFight

 A lighter-weight second story in case the interviewer asks for "another project" or specifically "a
 time you disagreed with someone" and PayPal doesn't fit that angle.

 - **Project:** FuFight, a personal real-time 1v1 fighting-mechanics app — built solo on the iOS/UI
   side, with a friend contributing art assets and helping think through backend/sync questions.
 - **The wrinkle:** a real disagreement over whether match state should be client-authoritative (each
   phone simulates the fight locally, syncs periodically) or server-authoritative (every move
   validated server-side before being applied). Client-authoritative was faster to build and felt
   more responsive; server-authoritative was more resistant to a fast/malicious client claiming a hit
   that didn't happen.
 - **How it resolved:** prototyped both for a single move type over a weekend rather than debating it
   further — client-authoritative had noticeably better feel (no input lag), server-authoritative
   caught the one deliberate desync test cleanly. Landed on a hybrid: client-predicted locally for
   responsiveness, server-validated asynchronously with a rollback-and-correct if the two disagreed —
   a smaller-scale version of the same "don't guess, prototype and measure" instinct from the PayPal
   story.
 - **The outcome:** shipped the hybrid model; it held up under casual testing without needing a full
   rollback-correction to actually fire in normal play, which suggested client prediction was accurate
   enough in practice that the server-authority was mostly a safety net rather than something users
   would feel.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
