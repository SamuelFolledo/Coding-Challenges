//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Fanatics Prep — Day 4: iOS Round Pt 1 — Swift, Architecture & Testability

 Format of the "iOS-style" round is unconfirmed (Day 0, Part 7 TODO) — this page preps the
 **conceptual-discussion/trivia** version, built directly off the JD's explicit skill list: "design
 patterns such as MVVM, coordinators, routers, publishers, and their impact on testability," memory
 management, concurrency. Day 5 preps the more hands-on version (a live-build drill + the KMP-boundary
 story). Prepping both means you're covered whichever way the round actually goes.

 ## Contents
 - Part 1: MVVM with a Coordinator/Router — the pattern the JD names explicitly
 - Part 2: Publishers (Combine) and their testability impact
 - Part 3: Protocol-based DI and mocks — why the JD calls this out separately from testability
 - Part 4: Memory management — retain cycles, `weak` vs. `unowned`
 - Part 5: Concurrency — GCD vs. `async`/`await` vs. actors, and when to reach for each
 - Part 6: Rapid-fire fundamentals likely to come up

 ---

 ## Part 1: MVVM with a Coordinator/Router

 The JD groups "MVVM, coordinators, routers, publishers" as one bullet — a strong signal the team's
 actual architecture is MVVM-plus-Coordinator, not just MVVM alone. The Coordinator's job: own
 navigation so the ViewModel never imports `UIKit`/`SwiftUI` navigation types directly, which is
 exactly what makes a ViewModel unit-testable without a view hierarchy.
*/

protocol Coordinator: AnyObject {
    func start()
    func showCardDetail(cardID: String)
}

final class CreditCardCoordinator: Coordinator {
    private var navigationHandler: (String) -> Void

    init(navigationHandler: @escaping (String) -> Void) {
        self.navigationHandler = navigationHandler
    }

    func start() { /* present the initial screen */ }

    func showCardDetail(cardID: String) {
        navigationHandler(cardID)   // in reality: push/present a detail screen, own the NavigationStack path
    }
}

final class CardListViewModel: ObservableObject {
    @Published private(set) var cards: [String] = []
    // The ViewModel depends on the PROTOCOL, not the concrete Coordinator — this is what makes it
    // testable in isolation: a test can inject a fake that just records "did it ask to navigate,"
    // with zero UIKit/SwiftUI involved.
    private weak var coordinator: Coordinator?

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    func didSelectCard(_ cardID: String) {
        coordinator?.showCardDetail(cardID: cardID)
    }
}

/*:
 **What to say out loud:** "the Coordinator owning navigation is what keeps the ViewModel testable in
 isolation — a test can assert 'selecting a card asked the coordinator to navigate' without spinning up
 any UIKit or SwiftUI view hierarchy at all."

 ---

 ## Part 2: Publishers (Combine) and their testability impact

 The JD's inclusion of "publishers" alongside MVVM/coordinators is specifically about **testing async
 state changes deterministically**. The naive way to test a `@Published` property waits for a real
 async operation; the reliable way collects emitted values into an array and asserts on the sequence.
*/

final class BalanceViewModel: ObservableObject {
    @Published private(set) var balance: Decimal?
    @Published private(set) var isLoading = false

    private let service: () async throws -> Decimal

    init(service: @escaping () async throws -> Decimal) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        balance = try? await service()
    }
}

// A deterministic test shape (not XCTest here, just the pattern to describe verbally):
// collect $balance's emissions into an array via .sink, call await viewModel.load(), then assert the
// array is [nil, someBalance] in that exact order — this is what "testing publishers" concretely means,
// as opposed to sleeping/waiting and hoping the timing lines up.
var recordedBalances: [Decimal?] = []
let sampleVM = BalanceViewModel(service: { 42.50 })
let cancellable = sampleVM.$balance.sink { recordedBalances.append($0) }
Task {
    await sampleVM.load()
    print(recordedBalances)   // [nil, 42.50]
}

/*:
 ---

 ## Part 3: Protocol-based DI and mocks

 The JD lists "dependency injection and writing mocks" as its own bullet, separate from testability in
 general — worth having a crisp, minimal example ready, since it's easy to gesture at vaguely
 ("I use protocols for DI") without a concrete instance.
*/

protocol CardService {
    func fetchCards() async throws -> [String]
}

final class MockCardService: CardService {
    var cardsToReturn: [String] = []
    var errorToThrow: Error?
    private(set) var fetchCallCount = 0   // lets a test assert the service was called exactly once

    func fetchCards() async throws -> [String] {
        fetchCallCount += 1
        if let errorToThrow { throw errorToThrow }
        return cardsToReturn
    }
}

