//: [Previous](@previous)

import Foundation
import Combine

/*:
 # Robinhood Finals — Day 8: VIPER, RxSwift & Fintech-Flavored Coding Patterns

 Added after researching the actual Robinhood iOS stack (see Day 0, Part 3) — several current job
 postings and an independent candidate report describe **UIKit + RxSwift + Core Data + Bazel +
 VIPER-esque architecture** as the legacy substrate, alongside newer SwiftUI adoption for new work.
 This page is a fluency refresher, not a from-scratch mastery attempt — the goal is to not freeze if
 the legacy stack comes up, and to have the fintech-specific coding patterns (money math, idempotency,
 pagination) ready since they're directly implied by an account/payments-focused role.

 ## TODO — confirm or correct before you rely on this

 Part 2's "how to answer" example reuses the same invented PayPal Make-A-Payment specifics as Day 5
 (the `PaymentFlowContext` protocol, the use-case/GraphQL details). Fix Day 5's TODO list first — this
 page's example will need the same corrections applied to stay consistent.

 ## Contents
 - Part 1: VIPER, at a glance
 - Part 2: MVVM vs. TCA/MVI (PayPal) vs. VIPER (Robinhood) — pros, cons, and how to talk about it
 - Part 3: RxSwift → Combine mental mapping
 - Part 4: Core Data refresher
 - Part 5: Money math — Decimal vs. Double
 - Part 6: Best Time to Buy and Sell Stock (confirmed real question — Day 0, Part 6)
 - Part 7: Idempotency pattern for account/payment requests
 - Part 8: Pagination pattern for a transaction/account history list

 ---

 ## Part 1: VIPER, at a glance

 ```
 Component   | Responsibility                          | Closest SwiftUI/MVVM analog
 ------------+------------------------------------------+------------------------------
 View        | Renders UI, forwards user actions        | View
 Interactor  | Business logic, talks to services/models  | (part of) ViewModel
 Presenter   | Formats data for View, mediates Interactor | ViewModel
 Entity      | Plain data model                          | Model / Codable struct
 Router      | Owns navigation between screens            | Coordinator / NavigationStack
 ```

 The core discipline VIPER enforces that MVVM doesn't strictly require: every dependency is a
 protocol, so the View never talks to the Interactor directly, and the Presenter never imports
 UIKit/SwiftUI types. This is a minimal sketch — not something to reproduce verbatim, just enough
 to speak to the shape if it comes up.
*/

protocol PaymentView: AnyObject {
    func display(amount: String)
    func displayError(_ message: String)
}

protocol PaymentInteractor {
    func submitPayment(amount: Decimal) async throws
}

protocol PaymentRouter {
    func routeToConfirmation()
}

final class PaymentPresenter {
    // `weak`, because the View side of this relationship typically holds a strong reference back
    // to its Presenter (e.g. a view controller owning the Presenter that drives it). Without
    // `weak` here, that would be a retain cycle — neither side could ever deallocate.
    weak var view: PaymentView?
    private let interactor: PaymentInteractor
    private let router: PaymentRouter

    init(interactor: PaymentInteractor, router: PaymentRouter) {
        self.interactor = interactor
        self.router = router
    }

    func didTapSubmit(amount: Decimal) {
        // `didTapSubmit` is called synchronously from a UI action (a button tap), but
        // `submitPayment` is async — the Task{} is the bridge from that synchronous entry point
        // into async/await, since the method signature itself can't be `async` (nothing awaits it).
        Task {
            do {
                try await interactor.submitPayment(amount: amount)
                router.routeToConfirmation()
            } catch {
                view?.displayError(error.localizedDescription)
            }
        }
    }
}

