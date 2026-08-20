//: [Previous](@previous)

import Foundation
import SwiftUI

/*:
 # Fanatics Prep — Day 5: iOS Round Pt 2 — SDUI, KMP Boundary & Live-Build Drill

 This page preps the more hands-on version of the "iOS-style" round — a live-build/system-design
 flavored session, or a deeper conceptual dive specifically into the two things that make this role
 different from a generic iOS req: **server-driven UI (SDUI) + experimentation**, and the **KMP
 boundary** (Day 0, Part 2's day-to-day reasoning, now made concrete in code).

 ## Contents
 - Part 1: SDUI — the mental model, worked in code
 - Part 2: SDUI + A/B testing/experimentation together
 - Part 3: A live-build drill — render a server-driven card list screen
 - Part 4: The KMP boundary story — `expect`/`actual` in Swift, live-codeable
 - Part 5: Debugging & profiling — what to say if asked "how would you find a slow screen"

 ---

 ## Part 1: SDUI — the mental model, worked in code

 The core idea: the **server sends a description of a screen** (a JSON tree of typed components and
 their data), and the client has a **rendering engine** that maps each component type to a native view.
 The server can change layout/copy/component order **without an app release** — the tradeoff is the
 client only knows how to render component types it's already shipped support for, so an unrecognized
 type needs a graceful fallback, not a crash.
*/

enum SDUIComponent: Decodable {
    case text(content: String)
    case image(url: String)
    case button(title: String, actionID: String)
    case stack(direction: String, children: [SDUIComponent])
    case unknown   // the fallback case — decoding an unrecognized "type" lands here, not a crash

    private enum CodingKeys: String, CodingKey { case type, content, url, title, actionID, direction, children }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            self = .text(content: try container.decode(String.self, forKey: .content))
        case "image":
            self = .image(url: try container.decode(String.self, forKey: .url))
        case "button":
            self = .button(
                title: try container.decode(String.self, forKey: .title),
                actionID: try container.decode(String.self, forKey: .actionID)
            )
        case "stack":
            self = .stack(
                direction: try container.decode(String.self, forKey: .direction),
                children: try container.decode([SDUIComponent].self, forKey: .children)
            )
        default:
            // A new component type the SERVER started sending before the CLIENT shipped support
            // for it — this is the exact scenario SDUI has to survive gracefully, since the server
            // and client release independently. Silently rendering nothing (or a neutral fallback
            // view) beats a decode failure that takes down the whole screen for one unknown node.
            self = .unknown
        }
    }
}

// `AnyView`, not `some View` — a function that recursively calls itself (the `.stack` case below)
// can't have its opaque return type inferred in terms of itself; type-erasing is the standard
// escape hatch for a recursive view-building function like this one.
func render(_ component: SDUIComponent, onAction: @escaping (String) -> Void) -> AnyView {
    switch component {
    case .text(let content):
        return AnyView(Text(content))
    case .image(let url):
        return AnyView(AsyncImage(url: URL(string: url)))
    case .button(let title, let actionID):
        return AnyView(Button(title) { onAction(actionID) })
    case .stack(let direction, let children):
        let renderedChildren = children.map { render($0, onAction: onAction) }
        if direction == "horizontal" {
            return AnyView(HStack { ForEach(renderedChildren.indices, id: \.self) { renderedChildren[$0] } })
        } else {
            return AnyView(VStack { ForEach(renderedChildren.indices, id: \.self) { renderedChildren[$0] } })
        }
    case .unknown:
        return AnyView(EmptyView())   // graceful degradation, not a crash — the whole point of .unknown
    }
}

/*:
 **What to say out loud:** "the rendering engine's job is mapping a fixed set of component types to
 native views — the part that actually matters for correctness is the fallback path: an unrecognized
 component type has to degrade gracefully, because the server can start sending a new type before the
 client ships support for rendering it, and those two things release independently."

 ---

 ## Part 2: SDUI + A/B testing/experimentation together

 The JD pairs these explicitly — the natural combination: the server decides **which variant of a
 screen's component tree** to send per user/experiment bucket, so an A/B test doesn't require an app
 release either. The client's job is just to record which variant it rendered, for attribution.
*/

struct ScreenRequest {
    let screenID: String
    let experimentContext: [String: String]   // e.g. ["userBucket": "control"] sent to the server
}

protocol SDUIClient {
    func fetchScreen(_ request: ScreenRequest) async throws -> (components: [SDUIComponent], variantID: String)
}

final class ExperimentAwareScreenLoader {
    private let client: SDUIClient
    private let analytics: (String, String) -> Void   // (screenID, variantID) -> log exposure

    init(client: SDUIClient, analytics: @escaping (String, String) -> Void) {
        self.client = client
        self.analytics = analytics
    }

    func load(screenID: String) async throws -> [SDUIComponent] {
        let (components, variantID) = try await client.fetchScreen(
            ScreenRequest(screenID: screenID, experimentContext: [:])
        )
        // Logging exposure the moment a variant is actually rendered — not when the experiment is
        // merely fetched or configured — is what makes downstream A/B analysis trustworthy; log too
        // early and you'd count users who never actually saw the variant.
        analytics(screenID, variantID)
        return components
    }
}