/*:
 **What to say out loud:** "the ViewModel depends on `CardService` the protocol, never the concrete
 network implementation — so a test injects `MockCardService`, controls exactly what it returns or
 throws, and can assert the ViewModel called it the expected number of times. That's the whole DI
 story: constructor injection of a protocol, a hand-written mock, no mocking framework required for
 something this simple."

 ---

 ## Part 4: Memory management — retain cycles, `weak` vs. `unowned`

 A near-guaranteed question ("how would you find/fix a retain cycle") across almost every senior iOS
 loop, and directly relevant to the Coordinator pattern above (note the `weak var coordinator?` — this
 is exactly why).
*/

final class Parent {
    var child: Child?
}

final class Child {
    // `weak`, not `unowned`: the child MIGHT outlive a moment where its parent reference is nil
    // (e.g. the parent is deallocated first in some flow), and `weak` degrades safely to nil in
    // that case — `unowned` would crash on access instead. Reach for `unowned` only when you can
    // GUARANTEE the referenced object always outlives (or exactly matches the lifetime of) self.
    weak var parent: Parent?
}

/*:
 **How to find one in practice, concretely** (this is what separates a real answer from reciting
 `weak`/`strong` definitions): Xcode's **Memory Graph Debugger** (the icon in the debug bar) visually
 flags objects Xcode suspects are leaked with a purple exclamation mark, showing the full reference
 chain — that's usually the fastest path to spotting *which* two objects hold each other. Instruments'
 **Leaks** and **Allocations** templates catch it over time/repeated navigation (e.g. push a screen 10
 times, watch instance count in Allocations climb instead of returning to baseline). The classic root
 cause in this exact codebase's shape: a closure capturing `self` strongly inside a Coordinator/
 ViewModel that the object itself owns a reference back to — fixed with `[weak self]` in the closure.

 ---

 ## Part 5: Concurrency — GCD vs. `async`/`await` vs. actors

 **When to reach for each**, the framing to have ready:

 - **GCD (`DispatchQueue`)** — still shows up for fine-grained queue control (a specific serial queue
   protecting a resource, `DispatchWorkItem` for cancellable work) or in legacy/UIKit-era code you
   didn't write. Not usually the first choice for new code anymore.
 - **`async`/`await`** — the default for new async code: sequential-looking code for what's actually
   asynchronous work, structured cancellation via `Task`, and — directly relevant here — this is
   exactly the shape KMP coroutines get bridged into on the iOS side (Day 0, Part 2's point about
   coroutine-to-`async` bridging at the shared-module boundary).
 - **Actors** — for protecting *mutable shared state* from concurrent access (the Swift compiler
   enforces it — a data race on an actor's properties is a compile error, not a runtime crash you
   hope to catch). `@MainActor` specifically pins UI-touching code to the main thread, which is why
   it shows up on almost every `ObservableObject` in the examples above.
*/

actor BalanceCache {
    private var cachedBalance: Decimal?

    func update(_ balance: Decimal) {
        cachedBalance = balance
    }

    func read() -> Decimal? {
        cachedBalance
    }
}

/*:
 **What to say out loud:** "an actor's whole job is serializing access to its own mutable state — two
 concurrent callers can't race on `cachedBalance` because the actor only executes one method body at a
 time, and the compiler enforces `await` at every call site as a visible marker that a suspension point
 exists there."

 ---

 ## Part 6: Rapid-fire fundamentals likely to come up

 Compressed answers worth having instantly ready, since a conceptual round can move fast:

 - **Struct vs. class** — value vs. reference semantics; struct copies on assignment/pass, class shares
   a reference. Use struct by default (models, view state); class when you need identity/shared
   mutable state or Objective-C interop (relevant here — Obj-C-bridged Kotlin types are classes).
 - **`@State` vs. `@StateObject` vs. `@ObservedObject` vs. `@EnvironmentObject`** — `@State` for
   view-local value-type state; `@StateObject` creates/owns a reference-type model tied to the view's
   lifetime; `@ObservedObject` for a reference-type model owned/passed in from elsewhere (view doesn't
   control its lifecycle); `@EnvironmentObject` for implicit dependency injection down a view tree.
 - **Protocol-oriented programming vs. inheritance** — Swift favors composition via protocols
   (+ protocol extensions for default implementations) over class inheritance hierarchies; avoids the
   fragile-base-class problem and works with both structs and classes, unlike inheritance.
 - **`Codable`** — `Encodable` + `Decodable`; synthesized automatically when every property conforms;
   custom `CodingKeys`/`init(from:)` for API responses whose JSON shape doesn't match the Swift model
   1:1 (a near-guaranteed need if integrating with a Go backend's JSON conventions, e.g. snake_case).

 [↑ Back to Top](#top)
*/

//: [Next](@next)