/*:
 If asked "have you used VIPER," the honest, strong answer: *"Not directly — I've worked in MVVM and
 in a TCA/MVI-style pattern at PayPal — but the separation maps closely: Presenter is doing what a
 ViewModel/Reducer does, Router is doing what a Coordinator does. The bigger adjustment would be the
 protocol boilerplate, not the underlying ideas."* See Part 2 for the full comparison across all
 three.

 ---

 ## Part 2: MVVM vs. TCA/MVI (PayPal) vs. VIPER (Robinhood) — pros, cons, how to talk about it

 You've got real experience in two of these three (MVVM generally, TCA/MVI-style at PayPal with
 Combine + a use-case layer + GraphQL) interviewing for a role that likely also touches the third
 (VIPER). That's a strong position — you can compare paradigms from lived experience, not just
 reading about them. Here's the shape of that comparison.

 ```
 Dimension         | MVVM                       | TCA / MVI (PayPal-style)              | VIPER
 -------------------+-----------------------------+------------------------------------------+---------------------------------------
 Data flow          | View <-> ViewModel binding, | Unidirectional: Action -> Reducer ->    | View -> Presenter -> Interactor;
                    | often two-way                | new State -> View, one-way, single       | Router owns nav; more hub-and-spoke
                    |                               | source of truth                          |
 State ownership    | ViewModel, per screen         | Reducer/State, often feature- or app-wide| Presenter (formats), Interactor (logic)
 Boilerplate        | Low                           | Medium-high (Action/Reducer/Effect types)| High (5 protocol-bound types per screen)
 Testability        | Good, if ViewModel stays thin | Excellent — reducers are pure functions  | Excellent — every dependency is a protocol
 Navigation         | Ad hoc / NavigationStack      | Usually a dedicated nav reducer/coord.   | Explicit — Router owns it
 Native SwiftUI fit | Excellent (@Published/@State) | Good, via an adapter (e.g. a ViewStore)  | Weak — built for UIKit-era screens
 Best fit           | Small-medium, fast-iterating  | Complex state, many derived values, need | Large legacy codebases, many engineers,
                    | screens, SwiftUI-native        | for traceable state changes, GraphQL cache| need enforced consistency across teams
 ```

 **MVVM — pros/cons**
 - *Pro:* minimal ceremony, plays natively with SwiftUI's `@Published`/`@StateObject`, low onboarding
   cost since almost everyone already knows it.
 - *Con:* no structural enforcement of one-way data flow — a ViewModel can be mutated from anywhere,
   so as a screen grows it gets harder to trace *what* triggered a given state change. Easy to let it
   become a "God object" if you don't split out services/use cases deliberately.

 **TCA / MVI (PayPal-style: Combine + use cases + GraphQL) — pros/cons**
 - *Pro:* every state change traces back to a specific dispatched Action — excellent for debugging a
   live payments flow where you need to reconstruct exactly how a user ended up in a given state.
   Reducers are pure functions, so they're trivially unit-testable without mocking a ViewModel's
   internals. Composability: nested reducers scale naturally for a multi-step flow (e.g. a checkout
   or account-setup flow with several sub-screens). Pairs well with GraphQL's normalized-cache model —
   a use-case layer sits between the reducer and the GraphQL client, keeping network effects out of
   the pure reducer.
 - *Con:* meaningfully more boilerplate (Action enums, Reducer functions, Effect/Environment types per
   feature); steeper onboarding for engineers unfamiliar with Redux/Elm-style unidirectional patterns;
   overkill for a simple, mostly-static screen; shared/global state can become a re-render performance
   bottleneck if not scoped carefully per feature.

 **VIPER (Robinhood-relevant) — pros/cons**
 - *Pro:* every cross-layer dependency is a protocol, so any layer (View, Interactor, Presenter) is
   independently mockable/testable. Forces consistency on a large team/codebase — a new engineer
   joining a VIPER feature knows exactly where new code goes. Router centralizes navigation ownership,
   similar benefit to a Coordinator.
 - *Con:* high file count per screen (5 types minimum) slows down simple CRUD-style screens. No
   built-in reactive binding — the Presenter must manually push formatted data to the View (unlike
   MVVM/TCA's automatic re-render on state change), which is a real ergonomic step backward if you're
   used to Combine. Common failure mode: "Massive Presenter" replacing "Massive View Controller" if
   discipline lapses — the strict separation is only as good as the team's adherence to it. Weaker
   native fit with SwiftUI, which was designed around declarative state-driven rendering, not
   protocol-mediated `display(...)` calls.

 **A compact TCA/MVI-style sketch** (State/Action/Reducer/Store, Combine-driven) — this is the shape
 worth having ready to sketch on a whiteboard or in CoderPad if asked to compare to VIPER live:
*/

