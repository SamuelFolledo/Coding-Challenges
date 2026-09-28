//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 1: The 30-Minute Foundation Call with Korey — Full Guide

 The recruiter (**Korey**) described three pieces: a **30-minute foundation call**, a **LeetCode-style
 round**, and an **"iOS-style" round**. This page is the full guide for the first of those — how to
 open, likely questions and how to answer them, 10 questions to ask back (with anticipated follow-ups),
 and how to close. A 30-minute call is short — there's no time for a deep technical dive, so treat it as
 the call where your **pitch (Day 0, Part 6)** and **"why this role" framing (Day 0, Part 2)** need to
 be tight and rehearsed, not the call to dive into KMP internals unprompted.

 ## Contents
 - Part 1: What 30 minutes realistically covers
 - Part 2: How to open the call
 - Part 3: Likely questions from Korey, with a full written intro and model answers
 - Part 4: 10 questions to ask Korey, with anticipated follow-ups
 - Part 5: Comp & leveling — how to raise it if it doesn't come up
 - Part 6: How to close the call
 - Part 7: Logistics checklist

 ---

 ## Part 1: What 30 minutes realistically covers

 Roughly: 2 min intro/opening, 5–8 min "tell me about yourself"/pitch, 10–15 min background/behavioral
 questions and role framing, 5–8 min your questions, wrap-up. Budget your pitch to genuinely fit in
 under a minute (Day 0, Part 6 is already sized for this) — a 3-minute answer here eats a third of the
 whole call. This call is also implicitly screening for **communication clarity under time pressure** —
 given the role is "sole iOS point of contact" on a cross-platform team, how clearly you explain a
 technical tradeoff to a non-iOS-fluent listener is itself a signal, not just content.

 ---

 ## Part 2: How to open the call

 Recruiter calls open fast — don't wait to be asked before establishing warmth and clarity. A simple,
 confident opening beats over-preparation here:

 > "Hi Korey, thanks for making the time — good to finally connect after our first conversation. I know
 > we've got about 30 minutes, so happy to dive right in wherever's most useful for you — whether that's
 > you walking me through what to expect, or me starting with a quick intro."

 This does three things deliberately: acknowledges you two have already talked (you're not a cold
 start), respects the time constraint out loud (signals the "communication under time pressure" instinct
 from Part 1), and hands control back to Korey to run his process rather than assuming your agenda.

 ---

 ## Part 3: Likely questions from Korey, with a full written intro and model answers

 Written out in full so there's no scrambling to reconstruct an answer live — say these in your own
 words rather than reciting them verbatim, but the content and shape are ready to go as-is.

 **"Tell me about yourself." — the full introduction**

 > "Sure. I'm an iOS engineer with six years of experience building customer-facing mobile apps. Most
 > recently I spent a year on PayPal's Credit Card mobile team, working across app flows that touched
 > all of PayPal's credit card products, not just one narrow feature. I actually joined while the app
 > was still UIKit, and a few months in I helped lead the effort to rewrite the entire thing to SwiftUI
 > alongside the rest of a team of about twenty five to thirty engineers, so I've been through a
 > full-app architecture migration at real scale, not just a greenfield SwiftUI project.
 >
 > What drew me to this role specifically is two things. First, it's directly in the credit card domain
 > I already work in, and I know this is for the new Fanatics American Express card, so that's a very
 > specific overlap, not a generic 'I like fintech' answer. Second, you'd mentioned I'd likely be the
 > only iOS engineer on a team that's otherwise built in Kotlin Multiplatform and Go, and that's exactly
 > the kind of ownership I want next, being the platform authority for iOS rather than one of several
 > engineers on a big iOS team. I actually flagged to you early on that something like Add to Apple
 > Wallet would need to live entirely in native code, since there's no real reuse value in routing it
 > through a shared module, and that's the kind of judgment I'd want to bring here day to day."

 This runs close to a minute spoken at a normal pace. If Korey wants shorter, the trim is easy: drop the
 second paragraph's Wallet sentence and end after "platform authority for iOS."

 **"Why are you looking to leave PayPal / why now?"**

 > "It's less about leaving and more about what I want to grow into next. PayPal is a great team, and
 > I'm proud of the migration work we did, but on a team that size, ownership naturally gets split
 > across a lot of engineers. I'm at a point where I want more end to end ownership than that structure
 > tends to hand any one person, and this role, being the sole iOS point of contact on the team, is
 > almost the opposite shape. That's a real pull, not a reaction against where I am now."

 Keep this forward-looking, never a complaint about PayPal specifically.

 **"What do you know about Fanatics / this role?"**

 > "I know this is for the Fanatics App team, and specifically the Credit Card side, which I understand
 > is the new Fanatics American Express card that was announced earlier this year, issued through First
 > Electronic Bank and running on the Amex network. I also know the team builds primarily in Kotlin
 > Multiplatform and Go, and that I'd likely be the only iOS specialist on it, which is a pretty
 > different setup than a typical iOS req. One thing I already thought through on my own before we even
 > got into details: a feature like Add to Apple Wallet would need to be handled entirely in native
 > code, since there's no real shared logic value in routing it through the Kotlin module. That's the
 > kind of thing I'd expect to be reasoning about regularly in this role."

 **"Walk me through a project you're proud of."**

 > "The one I'd point to is the UIKit to SwiftUI rewrite at PayPal. I joined the credit card mobile
 > team while the app was still fully UIKit, and within a few months the team decided to rebuild the
 > entire thing in SwiftUI. I worked on that alongside roughly twenty five to thirty other engineers,
 > handling both my own screens and helping other people work through the state management differences
 > between the two paradigms. The result was a fully modern SwiftUI app across all of our credit card
 > flows, and I came out of it with real experience operating through a team wide architecture change,
 > not just writing SwiftUI in a vacuum."

 Keep this to roughly this length on the 30-minute call, two to three sentences worth of content. A
 fuller technical deep dive, if asked for one, is a later-round conversation.

 **"What are you looking for in terms of comp / timeline / other processes?"**
 See Part 5.

 ---

 ## Part 4: 10 questions to ask Korey, with anticipated follow-ups

 A 30-minute call rarely fits all 10 — this is a **menu**, ranked by priority; Q1–Q3 are the ones to
 make sure land even if time runs short. Each has a likely-answer branch so you're not caught flat if
 Korey's response opens a door worth walking through.

 **1. "You mentioned a new interview process starting mid-August — can you walk me through what the
 LeetCode-style round and the iOS-style round each actually look like?"** *(highest priority — this is
 the single most valuable thing to learn on this call, since Days 2–10 of this prep are built on
 inference without it)*
 - *If he says the iOS round is live-coding* → follow up: "Is that building a feature from a blank
   project, or working within existing skeleton code?" (mirrors the Robinhood-style project-call
   distinction — materially changes how you'd prep).
 - *If he says it's more conceptual/design-discussion* → follow up: "Would that include discussing how
   iOS integrates with the team's Kotlin Multiplatform code, or is it iOS in isolation?"
 - *If he's vague/doesn't know the details himself* → don't push further; note it and move to Q2.

 **2. "Are the two technical rounds separate calls, or combined into one session?"**
 - *If combined* → follow up: "Roughly how is the hour split between them?" — useful for pacing prep
   time between Days 2–3 vs. 4–5/9–10.
 - *If separate* → follow up: "Is there a gap between them, or are they scheduled close together?"

 **3. "Who will I be meeting for each round — can I get names/titles ahead of time?"**
 - *If he gives a name* → immediately worth a mental note to look them up on LinkedIn afterward (not
   during the call) for shared background/interests.
 - *If titles suggest a KMP/Android-background interviewer for the "iOS round"* → strong signal that
   round leans conceptual/cross-platform rather than deep SwiftUI trivia — worth weighting Day 10
   accordingly afterward.

 **4. "You mentioned I'd likely be the only iOS engineer on a team that otherwise works in Kotlin
 Multiplatform and Go — how is iOS-specific code organized today: is there an existing `expect`/
 `actual` pattern in place, or would I be helping establish that structure?"**
 - *If there's already a pattern in place* → follow up: "Is there documentation on it, or would that be
   something I'd learn by reading the codebase?" (a fair, practical onboarding question.)
 - *If it's genuinely greenfield/ad hoc* → follow up: "Is establishing that structure something the team
   is hoping the new hire drives, or has an architecture direction already been decided elsewhere
   (e.g. by a staff/principal engineer)?" — materially changes the scope of the role.

 **5. "Is there a second iOS hire planned, or is this genuinely a long-term single-iOS-owner setup?"**
 - *If a second hire is planned* → follow up: "Would I be involved in that hiring process?" (ties
   directly to the JD's "mentor junior engineers" bullet — Day 0, Part 3).
 - *If it's long-term single-owner* → follow up: "What does coverage look like when I'm out — PTO,
   sick time — is there a backup plan for iOS-specific issues?" (Day 6, Part 5's on-call question,
   asked here in a lower-stakes, information-gathering way rather than a technical round.)

 **6. "Does the Credit Card team share business logic only through Kotlin Multiplatform, or UI code too,
 via Compose Multiplatform? And is the shared module rebuilt fresh as part of the iOS build, or consumed
 as a versioned, published xcframework?"** *(two related questions worth asking together — both shape
 what day-to-day iOS work and CI actually look like — Day 6, Part 3 and Day 8, Part 7 cover why the
 delivery-mechanism half matters)*
 - *If UI is also shared* → follow up: "So would native SwiftUI work mostly be wrapping/rendering
   shared UI components, or building fully native screens on top of shared state?" — this is a real
   fork in what day-to-day looks like, worth nailing down.
 - *If it's business logic only* → this matches the Day 0, Part 2 assumption; no follow-up needed on
   that half.
 - *If the module is rebuilt fresh locally* → follow up: "Does that add much to local build time?"
 - *If it's a versioned, published artifact* → follow up: "How is that publish cadence coordinated with
   iOS release timing?" — directly probes the release-coupling risk from Day 6, Part 3 / Day 8, Part 7.

 **7. "What does the current test coverage and CI setup look like for iOS specifically?"**
 - *If it's mature* → follow up: "Is that Fastlane/GitHub Actions, per the JD, or something else?"
 - *If it's thin/nonexistent* → follow up, framed as enthusiasm not criticism: "Would setting that up be
   an early priority, or is there a roadmap reason it hasn't been built out yet?"

 **8. "What's the biggest challenge the last person in this kind of iOS-on-a-cross-platform-team role
 ran into here — assuming there was a predecessor?"**
 - *If there was a predecessor who left* → tread carefully, but a natural, non-awkward follow-up:
   "Was that more about the technical setup, or more about team/process dynamics?" — useful signal
   either way, and shows you're thinking seriously about the role's real shape, not just its upside.
 - *If this is a net-new role* → follow up: "What prompted the team to decide they needed a dedicated
   iOS hire now?" (often reveals a concrete trigger — a launch, a KMP migration starting, a compliance
   deadline — genuinely useful context.)

 **9. "What does success look like in the first 90 days for whoever fills this role?"**
 - *Answer will almost always be somewhat generic ("ramp up, ship something small")* → follow up:
   "Is there a specific first project already in mind, or would that get decided once I'm ramped up?" —
   a good way to surface whether there's a concrete Wallet-provisioning-style project waiting, which
   would let you prep even more specifically if the timeline allows before an offer.

 **10. "What's the timeline looking like for this loop, and when should I expect to hear back after each
 round?"**
 - *Standard logistics* — rarely needs a follow-up, but if Korey gives a vague answer, it's fair to ask
   directly: "Is there flexibility if I need a few extra days between rounds to prepare?"

 ---

 ## Part 5: Comp & leveling — how to raise it if it doesn't come up

 Per Day 0, Part 5, the only number in hand is the JD's posted **$152k–$200k base**, unconfirmed
 against any specific level. If it doesn't come up naturally, it's fair to raise directly:

 > "The posting lists $152k–$200k base — where in that range would this req typically land for someone
 > with my background, and is that base-only or does it include target equity/bonus?"

 Don't negotiate a number yet — there's no offer. The goal is information: what level this maps to,
 what the full comp structure looks like, and whether "sole iOS owner" scope is reflected in leveling.

 ---

 ## Part 6: How to close the call

 Close with warmth, a clear next-step ask, and one line that reinforces your strongest asset without
 re-pitching from scratch:

 > "This has been really helpful, thanks, Korey — I'm even more excited about the role after hearing
 > [reference something specific he said]. Given the credit-card domain overlap from my PayPal
 > background and the kind of platform ownership this role is looking for, I feel like a strong fit, and
 > I'm looking forward to the next rounds. What's the best way to follow up if I think of anything else
 > before then — email, or back through you directly?"

 The bracketed callback is important — it proves you were listening, not just executing a script.

 ---

 ## Part 7: Logistics checklist

 - [ ] Time the Day 0, Part 6 pitch out loud — trim until it's under 60 seconds.
 - [ ] Confirm the call's format (phone vs. video) and platform ahead of time.
 - [ ] Have Q1–Q3 from Part 4 memorized cold; the rest as a backup list, not memorized verbatim.
 - [ ] Ask Q1 directly — this is the single highest-value question on this call, since Days 2–5 and
       9–10 are built on inference, not confirmation, until Korey answers it.
 - [ ] Re-read your own resume bullets the morning of — assume every bullet is fair game later in the
       loop even if this call stays high-level.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
