//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 0: JD Deep Dive, Day-to-Day Reality & Tailored Pitch

 Role: **Senior iOS Engineer — Credit Card**, Fanatics App team, New York, NY. Posted base range
 **$152,000–$200,000**. Recruiter is **Korey**. Per the call with him: this is a senior, sole-iOS-owner
 role on a team that otherwise works in **Kotlin Multiplatform (KMP) and Go** — you'd be the point of
 contact for everything iOS-native. Korey also said Fanatics is rolling out **a new interview format as
 of 2026-08-13**, so treat everything below sourced from public candidate reports as background
 texture, not a confirmed rubric — see the confidence tags in Part 7.

 ## CONFIRMED 2026-08-27 — the real loop, superseding the guesses below

 The actual interview loop, learned firsthand rather than inferred: **Round 1 (completed)** was an
 iOS-specific bug hunt in a given starting codebase — some users weren't getting rewards; root cause was
 using a type's `rawValue` as its identifier instead of a real `id` property. **Round 2** is a
 **from-scratch build round where AI tools are explicitly allowed**, framed as mimicking real day-to-day
 work — see Day 2, rebuilt around this. **Round 3** is behavioral. Days 2–3 and 9–10 below were written
 against a guessed "LeetCode round + iOS round" structure before this was known — Day 2 is now corrected;
 Days 3/9/10 still reflect the old guess and are lower-priority to fix given the real structure.

 ## Contents
 - Part 1: The role & team, concretely
 - Part 2: Day-to-day reality as the only iOS engineer on a KMP/Go team
 - Part 3: What the JD emphasizes, mapped to something you can say
 - Part 4: Tech stack reality — KMP, SDUI, and where native Swift is non-negotiable
 - Part 5: Comp — what's actually on the table
 - Part 6: A tailored 60-second pitch
 - Part 7: Curated high-likelihood question list (confidence-tagged)
 - Part 8: The week ahead — what Days 1–10 cover

 ---

 ## Part 1: The role & team, concretely

 Fanatics App is the umbrella brand app — Free to Play games, live events, ecommerce, and new product
 experiences under one roof, explicitly "one team in everything." The **Credit Card** team almost
 certainly owns the **Fanatics American Express® Card** — confirmed publicly (CNBC, Amex/Fanatics press
 releases, 2026-05-20): a co-brand card announced as part of a broader Amex/Fanatics partnership,
 **issued by First Electronic Bank**, running on the **American Express network**, **managed by
 Imprint** (a fintech that runs card programs for brands), launching later in 2026. Cardholders earn
 **FanCash** — Fanatics' own rewards currency, redeemable for merchandise/tickets/collectibles — and
 Amex is separately becoming a Fanatics Membership Rewards transfer partner. The standard feature set
 for a co-brand card app follows from this: application/eligibility flow, card management, statements,
 FanCash rewards tracking, and **Apple/Google Wallet provisioning** (Day 0, Part 4's Wallet story is
 directly this feature, not a hypothetical).

 What makes this different from a typical "iOS engineer" req: you were told directly this is a team
 that otherwise builds in **Kotlin Multiplatform and Go**, and you'd likely be **the only iOS
 specialist**. That's not a footnote — it's the central fact that should shape how you answer almost
 everything in this loop. A team like that isn't hiring someone to write feature code in a vacuum;
 they're hiring someone to be the **iOS platform authority** for a shared/cross-platform codebase that
 doesn't have one today.

 ---

 ## Part 2: Day-to-day reality as the only iOS engineer on a KMP/Go team

 You don't have KMP production experience, and that's fine to say plainly — but you should walk in
 with a concrete, reasoned picture of what the job actually looks like day to day, because "I've never
 used KMP" without that picture reads as a gap. With it, it reads as someone who already understands
 the shape of the work. Here's the reasoning, worth having ready almost verbatim:

 **1. You own the `actual` side of `expect`/`actual`, not the shared business logic.**
 KMP's whole model is: shared Kotlin code declares an `expect` (an interface/function signature with
 no body), and each platform supplies the `actual` implementation. Anything that touches an iOS-only
 framework — PassKit/Wallet, biometrics (Face ID/Touch ID via `LocalAuthentication`), push token
 registration (`UNUserNotificationCenter`), StoreKit, camera/photo picker, keychain — has to be written
 in Swift on the iOS side of that boundary, because Kotlin/Native can't call into Apple's Swift-first
 or Swift-only frameworks directly. That's most of your day-to-day: implementing and maintaining the
 iOS `actual`s the shared Kotlin layer depends on.

 **2. You own the native rendering layer, even under SDUI.**
 The JD calls out server-driven UI (SDUI) + experimentation. Under SDUI, the *screen composition* comes
 from the server (which components, in what order, with what data) — but *rendering* those components
 is still 100% native SwiftUI/UIKit work: building and maintaining the component library that
 interprets the server-sent schema, matching Apple's HIG, VoiceOver/accessibility, animations
 (Core Animation is explicitly in the JD), and performance. SDUI changes *what* decides the layout,
 not *who* builds the rendering engine.

 **3. You consume the shared KMP module; you debug the seams, not the internals.**
 The shared business-logic module gets built as a `.xcframework` and pulled into the iOS app (typically
 via Swift Package Manager — also explicitly in the JD). Day-to-day friction lives at the Kotlin↔Swift
 boundary: Kotlin coroutines surfaced to iOS as completion handlers or (with newer KMP) `async`/`await`
 via native coroutine-to-async bridging, Kotlin nullability mapping to Swift `Optional`, sealed classes
 surfacing as Obj-C-style enums that lose some of Swift's exhaustiveness checking. You don't need to
 write Kotlin fluently to be effective here — you need to be the person who can say "this bridged API
 is awkward/unsafe from the Swift side" and push back on the shared-module's public interface.

 **4. You're the iOS voice in a room that defaults to cross-platform thinking.**
 A Kotlin/Go-fluent team can reflexively reach for "put it in the shared module" even when the right
 answer is "this needs to be iOS-native" — App Store review policy (e.g. external payment links,
 in-app purchase rules), background execution limits, permission/privacy prompt timing (ATT, location,
 notifications), or a platform capability Android doesn't have an equivalent for. Advocating for
 **Add to Apple Wallet being native-only** (see Part 4) is exactly this kind of call — you already
 intuited the correct answer to the recruiter before this prep even started, which is a strong signal
 to lean into, not downplay.

 **5. You likely own iOS CI/CD and release end to end.**
 With no other iOS engineer, Fastlane pipelines, GitHub Actions, Xcodegen (generating the `.xcodeproj`
 from a config so it isn't hand-maintained/merge-conflict-prone — common in teams pulling in an
 external xcframework dependency), App Store submission, and on-call triage for iOS crashes are
 probably yours by default, not shared with a team.

 **6. Expect light Kotlin/Go *reading*, not writing.**
 You'll likely read the shared module's Kotlin to understand what an `expect` requires, and read Go
 service contracts/API docs to integrate against them — but the JD lists Kotlin/Go as "experience with,"
 not "primary language," and the role is explicitly titled iOS. Frame it as: comfortable reading
 C-family/curly-brace syntax, has not shipped Kotlin/Go to production — an honest, low-risk answer.

 **7. Less peer review, more documentation discipline.**
 Without another iOS engineer, there's no one to sanity-check an iOS-specific architecture call before
 it ships — so the habit that matters most here isn't "gets code review approval," it's writing
 decisions down clearly enough that someone unfamiliar with iOS (your KMP/Go teammates, or a future
 second iOS hire) can follow the reasoning later. Worth naming this explicitly as something you already
 do, if true, or intend to be deliberate about.

 **If asked directly ("what do you think this role looks like day to day"), a compressed version:**

 > "My read is I'd own the iOS side of an `expect`/`actual` boundary — writing the native
 > implementations the shared Kotlin business logic depends on for anything iOS-only, like Wallet or
 > biometrics — plus the native SwiftUI/UIKit rendering layer, especially if you're running SDUI, since
 > the server can decide layout but someone still has to build the component library that renders it
 > well on iOS. I'd expect to read Kotlin to understand the shared module's contracts and read Go for
 > backend integration, without necessarily shipping either day to day. And with no other iOS engineer,
 > I'd expect to own iOS CI/CD, release, and on-call outright, and to be more deliberate about writing
 > architecture decisions down clearly, since there's no other iOS person to sanity-check a call before
 > it ships."

 ---

 ## Part 3: What the JD emphasizes, mapped to something you can say

 - **"Experience with Kotlin Multiplatform" / "Kotlin and/or Go"** — don't overclaim. The honest,
   confident answer: "I haven't shipped KMP, but I understand the `expect`/`actual` model and where the
   iOS/Kotlin boundary typically causes friction" (Part 2). Then pivot to what you *do* bring that a
   pure-KMP hire wouldn't: deep native iOS judgment.
 - **"SDUI... especially combined with experimentation (e.g., A/B testing)"** — if you haven't built
   SDUI before, you likely have adjacent experience worth naming: any config-driven UI, feature-flagged
   screens, or remote-config-controlled experiments from PayPal. Say so explicitly rather than treating
   "SDUI" as unfamiliar territory (Day 5 covers the mental model in depth).
 - **"Design patterns such as MVVM, coordinators, routers, publishers, and their impact on
   testability"** — this is table stakes and matches your background directly; Day 4 drills it.
 - **"CI/CD... Fastlane, GitHub Actions, Swift Package Manager, Xcodegen"** — have real, specific
   examples ready, not just "yes I've used CI." Day 6 covers this.
 - **"Onboard and mentor junior engineers and interns"** — worth a real story even though you'll be the
   *only* iOS engineer initially; mentoring here might mean onboarding a future second iOS hire, or
   mentoring cross-functionally (helping a KMP/Android engineer reason about an iOS constraint).
 - **"Open to occasional travel to Fanatics offices"** — logistics-only, but confirm you're fine with
   it before the loop, not mid-interview.

 ---

 ## Part 4: Tech stack reality — KMP, SDUI, and where native Swift is non-negotiable

 Independent research (job postings across multiple Fanatics mobile teams, not just this one) confirms
 the stack pattern you were told about: **Fanatics' mobile strategy centers on Kotlin Multiplatform for
 shared business logic, with native rendering — SwiftUI on iOS, Jetpack Compose on Android** — which is
 SDUI-adjacent by design (shared logic decides *what*, native code decides *how it's drawn*). Some
 Fanatics teams also use **Compose Multiplatform** (shared *UI* code, not just logic) — worth asking
 early in the loop whether the Credit Card team shares business logic only, or UI too, since that
 changes how much of "your" screen code is actually shared.

 **The precise, defensible reason "Add to Apple Wallet" belongs entirely in the iOS app, correctly
 stated** (worth getting exactly right — a KMP-savvy interviewer could push back on an imprecise
 version of this claim, since `PassKit` predates Swift and has Objective-C headers, so Kotlin/Native's
 cinterop *can* technically reach it). The stronger argument isn't "Kotlin literally can't call this" —
 it's that routing it through the shared module has **zero reuse value and real cost**: (1) Android has
 no equivalent — Google Wallet is a completely different SDK with a different integration model, so
 there's no shared business logic to hoist into `commonMain`; a `WalletProvisioning` `expect` would have
 exactly one real `actual` and a stub on the other platform, which isn't what shared code is for. (2)
 It's tightly coupled to native UI presentation (`PKAddPaymentPassViewController`) and app-target
 entitlements, which live in the iOS app target regardless of which language wrote them. (3) Writing it
 in Swift gets full modern-language ergonomics (`async`/`await`, SwiftUI's `UIViewControllerRepresentable`
 wrapping) instead of routing through Kotlin/Native's cinterop for no benefit. **The sharper, truly
 "technically impossible" example**, if you want one in reserve: **SwiftUI itself** is unreachable from
 Kotlin/Native — its `View` protocol depends on associated types, opaque types (`some View`), property
 wrappers, and result builders, none of which have an Objective-C bridge, unlike the older Obj-C-based
 frameworks (PassKit, UIKit, Foundation). So the fully accurate framing: cross-platform reach is a
 spectrum — Obj-C-era frameworks are technically reachable from Kotlin but rarely worth routing through
 shared code, while modern Swift-only APIs (SwiftUI chief among them) are genuinely, technically
 native-only.

 A minimal sketch of the shape this takes in code. Note: a real KMP `actual` implementation is written
 in *Kotlin* (in the `iosMain` source set), not Swift — Day 8 covers that precisely. What's sketched
 here is the more likely real architecture per the argument above: Wallet provisioning skips the shared
 module's `expect`/`actual` mechanism entirely and lives as an ordinary Swift protocol/type wholly
 inside the iOS app target, since there's no `commonMain` logic worth sharing for it:
*/

protocol WalletProvisioning {
    func canAddCardToWallet() -> Bool
    func presentAddToWallet(cardholderName: String, primaryAccountSuffix: String) async throws
}

// Lives entirely in the iOS app target — never touches the shared KMP module at all, since Android's
// Wallet equivalent (Google Wallet) is a different enough SDK that there's no real logic to share.
final class PassKitWalletProvisioning: WalletProvisioning {
    func canAddCardToWallet() -> Bool {
        // In reality: PKAddPaymentPassViewModel.canAddPaymentPass()
        true
    }

    func presentAddToWallet(cardholderName: String, primaryAccountSuffix: String) async throws {
        // In reality: construct a PKAddPaymentPassRequestConfiguration, present
        // PKAddPaymentPassViewController, and forward the resulting certificates/nonce to your
        // card-issuer backend (likely a Go service) to complete provisioning server-side.
    }
}

/*:
 **What to say if this comes up live:** "I'd actually keep Wallet provisioning entirely inside the iOS
 app target, not behind an `expect`/`actual` boundary at all — there's no real logic to share with
 Android's Google Wallet integration, so routing it through the shared module would just add interop
 ceremony for zero reuse benefit. `expect`/`actual` earns its keep when the *behavior* is conceptually
 shared and only the *implementation* differs per platform — Wallet isn't that."

 ---

 ## Part 5: Comp — what's actually on the table

 Unlike a prior loop where a JD's posted range didn't apply to the confirmed level, here the **posted
 range ($152k–$200k base) is the only number in hand** — no recruiter-confirmed leveling/comp
 conversation has happened yet in what's in my context. Broader Fanatics Senior Software Engineer data
 (levels.fyi, not iOS-specific, likely web/backend-weighted) shows total comp averaging roughly $214k
 (~$190k base + stock + bonus) — useful only as a rough market sanity check, not a number to anchor on,
 since it isn't iOS- or team-specific.

 **How to handle it if it comes up on the 30-min call:** ask, don't assume — "What level is this req
 mapped to, and does the $152k–$200k reflect base only or total comp?" (the JD explicitly says base
 only). Given the role is titled *Senior* and described as sole-iOS-owner/point-of-contact, there's a
 reasonable case for anchoring toward the top of that band rather than the middle — a sole-owner role
 typically carries more scope than a "senior on a team of five iOS engineers" req at the same title.

 ---

 ## Part 6: A tailored 60-second pitch

 **Confirmed PayPal specifics (2026-08-20):** one year on **PayPal's Credit Card mobile team**, working
 across app flows spanning **all of PayPal's credit card products** (not one narrow flow — the whole
 product surface). Spent the first few months on the existing **UIKit** app, then helped **rewrite the
 entire app from UIKit to SwiftUI**, alongside the rest of a **~24–30 person team**. This is a
 genuinely strong, specific asset for this loop — a full-app UIKit→SwiftUI migration at that scale is
 exactly the kind of "modern Swift" experience the JD calls out, and it's a natural bridge to a KMP
 migration/adoption story: both are "the whole team moves the app to a new architecture together"
 problems, just with a different target.

 > "I'm an iOS engineer with 6 years building customer-facing mobile features. Most recently, I spent a
 > year on PayPal's Credit Card mobile team, working across flows spanning all of PayPal's credit card
 > products — including Make-A-Payment and its navigation logic. I joined on the existing UIKit app,
 > then helped rewrite the entire thing to SwiftUI alongside the rest of a 24-to-30-person team, so I've
 > lived through a full-app architecture migration at scale, not just a greenfield SwiftUI project. What
 > draws me to this role specifically is the shape of it: you're looking for someone to be the iOS point
 > of contact on a team that's built primarily in Kotlin Multiplatform and Go, and that's exactly the
 > kind of ownership I want next — not just writing iOS features, but being the platform authority who
 > knows where native Swift has to take over from shared logic. I actually flagged that instinct to
 > Korey before we'd even talked tech in depth — Add to Apple Wallet has to be native, since PassKit has
 > no cross-platform surface — and that's the kind of judgment I'd bring day to day here. Add in that
 > it's a credit-card product, directly the domain I already work in, and this is a very specific, not
 > generic, reason to want this team."

 Adjust specifics to taste, but keep the throughline: **credit-card-domain match → a real large-scale
 migration story (UIKit→SwiftUI) as proof you can operate through team-wide architecture change →
 sole-iOS-owner ownership as a feature, not a gap → the Apple Wallet insight as proof you already think
 this way.**

 **If asked "tell me about a complex technical project" specifically** (a near-certain question in the
 iOS round or foundation call), the UIKit→SwiftUI rewrite is likely your strongest answer, stronger than
 Make-A-Payment alone — it's team-scale, architecture-level, and directly on-stack for this JD. Worth
 having ready: what made the migration hard (state management differences, navigation paradigm changes,
 how you sequenced which screens moved first, how 24–30 engineers avoided stepping on each other), and
 what you'd tell Fanatics if they ever needed to fold the KMP shared module into more of the UI layer —
 you'd recognize the shape of that problem from having lived through an analogous one.

 ---

 ## Part 7: Curated high-likelihood question list (confidence-tagged)

 Public Fanatics interview reports are thin, mostly for generic (non-iOS) SWE roles, and possibly
 stale against the recruiter's stated **new-as-of-2026-08-13 process** — so nothing here is treated as
 confirmed the way Robinhood's LRU Cache question was. Tags: **[recruiter-confirmed]** = told to you
 directly, **[public-reported, low-confidence]** = found in candidate reports but for a different
 role/possibly outdated process, **[inferred from JD]** = not reported anywhere, reasoned from the
 skill list.

 - **[recruiter-confirmed]** A 30-minute foundation/background call — see Day 1.
 - **[recruiter-confirmed]** A LeetCode-style coding round — see Days 2–3.
 - **[recruiter-confirmed]** An "iOS-style" round — exact format unconfirmed; Days 4–5 prep both a
   trivia/design-discussion version and a live-coding version so you're covered either way.
 - **[public-reported, low-confidence, likely a different/older process]** General SWE reports describe
   a 1-hour remote coding round at *easy-to-medium* difficulty (one candidate reported a BFS,
   word-ladder-style graph problem), two behavioral rounds with overlapping questions
   (strengths/weaknesses/"tell me about a time"), and an on-site system design round. Useful as a
   rough calibration of *difficulty*, not as a guarantee of *format*, for a senior iOS-specific loop.
 - **[inferred from JD]** "Why Fanatics / why this team?" — your credit-card-domain match and the
   sole-iOS-owner framing (Part 6) answer this directly and specifically.
 - **[inferred from JD]** "Tell me about a time you influenced a technical decision without full
   authority" — plausible given "help your team define... best practices" and the sole-owner framing;
   have a real example ready (Day 1).
 - **[inferred from JD]** "How would you approach a codebase where you're the only iOS person and
   everyone else works in Kotlin/Go?" — Part 2 is your answer, verbatim if needed.

 ---

 ## Part 8: The week ahead — what Days 1–10 cover

 ```
 Day  | Focus
 -----+---------------------------------------------------------------------------
 1    | The 30-min foundation call — full guide: opening, 10 Q&As w/ follow-ups, closing
 2    | Coding round Pt 1 — arrays/strings/hashmaps (calibrated to "not medium/hard")
 3    | Coding round Pt 2 — graphs/BFS (word-ladder-style) + trees, senior-level extensions
 4    | iOS-style round Pt 1 — Swift/SwiftUI/UIKit, MVVM/coordinators/routers/Combine,
      | testability, DI & mocks, memory management, concurrency
 5    | iOS-style round Pt 2 — SDUI + A/B testing mental model, a live-build drill,
      | Core Animation/profiling & debugging, the KMP-boundary story in depth
 6    | CI/CD & engineering practice — Fastlane, GitHub Actions, SPM, Xcodegen, on-call,
      | code review & mentoring as the sole iOS owner
 7    | Questions to ask, comp/leveling framing, final countdown checklist
 8    | KMP deep dive for an iOS-only engineer — real code shape, ticket workflow, pros/
      | cons/limitations
 9    | Full guide for the LeetCode-style round — opening, 10 Q&As w/ follow-ups, closing
 10   | Full guide for the iOS-style round — opening, 10 Q&As w/ follow-ups, closing
 ```

 [↑ Back to Top](#top)
*/

//: [Next](@next)