struct PaymentFeatureState {
    var amount: Decimal = 0
    var isSubmitting = false
    var errorMessage: String?
}

enum PaymentFeatureAction {
    case amountChanged(Decimal)
    case submitTapped
    case submissionSucceeded
    case submissionFailed(String)
}

protocol PaymentUseCase {                          // the "use case" boundary to the GraphQL layer
    func submit(amount: Decimal) async throws
}

@MainActor
final class PaymentFeatureStore: ObservableObject {
    // `private(set)` is what makes this a reducer rather than just a ViewModel with a different
    // name — nothing outside this type can mutate `state` directly, so `send(_:)` is structurally
    // the ONLY entry point for a state change. That's the enforcement mechanism behind "every
    // state change traces back to an Action" — it's not a convention here, the compiler backs it.
    @Published private(set) var state = PaymentFeatureState()
    private let useCase: PaymentUseCase

    init(useCase: PaymentUseCase) {
        self.useCase = useCase
    }

    // The reducer: every state transition happens here, and only here — traceable by Action.
    func send(_ action: PaymentFeatureAction) {
        // No `default:` case — Swift requires this switch to be exhaustive over every case of
        // PaymentFeatureAction. Add a new action without handling it here and this won't compile,
        // which is a much stronger guarantee than "we agreed to update the reducer" convention.
        switch action {
        case .amountChanged(let amount):
            state.amount = amount
        case .submitTapped:
            state.isSubmitting = true
            state.errorMessage = nil
            // The reducer itself stays synchronous and side-effect-free — this Task is the
            // "Effect" in TCA terms: async work is kicked off here, but its result comes back
            // as a NEW Action (`.submissionSucceeded`/`.submissionFailed` below), not by awaiting
            // inline. That's what keeps `send` itself trivially testable as a pure function.
            Task { await submit() }
        case .submissionSucceeded:
            state.isSubmitting = false
        case .submissionFailed(let message):
            state.isSubmitting = false
            state.errorMessage = message
        }
    }

    private func submit() async {
        do {
            try await useCase.submit(amount: state.amount)
            // Routes back through `send`, not a direct `state.isSubmitting = false` — even async
            // results only ever touch state via an Action, so the trace-every-change-to-an-Action
            // property holds for effects too, not just synchronous taps.
            send(.submissionSucceeded)
        } catch {
            send(.submissionFailed(error.localizedDescription))
        }
    }
}

/*:
 **How to answer if asked directly** (project or foundation call):

 > "At PayPal we used a TCA/MVI-style pattern — Combine-driven state, a use-case layer as the boundary
 > to our GraphQL client — for flows like Make-A-Payment specifically because the screen had a lot of
 > derived state across flow variants, and we wanted every state transition traceable for debugging a
 > live payments flow. MVVM would've been simpler for a one-off screen, but the unidirectional
 > guarantee mattered more given how many edge cases a payment flow has. I understand Robinhood leans
 > on VIPER for a lot of the existing codebase — I haven't worked in it directly, but the underlying
 > instinct is the same: strict separation of concerns, just enforced structurally through protocols
 > rather than through team convention."

 This answer shows real, lived comparison rather than reciting a table — and doesn't overclaim VIPER
 experience you don't have.

 ---

 ## Part 3: RxSwift → Combine mental mapping

 ```
 RxSwift              | Combine                  | Meaning
 ----------------------+---------------------------+----------------------------------------
 Observable<T>         | Publisher (any type)      | A stream of values over time
 Observer               | Subscriber                | Something that receives values
 PublishSubject<T>     | PassthroughSubject<T,Err> | Emits values as they happen, no replay
 BehaviorSubject<T>    | CurrentValueSubject<T,Err>| Holds and emits a current value
 DisposeBag             | Set<AnyCancellable>       | Cancels subscriptions on deinit
 .map / .flatMap        | .map / .flatMap           | Same semantics, same names
 .debounce               | .debounce                 | Same semantics, same names
 .combineLatest          | .combineLatest            | Same semantics, same names
 ```

 A Combine snippet, annotated with the RxSwift equivalent for each piece, since that's the direction
 you'd be translating *from* your own experience:
*/

