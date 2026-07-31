//: [Previous](@previous)

import SwiftUI
import Combine

/*:
 # SwiftUI & iOS Fundamentals — Robinhood Interview Prep

 Robinhood's iOS loop has shifted away from LeetCode-style puzzles toward **fundamentals under time
 pressure**: a 45–60 minute round where you build a small, real, API-connected SwiftUI app from an
 empty project, plus a project deep-dive where you defend real architectural decisions.

 ## Contents
 - Part 1: What the loop actually tests
 - Part 2: State management — the #1 asked topic
 - Part 3: Lists, identity & performance
 - Part 4: Networking + JSON with async/await
 - Part 5: Combine vs async/await
 - Part 6: Architecture — MVVM vs MV vs Redux-style
 - Part 7: Concurrency & memory safety
 - Part 8: Animation & Timer
 - Part 9: Worked example — live stock ticker list
 - Part 10: Beyond code — how to stand out
 - Live Preview — run this page to see a few of the views actually rendered

 ---

 ## Part 1: What the loop actually tests

 Based on public interview reports (Glassdoor, Blind, Medium writeups) for Robinhood iOS roles:

 - **Round 1 — live coding (45–60 min):** build a working MVP from scratch in Xcode. Common asks:
   a list/table of items fetched from a mock API, search or filtering, a detail screen, and *some*
   dynamic behavior (a countdown, a live-updating value, a simple animation). You are graded on
   speed, comfort with the tools (no googling basic syntax), and whether you narrate tradeoffs while
   typing — not on cleverness.
 - **What gets explicitly graded:** networking & JSON parsing (clean `Codable` models, no force-unwraps),
   and UI/state binding (a list that updates smoothly as the underlying data changes).
 - **Round 2+ — fundamentals & system design for mobile:** memory management (ARC, retain cycles),
   concurrency (`async/await` vs GCD vs actors), architecture (how you structure a feature end to end).
 - **Project deep-dive / behavioral:** be ready to whiteboard a real app you shipped — why you chose
   an architecture, what you'd change, and a metric that shows the impact.

 **Practice priority, in order:** (1) build a List-based screen with async networking cold, in under
 20 minutes, (2) know every state-management wrapper's ownership rules cold, (3) have one deep-dive
 story fully rehearsed.

 ---

 ## Part 2: State management — the #1 asked topic

 ```
 Wrapper                | Owns data?               | Survives recreation?         | Use when
 ------------------------+--------------------------+-------------------------------+---------------------------------------
 @State                 | yes (value, view-local)  | yes, stored outside struct   | local UI state: a toggle, a text field, isShowingSheet
 @Binding               | no, parent's ref         | n/a                           | child needs to read/write a parent's @State
 @StateObject           | yes (reference type)     | yes, created once            | the view that CREATES an ObservableObject
 @ObservedObject        | no                       | no, replaced by parent       | the view that RECEIVES an already-created ObservableObject
 @EnvironmentObject     | no                       | yes, via the environment     | deeply nested views need shared state, no prop drilling
 @Environment            | no                       | yes                           | system values (colorScheme, dismiss) or a custom @Observable via .environment()
 @Observable (iOS 17+)  | yes (macro)              | —                             | replaces ObservableObject/@Published; tracks only properties a view actually reads
 ```

 **The most common trap:** declaring a freshly-created `ObservableObject` as `@ObservedObject` instead
 of `@StateObject`. Every time the parent's `body` re-evaluates, SwiftUI discards the old instance and
 builds a new one — state silently resets (a timer restarts, a form clears, a picked date reverts).
*/

// @State — local, value-type, the view itself owns it
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
        }
    }
}

// @Binding — child mutates the parent's @State via a two-way reference
struct ToggleRow: View {
    @Binding var isOn: Bool
    var body: some View {
        Toggle("Notifications", isOn: $isOn)
    }
}

struct SettingsView: View {
    @State private var notificationsEnabled = true
    var body: some View {
        ToggleRow(isOn: $notificationsEnabled)
    }
}

// ObservableObject — the pre-iOS-17 way to model a view model
final class PortfolioViewModel: ObservableObject {
    @Published var totalValue: Double = 0
    @Published var holdings: [String] = []

    func refresh() {
        totalValue = 12_450.32
        holdings = ["AAPL", "TSLA", "RBLX"]
    }
}

