//: [Previous](@previous)

import Foundation

/*:
 # Fanatics Prep — Day 2 (as actually run): System Design + Domain Modeling in Swift

 **CORRECTED 2026-08-27.** This page previously guessed Round 2 was a SwiftUI-with-AI-assistance build.
 That guess was wrong. What actually happened: a **system-design + coding round, no UI needed**,
 two parts — sketch the design on a drawing tab, then implement a plain-Swift, in-memory domain model.
 The real prompt (verbatim):

 > You pull into a busy parking lot. At the entrance you're handed a ticket. You drive in, find a spot
 > that fits your vehicle, and park. When you come back, you present the ticket at the exit, the system
 > works out what you owe, and your spot goes back into circulation. Behind the scenes, the system is
 > matching vehicles to spots by size, recording when each vehicle arrived and left, and keeping
 > availability current for everyone still driving in. Design and build that system.
 > Scope: a domain model in plain Swift. No UI, no database, no real payment processing. Everything in
 > memory.

 This is a classic **object-oriented design (OOD)** interview format — Parking Lot, Elevator, Vending
 Machine, Library System are the well-known family. The evaluation axis is: do you model entities with
 the right semantics (value vs. reference), do you handle the edge cases the prompt implies without being
 told explicitly (rejection, availability, pricing), and do you keep the API small and honest.

 ## Contents
 - Part 1: Postmortem on the attempted solution — the mistakes, and why they're the same lesson as
   Round 1's `rawValue`/`id` bug
 - Part 2: The design
 - Part 3: The implementation
 - Part 4: Demo / usage
 - Part 5: Questions that should've been asked — interviewer vs. AI
 - Part 6: The general OOD checklist — for the next one of these, if there is one

 ---

 ## Part 1: Postmortem on the attempted solution

 The first attempt got tripped up on **mechanics**, not the actual hard part of the problem:

 1. `Spot.enter`/`.exit` weren't marked `mutating` on a `struct` — doesn't compile as written.
 2. `.now()` — `Date.now` is a static *property*, not a callable method.
 3. `sizeType` was commented out on `Spot` but referenced elsewhere (`spot.sizeType`) — dangling
    reference.
 4. `for spot in spots` where `spots: [SizeType: [Spot]]` iterates dictionary `(key, value)` tuples, not
    individual `Spot`s.
 5. **The real lesson, and it's the exact same shape as Round 1's `rawValue`-instead-of-`id` bug just in
    a different costume:** a spot that needs to be "the same object, mutated in place, visible from
    everywhere that holds a reference to it" needs **reference semantics**. Storing `Spot` as a `struct`
    inside a `[SizeType: [Spot]]` means any spot pulled out via iteration is a **copy** — mutating it
    never writes back into the stored array. This is an identity bug, structurally identical to using a
    `rawValue` where a stable `id` was needed: both are "the type doesn't actually give you a stable
    handle on the thing you're trying to track."
 6. **No `Ticket` type at all** — the prompt is explicit that a ticket is handed out at entry and
    presented at exit. Without it, there's no way to know which spot a returning vehicle belongs to,
    especially with two same-size vehicles parked at once.
 7. **No pricing logic** — the actual "what do they owe" requirement was never implemented.
 8. **No rejection for "this lot doesn't have that size category at all"** — and `exitParking` was left
    unfinished, which compounds with #5/#6 (there was no working way to find the right spot regardless).

 None of this reflects an inability to reason about the problem — the value-type/mutation trap ate the
 time budget before the parts that actually score points (pricing, tickets, rejection) got built. Good
 thing to know about your own failure mode under pressure: **lock down value-vs-reference semantics for
 anything with identity in the first 60 seconds, before writing any logic that depends on it.**

 ---

 ## Part 2: The design

 ```
 Vehicle         — id, size                                    (struct — plain data)
 ParkingSpot     — id, size, occupiedBy: UUID?                  (class — needs identity/shared mutation)
 Ticket          — id, vehicleID, spotID, entryTime             (struct — immutable record)
 PricingStrategy — protocol, cost(for:duration:)                (protocol-first — swappable, testable)
 ParkingLot      — owns spots grouped by size + active tickets; enter()/exit() are the only entry points
 ```

 **Entry:** `enter(vehicle)` → does the lot have this size category at all? (if not, reject) → find a
 same-size spot that's free (if none, reject — "full," a distinct case from "unsupported size") → occupy
 it → mint a `Ticket` → hand it back.

 **Exit:** `exit(ticket)` → look up the spot the ticket points to → compute
 `pricing.cost(size, duration)` → free the spot → invalidate the ticket (so it can't be replayed).

 The `ParkingLot` never exposes `ParkingSpot` directly to callers — only `Ticket`s and fees — which keeps
 the "spot" concept an internal implementation detail, the same instinct as protocol-first networking
 layers from the original Day 2 draft: hide the mutable internals behind a small, intention-revealing API.

 ---

 ## Part 3: The implementation
*/