/*:
 **What to say out loud:** "the client stays dumb about *why* it got a particular tree — bucketing
 logic lives server-side. The one thing the client owns is firing an exposure event at the moment it
 actually renders a given variant, since that's the event experimentation analysis depends on."

 ---

 ## Part 3: A live-build drill — render a server-driven card list screen

 If the round is genuinely live-coding (build-from-blank-project style, similar to what a project-call
 format elsewhere asks for): a plausible senior-appropriate prompt given this domain — "render a list of
 credit cards from mock JSON, tap a card to see detail, handle a loading and an error state." A minimal
 shape worth having ready to type from scratch, fast:
*/

struct CreditCardSummary: Decodable, Identifiable {
    let id: String
    let last4: String
    let balance: Decimal
}

enum LoadState<T> {
    case loading
    case loaded(T)
    case failed(String)
}

@MainActor
final class CardListScreenViewModel: ObservableObject {
    @Published private(set) var state: LoadState<[CreditCardSummary]> = .loading
    private let fetchCards: () async throws -> [CreditCardSummary]

    init(fetchCards: @escaping () async throws -> [CreditCardSummary]) {
        self.fetchCards = fetchCards
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await fetchCards())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}

struct CardListScreen: View {
    @StateObject var viewModel: CardListScreenViewModel
    let onSelect: (CreditCardSummary) -> Void

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .loaded(let cards):
                List(cards) { card in
                    // `.description`, not raw interpolation — SwiftUI's LocalizedStringKey
                    // interpolation only special-cases types it knows how to localize; `Decimal`
                    // isn't one, so String(describing:) avoids the deprecation path.
                    Button("•••• \(card.last4) — $\(card.balance.description)") { onSelect(card) }
                }
            case .failed(let message):
                Text("Error: \(message)")
            }
        }
        .task { await viewModel.load() }
    }
}

/*:
 **What to narrate while typing this:** state as an explicit enum (`loading`/`loaded`/`failed`) rather
 than three separate optional/bool properties — it makes invalid combinations (e.g. `isLoading == true`
 AND `cards` non-empty AND `errorMessage` non-nil, all at once) unrepresentable, which is a stronger
 guarantee than remembering to keep three flags in sync by convention.

 ---

 ## Part 4: The KMP boundary story — `expect`/`actual` in Swift, live-codeable

 If asked to sketch how you'd structure a feature that needs both shared logic and native iOS behavior
 — this is the answer, and it directly reuses the Wallet example from Day 0, Part 4 in a more general
 form so you can adapt it to whatever specific prompt comes up live.
*/

// The Swift-side mirror of what a KMP `expect` interface generates for iOS consumption.
protocol PlatformCapability {
    func isSupported() -> Bool
    func perform() async throws
}

// Exactly ONE `actual` conformance per capability, isolating the platform-specific import to one file.
final class BiometricAuthCapability: PlatformCapability {
    func isSupported() -> Bool {
        // In reality: LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error:)
        true
    }

    func perform() async throws {
        // In reality: LAContext().evaluatePolicy(...) via a checked-throwing-continuation bridge,
        // since LocalAuthentication's API predates async/await.
    }
}

/*:
 **What to say out loud:** "wherever the shared Kotlin module needs something iOS-only — biometrics,
 Wallet, push registration — I'd model it as a small protocol on the Swift side that mirrors the KMP
 `expect` declaration, with exactly one concrete `actual`-equivalent conformance that's the only place
 in the codebase importing that platform framework. Keeps the platform-specific surface area small,
 explicit, and easy to find."

 ---

 ## Part 5: Debugging & profiling — "how would you find a slow screen"

 The JD explicitly lists "debugging and profiling skills" and Core Animation. A concrete, tool-by-tool
 answer beats a vague "I'd profile it":

 - **Instruments — Time Profiler**: sampling CPU usage over time, symbolicated call tree — the first
   stop for "this screen feels slow," to find which function is actually burning CPU.
 - **Instruments — Core Animation**: frame rate over time plus a color-coded overlay
   (`Debug > View Debugging > Rendering > Color Blended Layers`, etc., or the Core Animation instrument
   itself) for spotting offscreen rendering, blending, and layout thrash specifically — the tool to
   reach for once Time Profiler points at rendering rather than business logic.
 - **Instruments — Allocations/Leaks**: for a screen that gets slower the longer it's used (not just
   slow on first load) — a strong signal of a retain-cycle-driven memory growth issue (Day 4, Part 4).
 - **SwiftUI-specific**: `self._printChanges()` inside a view's `body` (debug-only) to see exactly
   which dependency triggered a re-render — useful for "this view re-renders way more than it should"
   specifically, a common SDUI-adjacent bug if the rendering engine over-invalidates on unrelated state
   changes.
 - **A concrete SDUI-specific failure mode worth naming unprompted**: a naive rendering engine that
   re-parses/re-diffs the entire component tree on every state change (instead of diffing at the
   sub-tree level) turns a small server-side update into a full-screen re-render — exactly the kind of
   performance bug that's specific to this architecture rather than generic SwiftUI advice.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