final class SearchBox {
    // Combine: CurrentValueSubject   |  RxSwift: BehaviorSubject
    let queryPublisher = CurrentValueSubject<String, Never>("")
    private var cancellables = Set<AnyCancellable>()   // RxSwift: DisposeBag

    func observe() {
        queryPublisher
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)   // same in RxSwift
            // Placed AFTER debounce, not before: without it, typing "AAPL" then backspacing to
            // "AAP" then retyping "AAPL" would re-fire a search for a query already searched,
            // since debounce only suppresses rapid-fire emissions, not repeated end values.
            .removeDuplicates()
            .sink { query in
                print("searching for: \(query)")
            }
            .store(in: &cancellables)   // RxSwift: .disposed(by: disposeBag)
    }
}

/*:
 ---

 ## Part 4: Core Data refresher

 ```
 Concept                 | What it's for
 --------------------------+-------------------------------------------------------------
 NSManagedObjectContext    | Your "scratchpad" for reading/writing objects; main-thread
                           | context for UI reads, a background context for writes
 NSManagedObject           | Your model class, generated from a .xcdatamodeld schema
 NSFetchRequest            | A query against the store, with predicates/sort descriptors
 NSPersistentContainer     | Ties the model + store file + contexts together
 Merging changes           | A background save posts a notification; the main context
                           | merges it (or you use `automaticallyMergesChangesFromParent`)
 ```

 The interview-relevant framing: Core Data is a good fit for **locally cached, queryable, relational
 data that needs to survive app relaunch** (e.g. a transaction/account history cache) — versus
 `UserDefaults` (small flags/settings) or a plain `Codable` JSON cache on disk (simple, non-relational
 blobs). If asked "how would you cache account data locally," naming this tradeoff is the signal,
 not reciting Core Data API syntax from memory.

 ---

 ## Part 5: Money math — Decimal vs. Double

 The single most common fintech-flavored correctness bug: using `Double` for currency. Binary
 floating point can't represent most decimal fractions exactly, so small rounding errors accumulate —
 unacceptable when the number is someone's account balance.
*/

let a: Double = 0.1
let b: Double = 0.2
a + b == 0.3        // false — binary floating point rounding error

// Force-unwrapped here only because these are known-valid compile-time literals in a demo —
// per Day 2's own talking points, real code parsing an amount from user/network input should
// use `guard let` with a proper failure path instead, since a malformed string returns nil here.
let decimalA = Decimal(string: "0.1")!
let decimalB = Decimal(string: "0.2")!
decimalA + decimalB == Decimal(string: "0.3")!   // true — Decimal is base-10, exact for this

/*:
 **The rule to state out loud in an interview:** any customer-facing currency amount should be
 modeled as `Decimal` (or an integer minor-unit count, e.g. cents as `Int`), never `Double` — and if
 you see `Double` in a payments-adjacent codebase, that's worth flagging in code review.

 ---

 ## Part 6: Best Time to Buy and Sell Stock

 > **Problem:** Given an array of prices where `prices[i]` is the price on day `i`, find the maximum
 > profit from one buy and one sell (buy before you sell). Return 0 if no profit is possible.

 Reported by candidates in a fintech-flavored form ("given a list of trades, return buy/sell pairs
 and profit"). Single pass: track the minimum price seen so far, and the best profit achievable if
 you sold today.
*/

func maxProfit(_ prices: [Int]) -> Int {
    guard !prices.isEmpty else { return 0 }
    var minPriceSoFar = prices[0]
    var bestProfit = 0

    // Only tracking the VALUES (min price, best profit), never the day indices — the problem only
    // asks for the profit magnitude, not which two days achieved it, so there's no need to carry
    // index bookkeeping that a first pass at this problem often reaches for out of habit.
    for price in prices.dropFirst() {
        bestProfit = max(bestProfit, price - minPriceSoFar)
        minPriceSoFar = min(minPriceSoFar, price)
    }
    return bestProfit
}