enum VehicleSize {
    case small, medium, large
}

struct Vehicle {
    let id = UUID()
    let size: VehicleSize
}

// A ticket is the actual contract handed to the driver — it's the thing presented at exit, not an
// internal bookkeeping detail invented after the fact. Modeling it explicitly is what the prompt is
// describing literally, and it's what the attempted solution skipped.
struct Ticket {
    let id = UUID()
    let vehicleID: UUID
    let spotID: UUID
    let entryTime: Date
}

// Reference type on purpose: multiple parts of the system need to observe the SAME spot flip from
// available to occupied, not an independent copy — see Part 1, mistake #5.
final class ParkingSpot {
    let id = UUID()
    let size: VehicleSize
    private(set) var occupiedBy: UUID?   // vehicle id; nil when free

    init(size: VehicleSize) {
        self.size = size
    }

    var isAvailable: Bool { occupiedBy == nil }

    func occupy(vehicleID: UUID) { occupiedBy = vehicleID }
    func vacate() { occupiedBy = nil }
}

enum ParkingError: Error, Equatable {
    case unsupportedVehicleSize(VehicleSize)   // the lot has no spots of this size category at all
    case noAvailableSpot(VehicleSize)          // the size exists, but every spot is currently occupied
    case invalidTicket                         // unknown, or already used to exit once already
}

extension ParkingError: CustomStringConvertible {
    var description: String {
        switch self {
        case .unsupportedVehicleSize(let size): "This lot has no \(size) spots."
        case .noAvailableSpot(let size): "No available \(size) spots right now."
        case .invalidTicket: "This ticket isn't valid — already used, or not recognized."
        }
    }
}

// Protocol-first: an interviewer can ask "how would you change the rate structure" and the answer is
// "swap the strategy," not "rewrite ParkingLot" — the same reason the networking layer earlier in this
// prep pack is built behind a protocol.
protocol PricingStrategy {
    func cost(for size: VehicleSize, duration: TimeInterval) -> Double
}

struct HourlyPricing: PricingStrategy {
    let ratesPerHour: [VehicleSize: Double]

    func cost(for size: VehicleSize, duration: TimeInterval) -> Double {
        let rate = ratesPerHour[size] ?? 0
        // Round UP to the next full hour — any partial hour bills as a full hour, the common
        // real-world convention. Worth saying out loud as an assumption, not a silent choice
        // (Part 5 — this is exactly the kind of thing to ask about instead of guessing).
        let hours = max(1, Int(ceil(duration / 3600)))
        return rate * Double(hours)
    }
}

final class ParkingLot {
    private var spotsBySize: [VehicleSize: [ParkingSpot]]
    private var activeTickets: [UUID: Ticket] = [:]
    private let pricing: PricingStrategy

    init(spotsBySize: [VehicleSize: [ParkingSpot]], pricing: PricingStrategy) {
        self.spotsBySize = spotsBySize
        self.pricing = pricing
    }

    func availableCount(for size: VehicleSize) -> Int {
        (spotsBySize[size] ?? []).filter(\.isAvailable).count
    }

    func enter(_ vehicle: Vehicle, at time: Date = .now) throws -> Ticket {
        guard let candidateSpots = spotsBySize[vehicle.size], !candidateSpots.isEmpty else {
            throw ParkingError.unsupportedVehicleSize(vehicle.size)
        }
        guard let freeSpot = candidateSpots.first(where: \.isAvailable) else {
            throw ParkingError.noAvailableSpot(vehicle.size)
        }

        freeSpot.occupy(vehicleID: vehicle.id)
        let ticket = Ticket(vehicleID: vehicle.id, spotID: freeSpot.id, entryTime: time)
        activeTickets[ticket.id] = ticket
        return ticket
    }

    @discardableResult
    func exit(ticket: Ticket, at time: Date = .now) throws -> Double {
        guard activeTickets[ticket.id] != nil else {
            throw ParkingError.invalidTicket
        }
        guard let spot = allSpots.first(where: { $0.id == ticket.spotID }) else {
            throw ParkingError.invalidTicket
        }

        let fee = pricing.cost(for: spot.size, duration: time.timeIntervalSince(ticket.entryTime))
        spot.vacate()
        activeTickets.removeValue(forKey: ticket.id)   // ticket can't be replayed to exit twice
        return fee
    }

    private var allSpots: [ParkingSpot] {
        spotsBySize.values.flatMap { $0 }
    }
}

/*:
 ---

 ## Part 4: Demo / usage
*/

let lot = ParkingLot(
    spotsBySize: [
        .small: [ParkingSpot(size: .small), ParkingSpot(size: .small)],
        .medium: [ParkingSpot(size: .medium)],
        .large: []   // deliberately empty — demonstrates the "unsupported size" rejection
    ],
    pricing: HourlyPricing(ratesPerHour: [.small: 2, .medium: 3, .large: 5])
)