// @StateObject — this view CREATES and owns the view model
struct PortfolioScreen: View {
    @StateObject private var viewModel = PortfolioViewModel()
    var body: some View {
        Text("$\(viewModel.totalValue, specifier: "%.2f")")
            .onAppear { viewModel.refresh() }
    }
}

// @ObservedObject — this view RECEIVES a view model it does not own
struct HoldingsList: View {
    @ObservedObject var viewModel: PortfolioViewModel
    var body: some View {
        List(viewModel.holdings, id: \.self) { Text($0) }
    }
}

// iOS 17+ — @Observable macro removes the ObservableObject/@Published ceremony
@Observable
final class PortfolioViewModelModern {
    var totalValue: Double = 0
    var holdings: [String] = []
}

struct PortfolioScreenModern: View {
    @State private var viewModel = PortfolioViewModelModern()   // note: @State, not @StateObject
    var body: some View {
        Text("$\(viewModel.totalValue, specifier: "%.2f")")
    }
}
// Interview talking point: @Observable's fine-grained tracking means a view that only reads
// `holdings` won't re-render when `totalValue` changes — @Published/ObservableObject invalidates
// every observing view on ANY published property change, which is coarser and costs more redraws.

/*:
 ---

 ## Part 3: Lists, identity & performance

 - `List` is backed by `UITableView`/`UICollectionView` — rows are recycled, only visible cells are
   built. Prefer it over `ScrollView { LazyVStack { ... } }` unless you need a layout `List` can't do
   (custom mixed-section styling, layout `.swipeActions` doesn't cover).
 - `ForEach` needs a **stable, unique** id per element (`Identifiable`, or an explicit `id:` keypath).
   An unstable id (e.g. array index after a sort/filter) makes SwiftUI think every row changed — cells
   reload, transitions glitch, scroll position jumps.
 - Never nest a `List` inside a `ScrollView` — that's two scroll containers fighting each other.
 - `.id()` forces SwiftUI to treat a view as a brand-new identity — handy to reset animation/transition
   state, expensive if overused since it destroys and rebuilds the whole subtree underneath it.
*/

struct Stock: Identifiable {
    let id: String        // ticker symbol — stable across refreshes, unlike an array index
    var price: Double
}

struct StockRow: View {
    let stock: Stock
    var body: some View {
        HStack {
            Text(stock.id)
            Spacer()
            Text(stock.price, format: .currency(code: "USD"))
        }
    }
}

struct StockListView: View {
    let stocks: [Stock]
    var body: some View {
        // Good: `Stock` conforms to Identifiable via its ticker — stable across sorts/reloads.
        List(stocks) { stock in
            StockRow(stock: stock)
        }
    }
}

// A trap worth naming out loud in an interview if you spot it in someone else's code:
//   List(stocks.indices, id: \.self) { i in StockRow(stock: stocks[i]) }
// The index is NOT a stable identity once `stocks` is sorted or filtered — SwiftUI ends up
// misattributing rows to the wrong data after a re-sort.

/*:
 ---

 ## Part 4: Networking + JSON with async/await

 Robinhood's live-coding round explicitly grades "networking & JSON parsing." The expected shape:
 1. A `Codable` struct matching the API's JSON (snake_case keys → `CodingKeys`, or a decoder-wide
    `keyDecodingStrategy`).
 2. `URLSession.shared.data(for:)` (or `.data(from:)`) as an **async call** — no completion-handler
    pyramid, no `[weak self]` juggling just to hop back to a callback.
 3. Decode with `JSONDecoder`, and throw a typed error instead of silently swallowing failures into
    an empty array.
 4. Keep the ViewModel `@MainActor` so published state is always mutated on the main thread — no
    manual `DispatchQueue.main.async`.
*/

struct QuoteDTO: Decodable {
    let symbol: String
    let lastPrice: Double
    let changePercent: Double

    enum CodingKeys: String, CodingKey {
        case symbol
        case lastPrice = "last_price"
        case changePercent = "change_percent"
    }
}

enum NetworkError: Error {
    case badStatus(Int)
    case decoding(Error)
}

