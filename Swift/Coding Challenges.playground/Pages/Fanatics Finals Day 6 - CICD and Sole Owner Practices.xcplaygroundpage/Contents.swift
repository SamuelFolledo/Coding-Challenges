//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 6: CI/CD & Engineering Practice as the Sole iOS Owner

 The JD explicitly lists **Fastlane, GitHub Actions, Swift Package Manager, Xcodegen**, plus "on-call
 rotation," "code reviews," and "onboard and mentor junior engineers" — all worth concrete answers, and
 all take on a different shape when you're the *only* iOS engineer (Day 0, Part 2). This page is about
 having real, specific stories, not just "yes I've used CI/CD."

 ## Contents
 - Part 1: Fastlane — what it actually does and a lane worth describing
 - Part 2: GitHub Actions — a realistic iOS CI pipeline shape
 - Part 3: Swift Package Manager — as a dependency manager AND as how the KMP xcframework likely arrives
 - Part 4: Xcodegen — why it matters specifically for a team pulling in a generated shared module
 - Part 5: On-call, code review, and mentoring — reframed for "team of one"

 ---

 ## Part 1: Fastlane — what it actually does and a lane worth describing

 Fastlane is a Ruby-based automation tool for the parts of iOS release that are otherwise manual and
 error-prone: bumping build numbers, code signing, running tests, building/archiving, and uploading to
 TestFlight/App Store Connect. A `Fastfile` defines **lanes** (named, composable automation steps).

 A realistic lane to describe if asked "walk me through a Fastlane setup you've used":

 ```ruby
 lane :beta do
   increment_build_number(xcodeproj: "App.xcodeproj")
   run_tests(scheme: "App")
   build_app(scheme: "App", export_method: "app-store")
   upload_to_testflight
   slack(message: "New beta build uploaded 🚀")
 end
 ```

 **What to say out loud:** "the value isn't any one step — it's that `fastlane beta` is the same
 command whether I run it locally or a GitHub Actions workflow runs it on every merge to `develop`,
 which removes 'works on my machine' as a category of release problem entirely."

 ---

 ## Part 2: GitHub Actions — a realistic iOS CI pipeline shape

 The core shape worth having ready, regardless of exact YAML syntax recall:

 ```
 Trigger              | Job
 ----------------------+--------------------------------------------------------------
 Every PR              | Lint (SwiftLint) + unit tests + UI tests on a simulator matrix
 Merge to develop/main  | fastlane beta — build, sign, upload to TestFlight
 Tag push (release)     | fastlane release — App Store Connect submission
 ```

 A specific, non-generic thing worth naming if this comes up: **caching**. iOS CI is slow mostly because
 of dependency resolution (SPM) and build time — `actions/cache` keyed on `Package.resolved`'s hash (for
 SPM dependencies) and DerivedData/build artifacts is the concrete lever that turns a 20-minute CI run
 into a 5-minute one. Vague "I set up CI" answers rarely mention this; naming it signals real hands-on
 experience with *slow* CI, not just working CI.

 A second thing specific to this role: with a KMP shared module in the dependency graph, CI has to
 either **build the Kotlin module fresh** (slower, always current) or **consume a published/cached
 `.xcframework` artifact** (faster, but needs its own versioning/publish pipeline on the Kotlin side) —
 worth asking about directly in the loop (Day 1, Part 3 already has this as a suggested question), since
 the answer materially changes what iOS CI even looks like here.

 ---

 ## Part 3: Swift Package Manager — dependency manager AND likely the KMP delivery mechanism

 Two distinct things worth being able to speak to:

 - **As a dependency manager**: `Package.swift` declares dependencies + version requirements;
   `Package.resolved` pins exact resolved versions (the file CI should cache/lint against, so a build
   is reproducible rather than silently picking up a new transitive version).
 - **As the likely delivery mechanism for the shared KMP module** (Day 0, Part 4): Kotlin/Native
   compiles the shared module to an `.xcframework`, which is then most commonly distributed to the iOS
   app either as a **local binary target** in `Package.swift` pointing at a built `.xcframework`, or via
   a private SPM registry hosting versioned builds. Worth asking directly: is the Kotlin module rebuilt
   locally as part of the iOS build (slower, simpler), or consumed as a versioned prebuilt binary
   (faster, requires the Kotlin side to publish releases on its own cadence)? That answer shapes how
   tightly iOS release timing is coupled to the shared-module team's release cadence.

 ---

 ## Part 4: Xcodegen — why it matters specifically here

 Xcodegen generates `project.yml` → an `.xcodeproj`/`.xcworkspace`, instead of hand-maintaining the
 Xcode project file directly. The generic reason teams adopt it: `.xcodeproj` is a giant XML-ish blob
 that produces brutal merge conflicts when two engineers add files in the same PR window; a YAML
 config diffs cleanly instead.

 **The reason it likely matters *especially* here**: a project consuming a KMP-built xcframework
 dependency, plus SPM packages, plus (per the JD) SDUI-driven modular screens, has more moving parts in
 its project configuration than a typical single-team iOS app — a config-as-code approach keeps that
 reproducible across machines/CI without a human ever hand-editing project settings. Worth naming this
 connection explicitly if asked "why Xcodegen" rather than giving the generic merge-conflict answer
 alone — it shows you're reasoning about *this* codebase's specific shape, not reciting boilerplate.

 ---

 ## Part 5: On-call, code review, and mentoring — reframed for "team of one"

 These three JD bullets assume a normal multi-iOS-engineer team by default — worth having an answer
 that acknowledges the reframing rather than reciting a generic answer that doesn't fit the actual role.

 **On-call**: with no other iOS engineer, "on-call" likely means *you* are the escalation point for
 iOS crashes/issues, full stop, not part of a rotation that spreads the load. Worth asking directly what
 backup looks like — is there an SRE/on-call process that pages you specifically for iOS issues, and is
 there any secondary coverage (e.g. a KMP engineer who can at least triage a shared-module-caused issue)
 during vacation/sick time? A fair, non-alarmist question, not a red flag to raise defensively.

 **Code review**: without another iOS engineer, who reviews your Swift-specific PRs? Realistic
 answers: a KMP/Android engineer reviews for logic/structure even without deep SwiftUI fluency, a
 lead/manager reviews for process, or — a fair thing to ask about directly — whether there's a plan to
 loop in cross-company iOS reviewers (another Fanatics iOS team, e.g. Growth or the broader app) for
 anything architecturally significant. Having a POSITION on this (not just a question) is a stronger
 answer: e.g. "I'd want to write a short design doc before any nontrivial iOS architecture change,
 specifically because there's no second iOS reviewer to sanity-check it in a normal PR review — that's
 the discipline that substitutes for a missing peer."

 **Mentoring**: reframe from "mentor other iOS engineers" (there likely aren't any yet) to two realistic
 versions: (1) mentoring cross-functionally — helping a KMP/Android/Go engineer understand an iOS
 platform constraint they're not familiar with, which is a real and valuable form of mentoring in this
 specific team shape; (2) being the onboarding path for a *future* second iOS hire, if/when the team
 grows — worth stating you'd think about documentation and architecture decisions with that future hire
 in mind from day one, not just as an afterthought once they're hired.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
