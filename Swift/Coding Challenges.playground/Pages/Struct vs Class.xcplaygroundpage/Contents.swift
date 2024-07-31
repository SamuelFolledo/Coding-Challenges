//: [Previous](@previous)

import Foundation

enum FighterType: String {
    case samuel, clara

    var name: String {
        switch self {
        case .samuel:
            "Samuel"
        case .clara:
            "Clara"
        }
    }

    var bonesName: String {
        switch self {
        case .samuel:
            "Armature"
        case .clara:
            "Armature-001"
        }
    }

    var scale: Float {
        switch self {
        case .samuel:
            0.02
        case .clara:
            0.02
        }
    }
}


class FetchedPlayer {
    private(set) var username: String
    var fighterType: FighterType

    init(username: String, fighterType: FighterType) {
        self.username = username
        self.fighterType = fighterType
    }
}

let p1 = FetchedPlayer(username: "1", fighterType: .clara)
let p2 = p1
p2.fighterType = .samuel
print("P1 \(p1.fighterType) and \(p2.fighterType)")

//: [Next](@next)
