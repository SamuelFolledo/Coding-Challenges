//: [Previous](@previous)

import Foundation

/*:
 # Robinhood Finals — Day 5: Foundation Call — Project Deep-Dive

 ## TODO — updated 2026-08-13 with your real specifics

 The previous version of this page told an invented "Autopay reuses Make-A-Payment's screen" story —
 that was a placeholder draft, never real, and it's now fully replaced below with the actual
 Make-A-Payment flow you described. If Day 0 or Day 8 still reference the old Autopay framing
 (per memory, they cross-referenced it), flag it and I'll fix those too — out of scope for this pass
 since you only asked about Day 5.

 What's now confirmed and baked into Part 3-6 below: the four screens and what each does, the
 GraphQL query/mutation split between you and your mentor, the Jan-March (+ April bug-fix tail) this
 year timeline, that you didn't design the MVI/TCA-lifecycle architecture or navigation pattern, the
 "one of two most complex flows at the time" framing, the UIKit→SwiftUI transition + flaky CI context,
 and the QA/friends-and-family/production bug result.

 Still open — check these before you rely on Part 4's follow-up answers especially:
 1. **Full team size.** Confirmed: you + your mentor as the iOS engineers, plus a product-team POC
    for UI/wireframe questions. Unconfirmed: backend engineer count, PM, designer, or other iOS
    engineers not hands-on with this specific feature. If asked "team size," you need a real number.
 2. **Why PayPal balance isn't valid for a future-dated payment.** I haven't invented a reason in the
    text below — if you don't have a crisp one-liner (e.g. "balance has to be verified at time of
    payment, not guaranteed days out"), that's worth having ready since it's the crux of nuance 1.
 3. **The actual mechanism for the conditional push/pop logic** — what did you call the thing that
    decides "push ChooseWayToPay again" vs "pop back to PaymentReview"? Described generically below
    (a navigation/effect layer reacting to reducer state) without a made-up type name — fill in the
    real term if you want to sound precise under a follow-up.
 4. **Nuance 2, debit + future date, re-paraphrased below** — the description was "change payment
    method to PayPal balance in screen 2, then screen 2 gets pushed again to select a backup, then
    pops back to screen 3." That reads as: debit isn't valid for a future date either, so the flow
    routes it through the PayPal-balance case (which itself isn't valid for a future date), causing a
    second push before landing back on review. Confirm that's right, and if there's a reason debit
    specifically routes through PayPal-balance rather than straight to a bank/backup picker, that
    detail would make your answer land better.
 5. **A specific hardest bug**, if you have one — left as an open prompt in Part 4 rather than
    invented, since the last draft's invented bug was flagged as wrong.
 6. **Launch deadline pressure** — was there a hard date (marketing push, quarter-end), or did this
    ship on a normal cadence? Not mentioned in what you gave me.
 7. **A disagreement/pushback moment** — not part of what you described. If the interviewer asks "tell
    me about a time you disagreed with a teammate," you'll want a real one ready; Part 4 currently
    flags this as missing rather than guessing one.

 Part 5 (FuFight backup story) is untouched from before and still carries its own earlier TODO.

 ## Contents
 - Part 0: Why this story is a strong match for this specific req
 - Part 1: What's actually graded
 - Part 2: The framework
 - Part 3: Your story — PayPal Make-A-Payment
 - Part 4: Anticipated follow-up questions + example answers
 - Part 5: Backup story — FuFight (draft — still unconfirmed, see earlier TODO)
 - Part 6: Slide outline for the Project Deep Dive (confirmed format: 1-2 slides)

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
 > "At PayPal, on the Payments team, I worked on Make-A-Payment — a four-screen flow for paying down a
 > balance: pick an amount, pick a payment method, review before submitting, and a confirmation
 > screen. I built it mainly with my mentor — the two of us were the iOS engineers on the feature —
 > with a product-team point of contact we could go to for UI and wireframe questions."

 **Task** *(~45 seconds)*
 > "Most of the work ran January through March this year, with a few final bug fixes into April. My
 > mentor built the first screen, amount entry, backed by a GraphQL query he owned — I fixed a couple
 > of issues in it, but the three screens after that were mine: choosing a payment method, reviewing
 > the payment, and confirmation, plus the GraphQL mutation that actually submits the payment, which I
 > wired up in the review screen. We used an existing MVI architecture with a TCA-style lifecycle and
 > a specific navigation pattern already established app-wide — I didn't design that, it predated me —
 > but this was one of only two flows in the app at the time with genuinely complex conditional
 > navigation. On top of that, the mobile team was mid-migration from UIKit to SwiftUI, so a lot of
 > patterns were still being figured out in parallel, and we were dealing with flaky tests and CI at
 > the same time."

 **Action** *(~90 seconds)*
 > "The review screen defaults the payment date to today, but has a calendar for picking a later date,
 > and shows a warning sheet if you pick a date past the due date. You can change the payment method
 > two ways — the back button pops you to the method-picker, or a dedicated change button pushes it
 > again on top, showing every option with a checkmark on whatever's currently selected; picking a new
 > one pops you back to review. The hard part was two business rules that don't fit a simple
 > push-once/pop-once model. First: if PayPal balance is the selected method and you pick a future
 > date, balance isn't valid for a future-dated payment, so we immediately push the method-picker again
 > to force a real backup — bank or debit — then pop back to review. Second: if debit is selected and
 > you pick a future date, that routes through the PayPal-balance case — the method gets set to PayPal
 > balance, which itself isn't valid for a future date, so the picker pushes *again* to get a real
 > backup, then pops back. So a single date change could take you two navigation pushes deep before you
 > land back on review, and all of that had to happen correctly on top of a navigation pattern and
 > architecture that already existed — the job wasn't inventing a new pattern, it was encoding these
 > rules into the existing reducer/navigation flow without turning it into a pile of special cases,
 > while the rest of the team was simultaneously still working out SwiftUI conventions and fighting CI
 > flakiness."

 **Result** *(~30 seconds)*
 > "It shipped, and despite the conditional-navigation complexity being the riskiest part of the
 > feature, and despite the team-wide UIKit-to-SwiftUI churn and flaky CI at the time, this was one of
 > the features with very few bugs reported by QA — and zero bugs reported in friends-and-family
 > testing or in production after launch."

 ---

 ## Part 4: Anticipated follow-up questions + example answers

 - **"Walk me through what happens if someone's paying with PayPal balance and picks a date after
   today."**
   > "On the review screen, changing the date to a future date triggers an immediate push of the
   > payment-method screen, because PayPal balance isn't a valid funding source for a future-dated
   > payment. The user picks a real backup — a bank or a debit card — and we pop back to review with
   > that new method reflected, including whatever fee or date-warning logic applies to it."

 - **"What about if they're on debit and pick a future date?"**
   > "That one's less direct — debit also isn't valid for a future date, but instead of going straight
   > to a backup picker, it routes through the PayPal-balance case: the method gets set to PayPal
   > balance first, and since that's also invalid for a future date, the picker pushes again to collect
   > a real backup, then pops back to review. So that specific combination can be two pushes deep off a
   > single date change." *(Note: confirm with yourself the "why route through PayPal balance" reasoning
   > per TODO 4 above — if there's a real business reason, say it here; if it's just an implementation
   > detail of how the state machine was structured, it's fine to describe it that way too.)*

 - **"You said you didn't design the architecture — what did you actually build, then?"**
   > "The architecture and navigation pattern were app-wide conventions that predated me — MVI with a
   > TCA-style lifecycle. What I built was three of the four screens, the GraphQL mutation, and all of
   > the conditional navigation logic for this flow specifically — encoding those funding-source/date
   > business rules into the existing pattern correctly, which is a different skill than inventing a
   > pattern from scratch: you're extending something you don't fully control the shape of."

 - **"How did the UIKit-to-SwiftUI transition affect this work?"**
   > "It meant a lot of the SwiftUI-side conventions the team would eventually standardize on weren't
   > settled yet while I was building this, and we were dealing with flaky tests and CI on top of that.
   > I'd call that out as context for why the low bug count mattered more than it might on a calmer
   > project — the conditions weren't ideal."

 - **"What was the hardest bug you hit building this?"**
   > *(Open — no specific bug confirmed yet. If you have a real one, even roughly remembered, it's a
   > much stronger answer than a generic "we tested carefully." Fill this in and I'll tighten the
   > phrasing.)*

 - **"How do you know it launched cleanly — was there a real number, or a dashboard?"**
   > *(You gave me "very few bugs reported by QA, zero in friends-and-family, zero in production" — if
   > you have an actual QA bug count, or know how bugs were tracked, e.g. Jira ticket count against this
   > feature, that turns this from a qualitative claim into a number, which the framework in Part 1
   > explicitly rewards.)*

 - **"Tell me about a time you disagreed with a teammate on this project."**
   > *(Not covered by what you described — see TODO 7. Worth having something real ready, even minor,
   > since this is a very commonly asked follow-up to a project deep-dive.)*

 ---

 ## Part 5: Backup story — FuFight

 A lighter-weight second story in case the interviewer asks for "another project" or specifically "a
 time you disagreed with someone" and PayPal doesn't fit that angle. Unchanged from the earlier draft
 of this page — still carries its own unconfirmed-specifics caveat from before, separate from the
 Make-A-Payment corrections above.

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
   a smaller-scale version of the same "don't guess, prototype and measure" instinct.
 - **The outcome:** shipped the hybrid model; it held up under casual testing without needing a full
   rollback-correction to actually fire in normal play, which suggested client prediction was accurate
   enough in practice that the server-authority was mostly a safety net rather than something users
   would feel.

 ---

 ## Part 6: Slide outline for the Project Deep Dive (confirmed format: 1-2 slides)

 Michael's exact ask: cover **conception → launch**, **team size**, **scope**, and **impact**, in
 1-2 slides. That's a prompt for *you* to talk over, not a document to be read — keep text to short
 phrases, not full sentences, and let the spoken version (Part 3 above) carry the actual narrative.

 **Slide 1 — "Make-A-Payment: Conditional Payment Navigation"**
 ```
 CONCEPTION
 • Four-screen one-time payment flow: choose amount → choose payment method → review → confirmation

 TEAM & SCOPE
 • Jan-Mar this year, final bug fixes into April
 • iOS: mentor + me. Mentor built screen 1 (amount entry) + its query, I fixed issues in it.
 • I built screens 2-4, the GraphQL mutation, and all conditional navigation logic
 • Product-team POC for UI/wireframe questions
 ```

 **Slide 2 — "The Hard Part, and What Shipped"**
 ```
 THE CHALLENGE
 • Review screen: date picker (default today, calendar, due-date warning) + change-method flow
   (back pops, dedicated button pushes the picker again with a checkmark on current selection)
 • PayPal balance AND debit both become invalid once a future date is picked — each triggers a
   conditional re-push of the method picker to force a valid backup source before popping back
 • Built on an existing MVI + TCA-lifecycle architecture and navigation pattern I didn't design,
   during the team's UIKit → SwiftUI transition, with flaky CI/tests at the time

 LAUNCH & IMPACT
 • Very few bugs reported by QA
 • Zero bugs in friends-and-family testing
 • Zero bugs in production
 ```

 **Building it:**
 - Tool doesn't matter (Keynote/Google Slides/PowerPoint) — what matters is text density: if a
   bullet needs more than ~6 words to make sense standalone, it belongs in what you SAY, not on the
   slide.
 - One simple diagram earns its place if you have 10 minutes to make one: four boxes in a row —
   Amount → Method → Review → Confirmation — with a branching arrow off Review showing the
   conditional push back into Method for the balance/debit + future-date cases. That visually carries
   the entire "why this navigation was hard" argument without you needing to explain it from scratch.
 - Rehearse with the slides up, out loud, timed — the goal is the deck prompts you, you don't read
   it. If you're reading bullets verbatim, cut more text.
 - This maps directly to Part 3's spoken narrative above — once the open TODOs are filled in, both
   stay consistent since they're built from the same facts.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