func fetchQuotes(from url: URL) async throws -> [QuoteDTO] {
    let (data, response) = try await URLSession.shared.data(from: url)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1
        throw NetworkError.badStatus(code)
    }
    do {
        return try JSONDecoder().decode([QuoteDTO].self, from: data)
    } catch {
        throw NetworkError.decoding(error)
    }
}

@MainActor
final class QuotesViewModel: ObservableObject {
    @Published private(set) var quotes: [QuoteDTO] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    func load(from url: URL) async {
        isLoading = true
        defer { isLoading = false }
        do {
            quotes = try await fetchQuotes(from: url)
        } catch {
            errorMessage = "Couldn't load quotes: \(error.localizedDescription)"
        }
    }
}

/*:
 ---

 ## Part 5: Combine vs async/await — when to reach for which

 ```
 Situation                                              | Prefer
 --------------------------------------------------------+---------------------------------------------------------------------
 One-shot request/response (fetch quotes, submit order) | async/await — top-to-bottom, plain try/catch, no cancellable bookkeeping
 Continuous stream of values (live price ticks, etc.)   | Combine — debounce, throttle, combineLatest, removeDuplicates
 Search-as-you-type                                     | Combine (debounce on a @Published string) or AsyncStream — both fine
 Bridging a delegate/closure API into async code        | Combine's Future, or withCheckedThrowingContinuation
 Combining several async values from different sources  | async let / TaskGroup, or Combine's combineLatest/zip
 ```

 **Interview framing:** async/await replaced most of Combine's use as a callback bridge, but Combine
 still wins for *operators over a stream*. Know both, and don't imply one made the other obsolete.
*/

final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [String] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.results = text.isEmpty ? [] : ["\(text) Inc.", "\(text) Corp."]
            }
            .store(in: &cancellables)
    }
}

/*:
 ---

 ## Part 6: Architecture — MVVM vs MV vs Redux-style

 - **MVVM** (the safe default answer): the View is dumb, an `ObservableObject`/`@Observable` ViewModel
   holds state and business logic, the Model is plain data. Tradeoff: an extra layer for simple
   screens, but the ViewModel is unit-testable without ever instantiating a `View`.
 - **MV ("just use the View")** — Apple's own recent WWDC guidance for simpler screens: put
   `@State`/`@Observable` model objects directly in the View, skip a dedicated ViewModel, and lean on
   SwiftUI's own state-diffing. Tradeoff: less indirection and boilerplate, but business logic can
   leak into views without discipline, and view-only logic is slightly harder to unit test in isolation.
 - **Redux-style / TCA** (The Composable Architecture): a single-source-of-truth `State` struct, an
   `Action` enum, a pure `reducer`, `Effect`s for side effects. Tradeoff: excellent testability and
   time-travel debugging, very predictable — but real learning curve and ceremony that's overkill for
   a 45-minute round or a small screen.

 **What to say out loud:** default to MVVM, justify it with testability, and be ready to name when
 you'd reach for plain MV (a static settings screen) or TCA (a large team, a genuinely complex state
 machine, a hard requirement for deterministic tests).

 ---

 ## Part 7: Concurrency & memory safety

 - **Retain cycles**: a closure that captures `self` strongly while `self` holds onto that closure (a
   stored Combine `sink`, a stored completion handler) leaks. Fix with `[weak self]` and an early
   `guard let self else { return }`.
 - **`@MainActor`**: annotate ViewModels (or just their mutating methods) that touch `@Published`/UI
   state so the *compiler* enforces "no updating UI off the main thread" — preferred over sprinkling
   `DispatchQueue.main.async` everywhere.
 - **Structured concurrency**: prefer `Task { }` / `async let` / `TaskGroup` over manual
   `DispatchQueue` + semaphores — cancellation propagates automatically down the task tree, and you
   can't accidentally forget to resume a completion handler.
 - **Actors**: use a plain `actor` (not a `@MainActor` class) to protect shared mutable state touched
   from multiple background tasks (an in-memory cache, a rate limiter) — the compiler enforces
   serialized access, no manual locks needed.
*/

final class PriceStreamer {
    private var cancellable: AnyCancellable?

    func start(onTick: @escaping (Double) -> Void) {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            // [weak self] breaks the retain cycle between `self` and the closure `self` is storing
            .sink { [weak self] _ in
                guard self != nil else { return }
                onTick(Double.random(in: 99...101))
            }
    }
}