maxProfit([7, 1, 5, 3, 6, 4])   // 5 (buy at 1, sell at 6)
maxProfit([7, 6, 4, 3, 1])      // 0 (prices only fall, no profit possible)

/*:
 ---

 ## Part 7: Idempotency pattern for account/payment requests

 Directly relevant to both your PayPal story and this role's "account management" surface: if a
 client retries a "submit payment" or "create account" request after a timeout, the server must not
 process it twice. The client-side pattern is to generate one idempotency key per *logical* attempt
 and resend the same key on retry.
*/

struct PaymentRequest {
    let idempotencyKey: UUID   // generated ONCE per logical submission, reused across retries
    let amount: Decimal
}

final class PaymentSubmitter {
    func submit(amount: Decimal, maxRetries: Int = 3) async throws {
        let request = PaymentRequest(idempotencyKey: UUID(), amount: amount)   // fixed for all attempts

        var attempt = 0
        while true {
            do {
                try await send(request)
                return
            } catch {
                attempt += 1
                if attempt >= maxRetries { throw error }
                // Exponential, not fixed, backoff (100ms, 200ms, 400ms...) — a fixed delay means
                // every failed client retries at the same cadence, which is what turns a struggling
                // server into a thundering herd right as it's trying to recover.
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 100_000_000)
            }
        }
    }

    private func send(_ request: PaymentRequest) async throws {
        // In reality: POST with `Idempotency-Key: request.idempotencyKey` header.
        // The server dedupes on that key, so a retried request after a dropped response
        // is a no-op rather than a double-charge.
    }
}

/*:
 **What to say out loud:** "the key insight is the idempotency key is generated once, outside the
 retry loop — if I generated a new key per attempt, retries would look like new, distinct requests
 to the server and defeat the whole point."

 ---

 ## Part 8: Pagination pattern for a transaction/account history list

 An account/transaction history screen is effectively guaranteed to need pagination. Cursor-based
 (not page-number-based) is the standard answer for data that can grow between page loads.
*/

struct Transaction: Identifiable {
    let id: String
    let description: String
    let amount: Decimal
}

struct TransactionPage {
    let items: [Transaction]
    let nextCursor: String?
}

protocol TransactionService {
    func fetchTransactions(cursor: String?) async throws -> TransactionPage
}

@MainActor
final class TransactionHistoryViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var isLoadingNextPage = false

    private var nextCursor: String?
    private var reachedEnd = false
    private let service: TransactionService

    init(service: TransactionService) {
        self.service = service
    }

    func loadNextPageIfNeeded(currentItem: Transaction) async {
        // This is meant to be called from every row's `.task`/`.onAppear` in the List (each row
        // passes itself as `currentItem`), but the check specifically compares against `.last` —
        // so out of N rows calling this, only the one row that IS the current last item actually
        // triggers a fetch. That's the whole "infinite scroll" mechanism, and it's why this needs
        // no scroll-position math at all.
        guard currentItem.id == transactions.last?.id else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoadingNextPage, !reachedEnd else { return }
        isLoadingNextPage = true
        // `defer`, not resetting the flag at the end of the `do` block — this guarantees the flag
        // clears on the `catch` path too. Without `defer`, a failed fetch would leave
        // `isLoadingNextPage` stuck `true` forever, permanently blocking further pagination.
        defer { isLoadingNextPage = false }

        do {
            let page = try await service.fetchTransactions(cursor: nextCursor)
            transactions.append(contentsOf: page.items)
            nextCursor = page.nextCursor
            // A nil cursor is the server's signal that there's no more data — this flag is what
            // the guard clause above reads to stop calling the network entirely once that happens,
            // rather than re-fetching an empty page forever.
            reachedEnd = page.nextCursor == nil
        } catch {
            // In production: surface a retry affordance rather than failing silently.
        }
    }
}

/*:
 **What to say out loud:** "I'm guarding on `isLoadingNextPage` so a fast scroll doesn't fire five
 concurrent fetches for the same page, and `reachedEnd` so I stop calling the network once the
 server signals there's no more data via a nil cursor."

 [↑ Back to Top](#top)
*/

//: [Next](@next)