do {
    let car = Vehicle(size: .small)
    let ticket = try lot.enter(car, at: Date().addingTimeInterval(-2.5 * 3600))   // "arrived" 2.5h ago
    print("Available small spots after entry:", lot.availableCount(for: .small))  // 1

    let fee = try lot.exit(ticket: ticket)
    print("Fee owed:", fee)                                                       // 3 hours -> 6.0
    print("Available small spots after exit:", lot.availableCount(for: .small))   // 2
} catch {
    print("Unexpected error:", error)
}

do {
    let truck = Vehicle(size: .large)
    _ = try lot.enter(truck)
} catch let error as ParkingError {
    print("Rejected as expected:", error.description)
}

do {
    // Fill both small spots, then a third small vehicle should be rejected as "full," a distinct
    // case from "unsupported size" above.
    let smallLot = ParkingLot(
        spotsBySize: [.small: [ParkingSpot(size: .small)]],
        pricing: HourlyPricing(ratesPerHour: [.small: 2])
    )
    _ = try smallLot.enter(Vehicle(size: .small))
    _ = try smallLot.enter(Vehicle(size: .small))
} catch let error as ParkingError {
    print("Rejected as expected:", error.description)
}

/*:
 ---

 ## Part 5: Questions that should've been asked — interviewer vs. AI

 **To the interviewer, before writing any code** (all cheap, all would've shaped the design in ways that
 are hard to retrofit later):

 1. **"Can a smaller vehicle park in a larger spot if its own size is full, or is it strict same-size
    matching only?"** — the prompt is ambiguous here, and the answer changes the spot-selection logic
    materially (a fallback search vs. an exact lookup).
 2. **"Is pricing a flat per-hour rate per size, or something with a minimum charge / grace period?"** —
    "how much they'll be charged" was explicit in the prompt; the *shape* of that pricing wasn't.
 3. **"Do partial hours round up, round down, or bill per-minute?"** — a real, easy-to-get-wrong
    assumption (this solution rounds up, and says so explicitly rather than silently).
 4. **"Does 'the parking lot doesn't have the size type it requires' mean the lot was never configured
    with that category, or does it also cover 'currently zero available, even though the category
    exists'?"** — these are genuinely two different rejection reasons (`unsupportedVehicleSize` vs.
    `noAvailableSpot` above), and the prompt's wording plausibly means either.
 5. **"Do we need thread-safety, or is single-threaded in-memory enough for this exercise?"** — worth
    asking once, out loud, then explicitly *not* building for it if the answer is no — over-engineering
    a scope-capped exercise is its own red flag.
 6. **"Should the set of spots be fixed at construction, or does the design need to support adding/
    removing spots later?"** — changes whether `spotsBySize` needs to be mutable at the `ParkingLot`
    level beyond just occupancy.

 **To the AI tool, if one was available** (these are prompts that front-load the identity/mutation
 decision instead of discovering it the hard way mid-solution):

 - *"I'm modeling a parking spot that needs to be found, mutated (occupied/freed), and have that mutation
   visible everywhere it's referenced — struct or class, and why?"* — asked **before** writing `Spot`,
   this alone would have prevented every downstream bug in Part 1.
 - *"Review this domain model against the prompt — does anything in the prompt imply a type I haven't
   modeled yet?"* — a ticket-shaped gap is exactly the kind of thing this catches, since "you're handed a
   ticket... present the ticket at the exit" is stated almost verbatim in the prompt.
 - *"Check this for compile errors before I consider it done"* — cheap, and would have caught the
   `mutating`/`.now()`/dangling-`sizeType` issues immediately rather than losing time to them live.
 - *"Generate the edge-case tests for this: full lot, wrong size rejected, exact-hour billing boundary,
   double-exit on the same ticket"* — a good closing move once the core model exists, and directly
   demonstrates the "testability" instinct the JD calls out (Day 0, Part 3).

 ---

 ## Part 6: The general OOD checklist — for the next one of these

 Parking Lot, Elevator System, Vending Machine, Library/Book-Lending System, Ride-Sharing Matcher — all
 the same family, all gradable the same way:

 - [ ] **Identify anything with identity/shared mutable state first** (a spot, an elevator car, a book
       copy) — that's a `class`, before anything else gets written.
 - [ ] **Find the "receipt" object the prompt implies but doesn't name outright** — a ticket, a
       reservation, a loan record — these decouple "the thing that happened" from "the resource it
       happened to," and are usually the actual point of the exercise.
 - [ ] **Separate "doesn't exist" from "exists but unavailable"** as distinct error cases — almost every
       one of these prompts has both, even when only one is stated explicitly.
 - [ ] **Keep the pluggable part behind a protocol** (pricing here; could be a matching strategy, a
       notification policy, etc. in other variants) — cheap to add, and it's a free "how would you
       change X" answer for follow-ups.
 - [ ] **Ask the 2–3 genuinely ambiguous questions before coding**, don't guess silently — Part 5 above
       is the template.

 [↑ Back to Top](#top)
*/

//: [Next](@next)
