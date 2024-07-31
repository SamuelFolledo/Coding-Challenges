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
}

protocol MoveObjectProtocol: MoveProtocol {
    var currentCooldown: Int { get set }
    var state: MoveButtonState { get set }

    mutating func reduceCooldown()
    mutating func setState(_ newState: MoveButtonState)
}

class Move: MoveObjectProtocol {
    var name: String
    var id: String
    var cooldown: Int
    var currentCooldown: Int
    var state: MoveButtonState

    var isAttack: Bool

    init(_ attackType: PunchType) {
        self.name = attackType.name
        self.id = attackType.id
        self.cooldown = attackType.cooldown
        self.isAttack = true
        self.currentCooldown = 0
        self.state = .initial
    }

    static func == (lhs: Move, rhs: Move) -> Bool {
        return lhs.id == lhs.id
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    //MARK: Move Protocol Methods

    func reduceCooldown() {
        currentCooldown -= 1
        if currentCooldown == 0 {
            setState(.initial)
        }
    }

    func setState(_ newState: MoveButtonState) {
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

protocol AttackProtocol: MoveProtocol {
    ///The base damage of this attack
    var damage: Double { get }
    ///How fast this attack is and will determine who goes first
    var speed: Double { get }
    ///The percentage amount of damage reduction this attack will apply to the enemy. 1 will not reduce any attack, 0 will fully remove the damage of the next attack
    var damageReduction: Double { get }
    ///Returns true if attack can increase next attack's damage. If true, these attacks can be slightly boosted indicated with small fire
    var canBoost: Bool { get }
    var position: AttackPosition { get }
}

protocol AttackObjectProtocol: AttackProtocol {

}

protocol DefendProtocol: MoveProtocol {
    ///The percentage amount of damage boost this move adds to attack's damage. 1 is default and 0 means no additional damage increase from this DefendProtocol move
    var damageMultiplier: Double { get }
    ///The percentage amount of speed boost this move adds to attack's speed. 1 is default and means no additional speed increase
    var speedMultiplier: Double { get }
    ///The percentage amount of defense boost this move reduces from incoming damage. 1 is default and means no additional damage reduction. In `0 > x > 1 > y`. In x, meaning values between 0 and 1, will reduce incoming damage. In y, meaning values over 1, will increase incoming damage (e.g. dash forward move)
    var incomingDamageMultiplier: Double { get }
}

enum PunchType: String, CaseIterable, AttackProtocol {
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

    var position: AttackPosition {
        switch self {
        case .leftPunchLight:
                .leftLight
        case .leftPunchMedium:
                .leftMedium
        case .leftPunchHard:
                .leftHard
        case .rightPunchLight:
                .rightLight
        case .rightPunchMedium:
                .rightMedium
        case .rightPunchHard:
                .rightHard
        }
    }
}

enum AttackPosition: Int {
    case leftLight = 1
    case rightLight = 2
    case leftMedium = 3
    case rightMedium = 4
    case leftHard = 5
    case rightHard = 6

    var isLeft: Bool {
        return rawValue % 2 == 1
    }
}

class Attack: Move, AttackProtocol {
    //MARK: AttackProtocol
//    var damage: Double { type.damage }
//    var speed: Double { type.speed }
//    var damageReduction: Double { type.damageReduction }
//    var canBoost: Bool { type.canBoost }
    private(set) var damage: Double
    private(set) var speed: Double
    private(set) var damageReduction: Double
    private(set) var canBoost: Bool
    private(set) var position: AttackPosition

    override init(_ type: PunchType) {
        self.damage = type.damage
        self.speed = type.speed
        self.damageReduction = type.damageReduction
        self.canBoost = type.canBoost
        self.position = type.position
        super.init(type)
    }
}

var attacks: [Attack] = PunchType.allCases.map { Attack($0) }
//print("ATTACKS \(attacks.count)")

//var attack = Attack(.leftPunchHard)
//attack.setState(.cooldown)
//print(attack.currentCooldown)
//attack.reduceCooldown()
//print(attack.currentCooldown)

struct Moves {
    var attacks: [Attack]
    var leftLightAttack: Attack
    var rightLightAttack: Attack
    var leftMediumAttack: Attack
    var rightMediumAttack: Attack
    var leftHardAttack: Attack
    var rightHardAttack: Attack

    init(attacks: [Attack]) {
        self.attacks = attacks
        self.leftLightAttack = attacks.first { $0.position == .leftLight }!
        self.rightLightAttack = attacks.first { $0.position == .rightLight }!
        self.leftMediumAttack = attacks.first { $0.position == .leftMedium }!
        self.rightMediumAttack = attacks.first { $0.position == .rightMedium }!
        self.leftHardAttack = attacks.first { $0.position == .leftHard }!
        self.rightHardAttack = attacks.first { $0.position == .rightHard }!
    }

    func reduceCd(_ position: AttackPosition) {
        let attack = attacks.first(where: { $0.position == position })!
        print("Attack \(attack.name) cd is currently \(attack.currentCooldown)")
        attack.reduceCooldown()
        print("Attack \(attack.name) is now \(attack.currentCooldown)")
    }
}

var moves = Moves(attacks: attacks)
print("Available moves \(moves.attacks.filter { $0.state != .cooldown }.count)")
moves.attacks.first { $0.position == .rightHard }!.setState(.cooldown)
moves.attacks.first { $0.position == .leftHard }!.setState(.cooldown)
print("Available moves \(moves.attacks.filter { $0.state != .cooldown }.count)")
//moves.reduceCd(.rightHard)
//print(moves.rightHardAttack.currentCooldown)
moves.reduceCd(.rightHard)
print(moves.rightHardAttack.currentCooldown)
moves.rightHardAttack.reduceCooldown()
moves.rightHardAttack.reduceCooldown()
//moves.rightHardAttack.reduceCooldown()
print("Available moves \(moves.attacks.filter { $0.state != .cooldown }.count)")

moves.attacks.removeAll()
print("Available moves \(moves.attacks.filter { $0.state != .cooldown }.count)")
print(moves.rightHardAttack.currentCooldown)
//: [Next](@next)
