//: [Previous](@previous)

import SwiftUI

/*:
 # Robinhood Finals — Day 4: Project Call — Live-Build Drill

 Recap from the SwiftUI Fundamentals page: the project call is the same format as the technical
 screen — plan first, then build — but **no skeleton code**, you start from a blank Xcode project,
 and it's graded on UI state management and clear data flow, not algorithmic cleverness.

 ## Contents
 - Part 1: The drill — build this cold, in Xcode, in ≤30 minutes
 - Part 2: Time-boxed structure
 - Part 3: Reference solution (what "done" looks like)
 - Part 4: Narration checklist — say these things out loud
 - Part 5: Common traps that read as red flags
 - Live Preview — run this page to see the reference solution rendered

 ---

 ## Part 1: The drill

 Build a **Watchlist** screen from a blank SwiftUI app:
 - A list of stock symbols loaded from an (async, mocked) service, showing symbol + price.
 - A search field that filters the list client-side as the user types.
 - Loading and error states while the async fetch is in flight.
 - Tapping a row pushes a detail screen showing the same symbol with a bit more data.
 - A live-updating element somewhere (e.g. the detail screen's price ticks every second) — this is
   the "some dynamic behavior" piece interviewers look for.

 Do this in actual Xcode first, from `File > New > Project > iOS > App`, not by reading the solution
 below. Time yourself. Then compare against Part 3.

 ---

 ## Part 2: Time-boxed structure

 ```
 0–3 min   | Restate the requirements back, ask 1-2 clarifying questions (mock data ok? navigation
           | style — NavigationStack fine? does search need to hit network or filter locally?)
 3–8 min   | Models + a ViewModel/service protocol. Get the shape of the data right before UI.
 8–18 min  | List screen: fetch on appear, loading/error states, render rows.
 18–24 min | Search filtering wired to the list.
 24–30 min | Detail screen + navigation + the live-updating element. Polish only if time remains.
 ```

 If you're behind schedule, cut polish, not the state-management fundamentals — a plain list that
 correctly handles loading/error/empty states beats a beautiful list that force-unwraps a network
 response.

 ---

 ## Part 3: Reference solution
*/

// MARK: - Model

struct Stock: Identifiable, Equatable {
    let id = UUID()
    let symbol: String
    var price: Double
}

// MARK: - Service (protocol so the ViewModel is testable without a real network)

protocol StockService {
    func fetchStocks() async throws -> [Stock]
}

struct MockStockService: StockService {
    func fetchStocks() async throws -> [Stock] {
        try await Task.sleep(nanoseconds: 500_000_000)   // simulate network latency
        return [
            Stock(symbol: "AAPL", price: 227.52),
            Stock(symbol: "TSLA", price: 248.10),
            Stock(symbol: "RBLX", price: 61.34),
            Stock(symbol: "NVDA", price: 118.42),
            Stock(symbol: "AMZN", price: 186.90)
        ]
    }
}

// MARK: - ViewModel (owns loading/error/data state, so the View just renders)

@MainActor
final class WatchlistViewModel: ObservableObject {
    // An enum, not three separate Bools (isLoading/isLoaded/errorMessage) — the enum makes
    // impossible states unrepresentable (e.g. loading == true AND failed == true at once),
    // whereas three independent Bools can always drift out of sync with each other.
    enum LoadState: Equatable {
        case loading
        case loaded
        case failed(String)
    }

    @Published private(set) var state: LoadState = .loading
    @Published private(set) var stocks: [Stock] = []
    @Published var searchText: String = ""

    private let service: StockService

    init(service: StockService = MockStockService()) {
        self.service = service
    }

    // Computed, not a separately stored/cached property — it reads two @Published properties
    // (stocks, searchText), so SwiftUI recomputes it on every access with no manual invalidation
    // logic. A cached version would need explicit invalidation on both stocks AND searchText
    // changes, which is exactly the kind of state-sync bug this sidesteps entirely.
    var filteredStocks: [Stock] {
        guard !searchText.isEmpty else { return stocks }
        return stocks.filter { $0.symbol.localizedCaseInsensitiveContains(searchText) }
    }