actor QuoteCache {
    private var cache: [String: Double] = [:]
    func set(_ price: Double, for symbol: String) { cache[symbol] = price }
    func price(for symbol: String) -> Double? { cache[symbol] }
}

/*:
 ---

 ## Part 8: Animation & Timer — live-coding essentials

 - **Implicit animation**: `.animation(.easeInOut, value: someState)` — animates *any* change to
   `someState` that affects this view.
 - **Explicit animation**: `withAnimation(.spring()) { someState.toggle() }` — animates exactly this
   one state change, nothing else incidentally caught up in it.
 - **Transitions**: `.transition(.slide)` only fires when a view *enters/leaves* the view tree
   (paired with `if`/`ForEach` insert-remove) — it does not animate property changes on a view that stays.
 - **Timer, two ways:**
   - Combine: `Timer.publish(every: 1, on: .main, in: .common).autoconnect()` — natural if the rest of
     the screen is already Combine-based.
   - `TimelineView(.periodic(from: .now, by: 1)) { context in ... }` — SwiftUI-native, no manual
     cancellable/lifecycle management, the better default for pure display-driven ticking (a live
     clock, a price flashing green/red).
*/

struct FlashingPriceText: View {
    let price: Double
    var wentUp: Bool

    var body: some View {
        Text(price, format: .currency(code: "USD"))
            .foregroundStyle(wentUp ? .green : .red)
            .animation(.easeInOut(duration: 0.3), value: price)
    }
}

struct LiveClock: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            Text(context.date, style: .time)
        }
    }
}

/*:
 ---

 ## Part 9: Worked example — live stock ticker list

 This is a rehearsal for the exact prompt Robinhood asks: a `List`, real (simulated) networking with
 `Codable`, search, sort, pull-to-refresh, and a live-updating value — all in one compileable screen.
 Read the comments; they're the tradeoffs you'd narrate out loud while typing this in the interview.
*/

struct Quote: Identifiable, Codable, Hashable {
    let id: String          // ticker — Identifiable's stable key, also what the API returns
    var price: Double
    var changePercent: Double
}

// Simulates hitting a real endpoint — same shape you'd write against a live API under time pressure.
func fetchMockQuotes() async throws -> [Quote] {
    try await Task.sleep(nanoseconds: 300_000_000)   // pretend network latency
    return [
        Quote(id: "AAPL", price: 227.16, changePercent: 0.42),
        Quote(id: "TSLA", price: 248.98, changePercent: -1.85),
        Quote(id: "RBLX", price: 61.30, changePercent: 3.10),
        Quote(id: "NVDA", price: 128.44, changePercent: 1.02),
    ]
}

@MainActor
final class TickerViewModel: ObservableObject {
    @Published private(set) var quotes: [Quote] = []
    @Published var searchText = ""
    @Published var sortByGainersFirst = true
    @Published private(set) var isLoading = false

    private var tickTask: Task<Void, Never>?

    // Computed, not stored+synced — one source of truth (`quotes`) instead of a second array that
    // can drift out of sync with the raw data whenever search/sort settings change.
    var visibleQuotes: [Quote] {
        let filtered = searchText.isEmpty
            ? quotes
            : quotes.filter { $0.id.localizedCaseInsensitiveContains(searchText) }
        return filtered.sorted {
            sortByGainersFirst ? $0.changePercent > $1.changePercent : $0.changePercent < $1.changePercent
        }
    }

    func loadInitial() async {
        isLoading = true
        defer { isLoading = false }
        quotes = (try? await fetchMockQuotes()) ?? []
    }

    // The "Timer" part of the prompt — done with structured concurrency (a cancellable Task) instead
    // of Combine's Timer publisher, so lifecycle is just "cancel the task," no subscription to store.
    func startLiveTicks() {
        tickTask?.cancel()
        tickTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                for i in quotes.indices {
                    let delta = Double.random(in: -0.5...0.5)
                    quotes[i].price += delta
                    quotes[i].changePercent += delta / quotes[i].price * 100
                }
            }
        }
    }

    func stopLiveTicks() { tickTask?.cancel() }
}

