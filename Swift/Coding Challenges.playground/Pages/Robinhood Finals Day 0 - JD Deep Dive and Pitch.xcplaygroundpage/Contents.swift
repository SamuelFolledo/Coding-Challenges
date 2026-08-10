//: [Previous](@previous)

import Foundation

/*:
 # Robinhood Finals — Day 0: Job Description Deep Dive & Tailored Pitch

 Role: **iOS Engineer, Retirements and Accounts team** — New York, NY (in-office 3 days/week).
 This page synthesizes the actual JD + what's findable online (job postings, candidate reports) into
 what to emphasize this week. Read this first — it should reshape how you weight Days 1–7.

 ## TODO — confirm or correct before you rely on this

 1. Part 5's pitch guesses **"6 years"** of iOS experience — adjust to your real number.
 2. Part 6's example answers for "Why fintech?" and "tell me about a mistake" lean on the same
    invented PayPal Make-A-Payment specifics as Day 5 — see Day 5's TODO list, since fixing those
    will also fix the examples here.

 ## Contents
 - Part 1: The team & the mission, concretely
 - Part 2: What the JD emphasizes that Carlos's loop summary didn't
 - Part 3: Tech stack reality check — legacy UIKit/VIPER alongside a SwiftUI-forward push
 - Part 4: Comp — the confirmed number is $133k-150k (IC3), JD's posted range doesn't apply
 - Part 5: A tailored 60-second pitch
 - Part 6: Curated "high-likelihood" question list (JD + research, cross-referenced with Days 1-8)

 ---

 ## Part 1: The team & the mission, concretely

 The JD says Robinhood was "tapped as the brokerage and initial trustee for Trump Accounts," working
 with **BNY** to build a **standalone web and app experience**. Publicly confirmed details worth
 knowing cold:

 - Trump Accounts are custodial, IRA-style investment accounts for children under 18, created by the
   Treasury as part of a national child savings initiative.
 - BNY was selected by the Treasury as financial agent for the program; BNY in turn selected
   Robinhood to build and operate the platform.
 - The app is **fully white-labeled** — no Robinhood branding — available on iOS, Android, and web.
   Robinhood also handles education content and customer support for it.
 - It already launched publicly (around July 4 timing per the rollout coverage), so this isn't
   pre-launch speculative work — you'd likely be joining a team maintaining and iterating on a
   **live, high-visibility, government-adjacent product**, not just prototyping.

 **Why this matters for the interview:** this is a strong, specific reason to want *this* team over
 a generic "I like fintech" answer. A guardian/child custodial account also implies onboarding flows
 with real complexity — identity verification for a guardian, linking a minor, multi-step KYC-style
 setup — which lines up directly with the JD's call-out of "customer onboarding experiences."

 ---

 ## Part 2: What the JD emphasizes that Carlos's loop summary didn't

 Carlos's description of the loop (Day 1) is entirely about how you *build* — algorithms, UI state,
 project depth. The JD adds a layer Carlos didn't spell out, and it's fair game anywhere in the loop,
 especially the foundation call:

 - **"Improve testing practices, observability, and release processes"** — have an opinion ready on:
   what you'd unit test vs. UI test vs. leave to manual QA; what you'd want logged/instrumented for a
   critical account-creation flow; whether you've worked with phased rollouts / feature flags.
 - **"Contribute to architecture decisions... scalable mobile architecture patterns across the
   codebase"** — this is bigger than "I used MVVM once." Be ready to talk about modularization
   (splitting a codebase into feature modules) even if you haven't done it yourself — say what you
   understand the tradeoffs to be (build time, team autonomy, harder cross-module refactors).
 - **"Participate in code reviews, documentation, and collaborative engineering processes"** — have a
   real example of giving *and* receiving code review feedback that changed the outcome, not just
   "we do PRs."
 - **Preferred: "financial systems, payments, or account-related platforms"** — your PayPal
   Make-A-Payment/Autopay story (Day 5) is a direct, non-generic match. Say so explicitly in the
   foundation call rather than assuming they'll connect the dots themselves.

 ---

 ## Part 3: Tech stack reality check — legacy UIKit/VIPER alongside a SwiftUI-forward push

 To be precise about what you already expected: the codebase isn't pure SwiftUI, and you weren't
 assuming it was — the working model is legacy UIKit still present, with new view development done
 in SwiftUI "unless impossible." Independent research confirms exactly that kind of mixed state, and
 gives it more texture. Multiple current/recent Robinhood iOS job postings (Payments, Crypto, Credit
 Cards & Banking, and general iOS Engineer reqs) consistently list the stack as:

 **Swift, RxSwift, UIKit, a custom Design System + "Declarative UI Framework," Core Data, Bazel,
 VIPER-esque architecture.**

 A candidate's own Blind post from 2026 prepping for a Robinhood iOS interview independently
 confirms: *"they use UIKit, CoreData, and Viper architecture... all of which I have very little
 experience with."*

 **Read on this:** "Declarative UI Framework" alongside UIKit in the same listings is consistent with
 SwiftUI being adopted for new work while VIPER/RxSwift/UIKit/Core Data remain the substrate for
 existing screens — exactly the mixed state you described. The newer, standalone Trump Accounts app
 is plausibly the freshest SwiftUI surface (it's a from-scratch product), while older verticals carry
 more legacy. Either way, be ready to *reason about* the legacy stack even if your hands-on depth is
 in SwiftUI — it'll likely come up when discussing "how the codebase is structured today":

 - **VIPER, at a glance:** View (dumb UI), Interactor (business logic), Presenter (formats data for
   View, talks to Interactor — closest analog to a ViewModel/Reducer but with stricter
   protocol-enforced boundaries), Entity (plain data models), Router (owns navigation — like a
   Coordinator). You've got real experience in two comparable paradigms — MVVM generally, and a
   TCA/MVI-style pattern (Combine + use cases + GraphQL) at PayPal — so this isn't a knowledge gap to
   paper over, it's a genuine three-way comparison you can speak to. Full pros/cons breakdown and a
   code sketch in Day 8, Part 2.
 - **RxSwift, at a glance:** if you know Combine, you already know this conceptually —
   `Observable` ~ `Publisher`, `PublishSubject` ~ `PassthroughSubject`, `BehaviorSubject` ~
   `CurrentValueSubject`, `DisposeBag` ~ `Set<AnyCancellable>`. Operators (`map`, `flatMap`,
   `debounce`, `combineLatest`) are near-identical in name and semantics across both.
 - **Core Data, at a glance:** `NSManagedObjectContext` for reads/writes, `NSManagedObject`
   subclasses as your model, `NSFetchRequest` to query, a persistent container tying it to disk,
   background contexts for writes off the main thread merged back via notifications.
 - **Bazel:** Google's build system, common at companies with large monorepos for reproducible,
   cacheable builds. You don't need depth — just don't be caught not knowing what it is.

 See Day 8 for a hands-on refresher on all four, including the full MVVM vs. TCA/MVI vs. VIPER
 comparison.

 ---

 ## Part 4: Comp — the confirmed number is $133k-150k (IC3)

 The JD posting lists a Zone 1 (NY) range of $166,000-$195,000 — **that number does not apply here.**
 The recruiter confirmed after the first round that Samuel is being considered at **IC3**, with a
 **$133k-150k** base band. That's the real, settled figure — the JD's posted range is a broader
 spread on the req covering levels above what's actually on the table right now, not a target Samuel
 is tracking toward via this offer.

 What's still relevant from the earlier conversation: a **promotion to a higher level in 6-12 months**
 post-hire was discussed as the path if performance is above the typical IC3 profile — that's a real,
 separate conversation from the posted-range number, and doesn't need reconciling with it.

 - No open question to raise with Carlos here — this is confirmed, not ambiguous.
 - Keep the focus, if leveling comes up again, on what concretely defines "above IC3 profile" and how
   the 6-12 month promotion path actually gets evaluated (see Day 1, Part 2 for that framing).

 ---

 ## Part 5: A tailored 60-second pitch

 Use this shape for "tell me about yourself" / recruiter-screen-style opens, adjusted to how you
 actually talk:

 > "I'm an iOS engineer with 6 years building customer-facing mobile features, most recently at
 > PayPal working on payment flows — including the Make-A-Payment experience, where I designed the
 > navigation for a view that got reused across both one-time payments and Autopay, one of the more
 > complex navigation problems our team had tackled. That work sits right at the intersection of
 > what drew me to this role — I want to keep building in financial systems specifically, on
 > products where getting the details right (state management, precision in the numbers, reliability
 > under real usage) actually matters to people's financial lives. The Trump Accounts work this team
 > is doing — standalone, live, and genuinely new territory for the industry — is exactly that kind
 > of high-stakes, high-craft problem, which is what pulled me toward this specific team rather than
 > a general mobile role."

 Adjust the years/specifics, but keep the throughline: **payments/fintech background → why this
 domain → why this specific team's mission**, not a generic "I love building apps" pitch.

 ---

 ## Part 6: Curated high-likelihood question list

 Cross-referenced from the JD, Carlos's description, and public candidate reports (Glassdoor,
 1Point3Acres, Exponent, Medium interview writeups). Confidence noted where a source independently
 confirmed a question.

 **Technical screen (Day 2/3 cover the coding; these are the framing questions around them):**
 - "Walk me through your approach before you write any code." *(explicitly graded per Carlos)*
 - LRU Cache *(independently confirmed as an actual asked question — see Day 3, Part 1)*
 - A buy/sell-timing profit problem *(confirmed via candidate reports — "given a list of trades,
   return buy/sell pairs and profit" — see Day 8, Part 6 for the canonical version, Best Time to Buy
   and Sell Stock)*
 - Memory management: "how would you find/fix a retain cycle?" *(commonly reported)*
 - Concurrency: GCD vs. `async/await` vs. actors — when would you reach for each?

 **Project call:**
 - Build a small list+detail screen with async data and state management, from a blank project
   (Day 4 drill matches this directly).
 - "How would you structure this to be testable?" — have the protocol-based service pattern from
   Day 4 ready to point to.

 **Foundation call:**
 - "Walk me through a project end to end" → your PayPal story (Day 5).
 - **"Why fintech?"** *(reported as a common behavioral question)*
   > "I got pulled into it specifically after building Make-A-Payment at PayPal — realizing that a
   > subtle state bug in a payment flow doesn't just look bad, it can cost someone real money or
   > block a bill from getting paid on time. That kind of stakes makes the craft matter in a way I
   > find more motivating than a typical consumer feature, where a bug is annoying but rarely costly.
   > The Trump Accounts work here is the same instinct at an even higher bar — it's not just money
   > movement, it's a child's long-term account."
 - **"Tell me about a time you made a mistake."** *(reported as a common behavioral question)*
   > "On the Make-A-Payment work, I shipped a change to funding-source validation that had an edge
   > case — a specific currency mismatch — that never surfaced the right error message, so instead of
   > a clear 'this funding source isn't supported' message, a small number of users hit a spinner that
   > never resolved. We caught it within a day through our crash/error-rate monitoring, not through
   > tests, which was the real problem — our test matrix covered the common funding-source
   > combinations but not that specific mismatch. I shipped a hotfix with a proper fallback error
   > state, and afterward we added a full combinatorial test matrix for funding-source ×
   > payment-type validation instead of spot-checking the common cases, specifically so that class of
   > gap couldn't recur." *(mirrors the invented mistake in Day 5 — see Day 5's TODO list, since
   > correcting that story updates this answer too)*

 [↑ Back to Top](#top)
*/

//: [Next](@next)
