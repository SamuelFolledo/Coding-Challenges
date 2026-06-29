//: [Previous](@previous)

import Foundation

/*:
 # Soft Skill Guide
 Behavioral stories and coding principles — ready to reference before interviews.

 ---

 ## Coding Principles with Stories

 ### 1. Dependency Inversion — PayPal SwiftUI Rewrite

 **The principle:** High-level modules should depend on *abstractions*, not concrete implementations.
 Instead of a view model directly creating and using `URLSession`, it depends on a protocol that
 describes what it needs — and the real network code is just one implementation of that protocol.

 **Why it matters:**
 - Tests run instantly and deterministically (no flaky network, no waiting)
 - You can simulate error cases easily (have the mock throw)
 - You can develop UI before the backend endpoint even exists

 **The story:**
 *"During the UIKit-to-SwiftUI rewrite for credit card products at PayPal, we made sure every view
 model took its services as protocol-typed dependencies instead of concrete network classes. That
 meant our test suite could inject mocks and cover edge cases like expired sessions or malformed
 responses without ever hitting a real endpoint. It also meant designers and other engineers could
 build and demo new screens against fake data before the backend was ready, which kept the rewrite
 moving in parallel across teams."*
*/

// --- Dependency Inversion Example ---

// 1. Define a protocol describing what the view model needs
protocol CardServiceProtocol {
    func fetchCardDetails(id: String) async throws -> CardDetails
}

struct CardDetails {
    let id: String
    let last4: String
    let balance: Double
}

// 2. The real implementation hits the network
class CardService: CardServiceProtocol {
    func fetchCardDetails(id: String) async throws -> CardDetails {
        // actual URLSession/network call would go here
        return CardDetails(id: id, last4: "4242", balance: 500.0)
    }
}

// 3. The view model depends on the PROTOCOL, not the concrete class
class CardViewModel: ObservableObject {
    private let service: CardServiceProtocol
    var cardDetails: CardDetails?

    // Injected from outside — defaults to real implementation in production
    init(service: CardServiceProtocol = CardService()) {
        self.service = service
    }

    func loadCard(id: String) async {
        cardDetails = try? await service.fetchCardDetails(id: id)
    }
}

// 4. In tests: swap in a mock — no network, no flakiness
class MockCardService: CardServiceProtocol {
    func fetchCardDetails(id: String) async throws -> CardDetails {
        return CardDetails(id: id, last4: "1234", balance: 100.0)   // fixed test data
    }
}

// Usage in a test
Task {
    let viewModel = CardViewModel(service: MockCardService())
    await viewModel.loadCard(id: "abc")
    print(viewModel.cardDetails?.last4 ?? "nil")  // "1234" — no network call
}

/*:
 ---

 ### 2. Single Responsibility — Garmin Bluetooth Troubleshooter

 **The principle:** A class or module should have one — and only one — reason to change.
 Mixing concerns (UI state, business logic, formatting) into one class makes every bug fix
 risky because unrelated behavior can break.

 **Why it matters:**
 - Debugging is faster — each piece has a clear scope
 - Changes in one area don't accidentally affect another
 - New engineers can reason about each piece independently

 **The story:**
 *"When I fixed the Bluetooth troubleshooter flow at Garmin, the existing code mixed device-pairing
 logic, UI state, and error-message formatting all in one massive class. Debugging it was painful
 because a change to how we displayed an error could accidentally affect the actual pairing logic.
 I split it into a pairing service, a state machine for troubleshooting steps, and a separate
 presenter for error messages. After that, fixing a CTKD pairing bug didn't risk breaking the UI,
 and the next person who touched that code could reason about each piece independently."*

 **Before — everything in one class:**

 ```
 class BluetoothTroubleshooterVC {
     // pairing logic + UI state + error formatting — all tangled
     func startPairing() { ... }
     func updateUI() { ... }
     func formatError(_ code: Int) -> String { ... }
 }
 ```

 **After — single responsibility per type:**

 ```
 class PairingService         { func startPairing() { ... } }
 class TroubleshooterState    { var currentStep: Step ... }
 class ErrorPresenter         { func message(for code: Int) -> String { ... } }
 class BluetoothTroubleshooterVC {
     // only wires the three pieces together
 }
 ```

 ---

 ### 3. Separation of Concerns / Composition — PayPal Accessibility Components

 **The principle:** Different responsibilities belong in different layers. Shared behavior
 should be composed in, not duplicated — so one change propagates everywhere.

 **Why it matters:**
 - Updating a shared component once fixes all adopters
 - Teams stay unblocked — they opt into behavior without understanding internals
 - Avoids hunting through dozens of screens when requirements change

 **The story:**
 *"At PayPal, I built shared accessibility components for dynamic font scaling and screen readers
 that multiple teams adopted. Instead of baking accessibility logic into each individual view, I
 built it as composable modifiers and protocols that any view could opt into. That let different
 teams apply consistent accessibility behavior without duplicating code, and it meant when
 accessibility guidelines changed, we updated the shared component once instead of hunting through
 dozens of screens."*

 **Example — composable accessibility modifier:**

 ```
 struct AccessibleText: ViewModifier {
     func body(content: Content) -> some View {
         content
             .dynamicTypeSize(.xSmall ... .accessibility3)
             .accessibilityAddTraits(.isStaticText)
     }
 }

 extension View {
     func accessibleText() -> some View {
         modifier(AccessibleText())
     }
 }

 // Any team can now opt in with one line:
 Text("Balance: $500").accessibleText()
 ```

 ---

 ## General Behavioral Framework (STAR)

 Use this for any behavioral question:

 1. **Situation** — Set the context briefly (team, product, constraint)
 2. **Task** — What was your specific responsibility?
 3. **Action** — What did *you* do? (use "I", not "we")
 4. **Result** — Measurable outcome, or what was learned

 ---

 ## Common Behavioral Questions & Angles

 **"Tell me about a time you disagreed with a teammate."**
 - Focus on the process: how you raised it, listened, and resolved it — not who was right.

 **"Tell me about a time you had to learn something quickly."**
 - Show curiosity + methodology: what you did to ramp up fast, how you applied it.

 **"Tell me about a technical decision you made that you'd do differently."**
 - Shows self-awareness. Pick something real but not catastrophic. End with what you learned.

 **"How do you handle ambiguous requirements?"**
 - Show that you ask clarifying questions early, prototype if needed, and align stakeholders before building.

 **"Tell me about a time you improved a process."**
 - Great for: CI/CD improvements, refactors that unblocked teams, shared tooling, documentation.

 ---

 ## Things to Weave In Naturally

 - **Ownership** — you drove it, you shipped it, you followed up
 - **Impact** — faster tests, fewer bugs, unblocked teams, reduced latency
 - **Collaboration** — worked across teams, reviewed others' code, mentored
 - **Trade-offs** — you considered alternatives and justified your choice
*/

//: [Next](@next)