struct TickerRow: View {
    let quote: Quote
    var body: some View {
        HStack {
            Text(quote.id).bold()
            Spacer()
            VStack(alignment: .trailing) {
                Text(quote.price, format: .currency(code: "USD"))
                Text(quote.changePercent / 100, format: .percent.precision(.fractionLength(2)))
                    .foregroundStyle(quote.changePercent >= 0 ? .green : .red)
                    .font(.caption)
            }
        }
        .animation(.easeInOut, value: quote.price)
    }
}

struct TickerListView: View {
    @StateObject private var viewModel = TickerViewModel()   // this view CREATES the view model → @StateObject

    var body: some View {
        NavigationStack {
            List(viewModel.visibleQuotes) { quote in
                // NavigationLink(value:) — pushes by VALUE, not by eagerly building a destination view.
                // Paired with .navigationDestination(for:) below, this is the iOS 16+ pattern: the
                // list only needs to know the row content, not what the pushed screen looks like.
//                NavigationLink(value: quote) {
//                    TickerRow(quote: quote)
//                }

                NavigationLink {
                    QuoteDetailView(quote: quote)
                } label: {
                    TickerRow(quote: quote)
                }

//                NavigationLink(quote.id) {
//                    QuoteDetailView(quote: quote)
//                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search ticker")
            .refreshable { await viewModel.loadInitial() }   // pull-to-refresh, free with `List`
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(viewModel.sortByGainersFirst ? "Gainers" : "Losers") {
                        viewModel.sortByGainersFirst.toggle()
                    }
                }
            }
            .navigationTitle("Watchlist")
//            .navigationDestination(for: Quote.self) { quote in
//                QuoteDetailView(quote: quote)
//            }
            .task {
                await viewModel.loadInitial()
                viewModel.startLiveTicks()
            }
            .onDisappear { viewModel.stopLiveTicks() }   // stop the background task when the screen leaves — avoid leaking a running Task
        }
    }
}

// Tapping a row pushes here. Kept as a separate, independently-previewable View — same reasoning
// as splitting TickerRow out of TickerListView: small, single-purpose views are easier to preview,
// reuse, and unit-test in isolation than one giant body.
struct QuoteDetailView: View {
    let quote: Quote

    // Derived display-only values — a real screen would fetch these from the API detail endpoint;
    // here they're computed from the quote so the detail screen has something to show.
    private var dayLow: Double { quote.price * 0.97 }
    private var dayHigh: Double { quote.price * 1.03 }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quote.id)
                        .font(.largeTitle.bold())
                    Text(quote.price, format: .currency(code: "USD"))
                        .font(.title2)
                    Text(quote.changePercent / 100, format: .percent.precision(.fractionLength(2)))
                        .foregroundStyle(quote.changePercent >= 0 ? .green : .red)
                }
                .padding(.vertical, 8)
            }

            Section("Today's Range") {
                HStack { Text("Low");  Spacer(); Text(dayLow, format: .currency(code: "USD")) }
                HStack { Text("High"); Spacer(); Text(dayHigh, format: .currency(code: "USD")) }
            }

            Section {
                Button("Buy \(quote.id)") { }
                Button("Sell \(quote.id)") { }.foregroundStyle(.red)
            }
        }
        .navigationTitle(quote.id)
    }
}