    func load() async {
        state = .loading
        do {
            stocks = try await service.fetchStocks()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

// MARK: - List screen

struct WatchlistView: View {
    @StateObject private var viewModel: WatchlistViewModel   // this screen CREATES its view model

    init(service: StockService = MockStockService()) {
        // Can't write `viewModel = WatchlistViewModel(...)` directly — @StateObject's persistent
        // storage lives behind the underscore-prefixed backing property, and StateObject's own
        // init is the only supported way to seed it exactly once per view identity. Assigning the
        // wrapped value instead would just create a plain instance that gets discarded and
        // re-created on every body re-evaluation, defeating the whole point of @StateObject.
        _viewModel = StateObject(wrappedValue: WatchlistViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Watchlist")
                .searchable(text: $viewModel.searchText)
                // `.task`, not `.onAppear { Task { ... } }` — `.task` ties the async work's
                // lifetime to the view's: SwiftUI auto-cancels it if the view disappears before
                // `load()` finishes. A manually spawned Task in `.onAppear` keeps running
                // regardless, which can race a state update against a view that's already gone.
                .task { await viewModel.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading…")
        case .failed(let message):
            ContentUnavailableFallback(message: message) {
                Task { await viewModel.load() }
            }
        case .loaded:
            List(viewModel.filteredStocks) { stock in
                NavigationLink(value: stock) {
                    HStack {
                        Text(stock.symbol).bold()
                        Spacer()
                        Text(stock.price, format: .currency(code: "USD"))
                    }
                }
            }
            .navigationDestination(for: Stock.self) { stock in
                StockDetailView(stock: stock)
            }
        }
    }
}

// Stand-in for ContentUnavailableView (available iOS 17+) so this compiles on older targets too.
struct ContentUnavailableFallback: View {
    let message: String
    let retry: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Text("Couldn't load watchlist").font(.headline)
            Text(message).font(.caption).foregroundStyle(.secondary)
            Button("Retry", action: retry)
        }
    }
}

extension Stock: Hashable {
    // Identity is defined by `id` alone, not by comparing every field — `navigationDestination(for:)`
    // uses Hashable to key navigation state, and identity (not full-value equality) is what that
    // needs. The real gotcha this creates: `id = UUID()` is generated fresh every time a Stock
    // value is constructed, so re-fetching the list produces brand-new ids for the "same" symbol —
    // a stale NavigationPath entry from before a refetch won't match after it.
    static func == (lhs: Stock, rhs: Stock) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: - Detail screen (the "dynamic behavior" ask — price ticks live)

struct StockDetailView: View {
    let stock: Stock
    @State private var livePrice: Double
    @State private var timer: Timer?

    init(stock: Stock) {
        self.stock = stock
        // Can't write `@State private var livePrice = stock.price` at the declaration site —
        // a property wrapper's default expression can't reference another instance property
        // (`stock`) that isn't set yet. Seeding it explicitly through the underscore-prefixed
        // backing storage in init is the only way to initialize @State from a constructor argument.
        _livePrice = State(initialValue: stock.price)
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(stock.symbol).font(.largeTitle).bold()
            Text(livePrice, format: .currency(code: "USD"))
                .font(.title)
                .contentTransition(.numericText())
                // contentTransition alone doesn't animate anything — it only defines HOW a
                // transition looks once one is triggered. `.animation(_:value:)` is what actually
                // triggers it, tied specifically to `livePrice` so unrelated state changes don't.
                .animation(.default, value: livePrice)
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // Timer's closure isn't MainActor-isolated by default, so mutating `livePrice`
                // (MainActor-isolated view state) directly from it would be a data-race warning/
                // error under strict concurrency. Hopping into `Task { @MainActor in }` is what
                // makes the mutation safe.
                Task { @MainActor in
                    livePrice += Double.random(in: -1.5...1.5)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()   // stop ticking once the view leaves — avoid leaking a repeating timer
        }
    }
}

/*:
 ---

 ## Part 4: Narration checklist — say these things out loud

 - "I'm putting the async fetch behind a `StockService` protocol so the ViewModel is testable with a
   fake, and so the view doesn't know or care where the data comes from."
 - "This screen creates its own view model, so it's `@StateObject`, not `@ObservedObject` — otherwise
   a parent re-render would silently reset the loading state."
 - "I'm modeling loading/loaded/failed as an enum on the ViewModel rather than three separate
   booleans — booleans can represent invalid combinations (loading *and* failed at once); the enum
   can't."
 - "Filtering happens as a computed property over the already-fetched list, not a new network call
   per keystroke — cheap, and I'd debounce this if it did hit the network (see Day 3, Part 5)."
 - "I invalidate the timer `onDisappear` so it doesn't keep firing (and retaining the view) after the
   user navigates away."

 ---

 ## Part 5: Common traps that read as red flags

 - Declaring a freshly created `ObservableObject` as `@ObservedObject` in the owning view (state
   silently resets on re-render — the #1 called-out mistake).
 - Force-unwrapping the network result or array access (`stocks[0]`) instead of guarding empty state.
 - Filtering by re-fetching from the network on every keystroke instead of filtering the in-memory
   array, with no debounce mentioned either way.
 - Starting a `Timer` without ever invalidating it — a real memory/behavior leak, and an easy thing
   for an interviewer to probe ("what happens if the user backs out of this screen?").
 - Jumping straight into typing without stating the plan (state shape, loading states, navigation)
   first — this call is explicitly graded on clear data flow and reasoning, not just working code.

 ---

 ## Live Preview
*/

import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

#if canImport(UIKit)
let hostingController = UIHostingController(rootView: WatchlistView())
hostingController.preferredContentSize = CGSize(width: 390, height: 844)
PlaygroundPage.current.liveView = hostingController
#elseif canImport(AppKit)
let hostingController = NSHostingController(rootView: WatchlistView())
hostingController.preferredContentSize = CGSize(width: 390, height: 844)
PlaygroundPage.current.liveView = hostingController
#endif

//: [Next](@next)
