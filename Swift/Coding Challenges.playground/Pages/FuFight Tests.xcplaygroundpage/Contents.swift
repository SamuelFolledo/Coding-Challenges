//: [Previous](@previous)

import Foundation

enum MoveButtonState: Int {
    case initial = 0
    case unselected = 1
    case selected = 2
    case cooldown = 3
}

protocol MoveProtocol: Hashable {
    var name: String { get }
    var id: String { get }
    ///Move's cooldown
    var cooldown: Int { get }
    var currentCooldown: Int { get set }
    var state: MoveButtonState { get set }

    mutating func reduceCooldown()
    mutating func setState(_ newState: MoveButtonState)
}

extension MoveProtocol {
    var state: MoveButtonState {
        get { return state }
        set { self.state = newValue }
    }
    var currentCooldown: Int {
        get { return currentCooldown }
        set { self.currentCooldown = newValue }
    }

    mutating func reduceCooldown() {
        currentCooldown -= 1
        if currentCooldown == 0 {
            setState(.initial)
        }
    }

    mutating func setState(_ newState: MoveButtonState) {
        print("State for \(id) is now \(newState)")
        if !(nil ?? true) { //will not go in
            print("IM IN")
        }
        state = newState
        switch newState {
        case .cooldown:
            currentCooldown = cooldown
        case .unselected, .selected:
            break
        case .initial:
            if currentCooldown != 0 {
                currentCooldown = 0
            }
        }
    }
}

fileprivate extension MoveProtocol {
    mutating func defaultReduceCooldown() {
        currentCooldown -= 1
        if currentCooldown == 0 {
            setState(.initial)
        }
    }

    mutating func defaultSetState(_ newState: MoveButtonState) {
        print("State for \(id) is now \(newState)")
        state = newState
        switch newState {
        case .cooldown:
            currentCooldown = cooldown
        case .unselected, .selected:
            break
        case .initial:
            if currentCooldown != 0 {
                currentCooldown = 0
            }
        }
    }
}

protocol AttackProtocol {
    ///The base damage of this attack
    var damage: Double { get }
    ///How fast this attack is and will determine who goes first
    var speed: Double { get }
    ///The percentage amount of damage reduction this attack will apply to the enemy. 1 will not reduce any attack, 0 will fully remove the damage of the next attack
    var damageReduction: Double { get }
    ///Returns true if attack can increase next attack's damage. If true, these attacks can be slightly boosted indicated with small fire
    var canBoost: Bool { get }
}

protocol DefendProtocol: MoveProtocol {
    ///The percentage amount of damage boost this move adds to attack's damage. 1 is default and 0 means no additional damage increase from this DefendProtocol move
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed. 1 is default and means no additional speed increase
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage. 1 is default and means no additional damage reduction. In `0 > x > 1 > y`. In x, meaning values between 0 and 1, will reduce incoming damage. In y, meaning values over 1, will increase incoming damage (e.g. dash forward move)
    var incomingDamageMultiplier: Double { get }
}

protocol AttackTypeProtocol: CaseIterable {

}

enum PunchType: String, CaseIterable {
    case leftPunchLight
    case leftPunchMedium
    case leftPunchHard
    case rightPunchLight
    case rightPunchMedium
    case rightPunchHard
}

//MARK: - MoveProtocol extension
extension PunchType {
    var id: String {
        rawValue
    }

    var name: String {
        rawValue
    }

    var cooldown: Int {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            1
        case .leftPunchMedium, .rightPunchMedium:
            2
        case .leftPunchHard, .rightPunchHard:
            3
        }
    }
}

//MARK: - AttackProtocol extension
extension PunchType {
    var damage: Double {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            10
        case .leftPunchMedium, .rightPunchMedium:
            15
        case .leftPunchHard, .rightPunchHard:
            25
        }
    }

    var speed: Double {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            50
        case .leftPunchMedium, .rightPunchMedium:
            35
        case .leftPunchHard, .rightPunchHard:
            25
        }
    }

    var damageReduction: Double {
        switch self {
        case .leftPunchLight, .rightPunchLight:
            0.85
        case .leftPunchMedium, .rightPunchMedium:
            0.75
        case .leftPunchHard, .rightPunchHard:
            0.65
        }
    }

    var canBoost: Bool {
        switch self {
        case .leftPunchLight, .rightPunchLight, .rightPunchMedium:
            true
        case .leftPunchMedium, .leftPunchHard, .rightPunchHard:
            false
        }
    }
}

class Attack: AttackProtocol, MoveProtocol {
//    mutating func setState(_ newState: MoveButtonState) {
//        defaultSetState(newState)
//    }
//    
//    mutating func reduceCooldown() {
//        defaultReduceCooldown()
//    }
    
    var name: String { type.name }

    var id: String { type.rawValue }

    var cooldown: Int { type.cooldown }

    var damage: Double { type.damage }

    var speed: Double { type.speed }

    var damageReduction: Double { type.damageReduction }

    var canBoost: Bool { type.canBoost }

    var type: PunchType

    init(type: PunchType) {
        self.type = type
    }

//    override func setState(_ newState: MoveButtonState) {
//        super.setState(newState)
//        print("Done setting state")
//    }
//
//    override func reduceCooldown() {
//        super.reduceCooldown()
//        print("Done reducing cd")
//    }
}

extension Attack {
    static func == (lhs: Attack, rhs: Attack) -> Bool {
        return lhs.type.id == lhs.type.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(type.id)
    }
}


var attack = Attack(type: .leftPunchHard)
attack.setState(.cooldown)

//: [Next](@next)