/*:
 Why this shape, in interview-narration form:
 - `List`, not `ScrollView`+`LazyVStack` — free cell recycling, free `.searchable`/`.refreshable`.
 - `@StateObject` at the root, `@MainActor` on the class — state ownership and thread-safety are both
   enforced by the compiler, not by convention.
 - `visibleQuotes` is computed from one source of truth — no risk of a second "filteredQuotes" array
   silently going stale.
 - Live ticking uses a single cancellable `Task`, matched to a `.task`/`.onDisappear` pair — no
   Combine subscription to remember to cancel, no retain cycle to reason about.
 - **Row tap → detail:** `NavigationLink(value: quote)` + `.navigationDestination(for: Quote.self)`
   instead of the older `NavigationLink(destination: QuoteDetailView(quote: quote))`. The value-based
   form is the pattern to default to in an interview: it decouples "what a row looks like" from
   "what pushing it navigates to," and it composes with a `NavigationPath` if you later need
   programmatic navigation (deep links, "jump to this ticker from a push notification") — the
   destination-based form has no equivalent without restructuring the view.

 ---

 ## Part 10: Beyond code — how to stand out

 - **One deep-dive story, fully rehearsed, in STAR form:** situation → the architecture decision you
   made → the tradeoffs you weighed → a metric that shows the impact (crash rate, launch time,
   feature adoption). Robinhood explicitly interviews for this; a vague "we used MVVM" answer reads
   as junior.
 - **A small public repo** demonstrating MVVM or MV with `async/await`, unit tests on ViewModels
   (inject the network as a protocol so it's mockable), and a README that states the tradeoffs you
   chose and why — this is a concrete artifact an interviewer can actually look at.
 - **A testing story:** protocol-based dependency injection for services, an `async` XCTest that
   awaits a ViewModel's published state, maybe a snapshot test on a critical view.
 - **A performance story:** a real time you used Instruments (Time Profiler, Allocations, the memory
   graph debugger) to find and fix a retain cycle, a main-thread hang, or excessive SwiftUI re-renders.
 - **Accessibility, mentioned unprompted:** Dynamic Type support, VoiceOver labels, minimum tap
   targets — this reads as senior-level polish without being asked.
 - **Narrate tradeoffs out loud while typing.** Robinhood's rubric explicitly grades communication
   under time pressure — a working app with silent typing scores worse than a slightly rougher app
   where you explained every decision as you made it.
 - **Ask one informed question at the end**, e.g. "Are you moving further toward `@Observable` and
   Swift 6 strict concurrency, or is Combine still core to the codebase?" — it signals you did your
   homework and think about migration cost, not just syntax.

 ---
*/

/*:
 ## Live Preview

 Xcode Playgrounds render SwiftUI through **PlaygroundSupport's Live View**, not the Xcode canvas
 `#Preview` macro — that macro only works inside a real app target, not a `.playgroundpage`.

 **If nothing appears when you run this page**, it's almost always one of these, in order of likelihood:
 1. **The Live View pane isn't open.** Menu bar ▸ **Editor ▸ Live View** (or the small overlapping-
    circles icon top-right ▸ Assistant Editor). The page can finish running with zero errors and
    still show nothing if this pane was never opened.
 2. **The page hasn't finished executing yet.** With a live-ticking `Task` running (Part 9), the
    playground stays "running" indefinitely — that's expected (`needsIndefiniteExecution = true`),
    not a hang. Check for a spinner vs. a red error badge in the left-hand gutter.
 3. **A build error earlier in the page** silently prevents the last line from ever running — check
    the Issue Navigator (⌘5) for red errors before assuming the Live View itself is broken. The most
    common one: this playground bundle's platform (Editor ▸ Playground Settings, or the platform
    picker at the bottom of the window) is set to **macOS** instead of **iOS**. Everything above
    compiles on both, but `UIHostingController` only exists on iOS — the `#if canImport(UIKit)`
    below handles that automatically, but if you still see "no such module" errors, switch the
    playground's platform to iOS.

 **Why the live view looked short, and why `TabView`'s tabs didn't respond:** both came from the
 same root cause. Without an explicit size, `PlaygroundSupport` hosts the view at whatever tiny
 default the Live View pane happens to start at, and a `TabView` lays itself out — including
 positioning its own tab bar — based on that cramped height. The tab bar ends up rendered somewhere
 that doesn't line up with where it's actually tappable. Setting `preferredContentSize` on the
 hosting controller to a real phone-sized canvas fixes both: the app now renders at full height, and
 the tab bar sits where it's supposed to and responds normally.
*/

import PlaygroundSupport

struct FundamentalsPreviewGallery: View {
    var body: some View {
        TabView {
            CounterView()
                .tabItem { Label("@State", systemImage: "1.circle") }

            LiveClock()
                .tabItem { Label("TimelineView", systemImage: "clock") }

            TickerListView()
                .tabItem { Label("Tap a Row →", systemImage: "list.bullet") }
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

#if canImport(UIKit)
let hostingController = UIHostingController(rootView: FundamentalsPreviewGallery())
hostingController.preferredContentSize = CGSize(width: 390, height: 844)   // iPhone-sized canvas, not the pane's cramped default
PlaygroundPage.current.liveView = hostingController
#elseif canImport(AppKit)
let hostingController = NSHostingController(rootView: FundamentalsPreviewGallery())
hostingController.preferredContentSize = CGSize(width: 390, height: 844)
PlaygroundPage.current.liveView = hostingController
#endif

//: [Next](@next)
