//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 3: Round 3 — Behavioral

 **CONFIRMED 2026-08-27, replacing this page's earlier "graphs/BFS/trees" guess.** The real loop, now
 fully known: foundation call (Day 1) → Round 1 bug-hunt in a given codebase (completed — rewards bug,
 root cause was using `rawValue` instead of `id`) → Round 2 from-scratch build with AI tools allowed
 (Day 2) → **Round 3: behavioral.** There is no separate "graphs/trees" or "iOS-style" round in the real
 loop — this page is now the guide for what's actually next.

 ## Contents
 - Part 1: What this round is likely evaluating, given the role shape
 - Part 2: STAR, compressed
 - Part 3: Likely questions with full model answers (built from your existing story bank)
 - Part 4: Questions to ask them — different flavor from Day 1's recruiter list, not a repeat
 - Part 5: How to close
 - Part 6: Pre-round checklist

 ---

 ## Part 1: What this round is likely evaluating

 A behavioral round this late in a senior, sole-iOS-owner loop is rarely generic "tell me about a
 conflict" filler — it's almost always checking for the specific traits that matter *because* of the role
 shape (Day 0, Part 1–2): can you operate with real autonomy, make defensible calls with no other iOS
 engineer to sanity-check you, communicate technical reasoning to a KMP/Go-fluent team, and handle
 ambiguity without stalling. Expect the interviewer (likely the hiring manager and/or a team member, not
 Korey) to probe past your rehearsed pitch into specifics — "what exactly did *you* do" not "what did the
 team do."

 ---

 ## Part 2: STAR, compressed

 **Situation** (1 sentence of context) → **Task** (what was actually yours to solve) → **Action** (the
 specific decisions/steps you took — this is the part interviewers actually listen for, don't rush it) →
 **Result** (outcome, ideally with a number or a concrete change). Most candidates under-invest in Action
 and over-invest in Situation — flip that ratio.

 ---

 ## Part 3: Likely questions, with full model answers

 **"Tell me about a time you disagreed with a technical decision, or had to push back."**

 > "The clearest example is actually from this loop — when Korey and I were first talking through the
 > role, before I'd even started formal prep, I told him that a feature like Add to Apple Wallet should
 > live entirely in native iOS code, not routed through the team's shared Kotlin Multiplatform module.
 > The instinct wasn't 'Kotlin can't call it' — technically it can reach older Objective-C-based
 > frameworks — it's that there's zero reuse value: Android's equivalent, Google Wallet, is a totally
 > different SDK, so a shared `expect`/`actual` for it would have exactly one real implementation and a
 > stub on the other side, which isn't what shared code is for. I raised that unprompted, before anyone
 > asked me to. That's the kind of call I'd expect to make regularly here, being the only iOS voice in a
 > room that defaults to 'can this be shared.'"

 **"Walk me through the biggest technical project you've led or driven."**

 > "That's the UIKit-to-SwiftUI rewrite on PayPal's Credit Card mobile team. I joined while the app was
 > still fully UIKit, and within a few months the team decided to rebuild the entire thing in SwiftUI. I
 > worked on it alongside roughly twenty-five to thirty engineers — not just my own screens, but helping
 > other people reason through the state-management differences between the two paradigms, since that was
 > the part that tripped people up most. The result was a fully modern SwiftUI app across all of our
 > credit-card flows. What I'd actually highlight if asked to go deeper: sequencing which screens moved
 > first mattered more than raw coding speed — we moved lower-risk, less-trafficked screens early to work
 > out our shared patterns (navigation, state ownership) before touching the highest-traffic flows like
 > Make-A-Payment."

 **"Tell me about a time you had to get up to speed on something unfamiliar quickly."**

 > "Two real examples, actually. The longer-term one: I came into this process with zero production KMP
 > experience, and rather than treat that as a gap to hide, I worked through the `expect`/`actual` model
 > and where the iOS/Kotlin boundary actually causes friction, so I could speak concretely about the
 > day-to-day even without having shipped it. The more immediate one: earlier today, in this same
 > interview loop, I did a build-from-scratch round where AI tools were explicitly allowed — which is
 > itself a 'get up to speed fast' moment, since the actual skill being tested wasn't typing Swift from
 > memory, it was directing an AI tool like a fast junior pair — stating architecture before prompting,
 > verifying every generated chunk before accepting it, catching the kind of subtle bug AI tends to
 > introduce."

 **"Tell me about a bug you found or a mistake you made, and how you handled it."**

 > If reusing today's Round 1 story feels redundant since this same company already watched it happen,
 > pivot to a genuine PayPal example instead — have one ready before the round: a specific bug, the wrong
 > assumption behind it, how you found it (not just "I fixed it"), and what you changed afterward
 > (a test added, a lint rule, a pattern documented) so it's a real prevention story, not just a fix
 > story. **Fill this in with a specific PayPal incident before the round if you have one in mind** — a
 > generic answer here is the one gap this page can't write for you.

 **"How would you handle being the only iOS engineer, with no one to review your architecture calls
 before they ship?"**

 > "The habit that matters most there isn't 'get code review approval,' since there's no one to give it —
 > it's writing decisions down clearly enough that someone unfamiliar with iOS, whether that's my KMP/Go
 > teammates now or a future second iOS hire later, can follow the reasoning after the fact. I'd also
 > lean harder on tests as the thing that catches what a second pair of eyes normally would, and treat
 > any genuinely uncertain call as worth a short written note explaining the tradeoff, not just a
 > decision made silently in my head."

 **"Tell me about a time you had to explain something technical to someone without your background."**

 > A good candidate: explaining the Wallet-native reasoning to Korey (non-engineer) in a way that landed
 > without PassKit jargon — cite the actual conversation, and note what you deliberately left out (the
 > Objective-C-cinterop nuance) for a non-technical audience versus what you'd include for a KMP-fluent
 > engineer. This shows audience-calibration, a real and checkable skill.

 **"Why Fanatics? Why this team specifically?"**

 > Same core answer as Day 1, Part 3 — credit-card domain overlap from PayPal, the sole-iOS-owner shape
 > as something you're seeking rather than tolerating, the Wallet insight as proof you already think this
 > way. Don't recite it identically if you already gave this to Korey; compress it and let the interviewer
 > ask a follow-up rather than performing the full pitch again.

 ---

 ## Part 4: Questions to ask them — a different flavor from Day 1

 Day 1's list was written for a recruiter screen (process/logistics-leaning). This round likely has a
 hiring manager or future teammate — better questions probe **team dynamics and how decisions actually
 get made**, not process:

 1. **"How does the team currently resolve a disagreement between what's easiest to build in the shared
    Kotlin module versus what's right for iOS specifically — is that a conversation, or does someone have
    final say?"** — directly probes the "iOS voice in a cross-platform-default room" dynamic from Day 0,
    Part 2.
 2. **"What does the review process look like for iOS-specific changes, given there's no other iOS
    engineer today?"** — a fair, practical question that also signals you've already thought about the
    sole-ownership tradeoff seriously.
 3. **"What's the biggest open technical risk for the Amex card launch from where you're sitting?"** —
    gives you real signal on what you'd actually be walking into, and a hiring-manager-level question
    a recruiter usually can't answer as concretely.
 4. **"How does the team decide what's worth building shared vs. native-only in practice — is there a
    real example besides Wallet where that call was close?"** — tests whether your Wallet reasoning
    (Part 3 above) matches how they actually think, and surfaces a second data point either way.
 5. **"What would make the first 90 days a clear success from your side, specifically — not the generic
    version, the thing you'd actually be relieved to see land?"**

 If time is short, ask 1 and 3 — they carry the most unique signal for a hiring-manager-level
 conversation and aren't things Korey could have answered as concretely.

 ---

 ## Part 5: How to close

 > "This was really useful — I feel like I have a much clearer picture of how the team actually resolves
 > the iOS-vs-shared question day to day, which was the thing I was most curious about coming in. I'm
 > still very much interested, and glad to follow up on anything if it'd help on your end."

 ---

 ## Part 6: Pre-round checklist

 - [ ] Fill in one real PayPal bug/mistake story (Part 3) — the one gap this page left open.
 - [ ] Have the Wallet-pushback story ready close to verbatim — it's your strongest "disagreed and was
       right" answer, and it's already proven to work since it's the exact thing that got Korey's
       attention originally.
 - [ ] Decide, in advance, how much of today's Round 1/Round 2 experience you're comfortable narrating if
       asked directly — both are genuinely good "learned fast under pressure" material.
 - [ ] Pick your Part 4 questions now, don't decide live — 1 and 3 first if time is short.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
