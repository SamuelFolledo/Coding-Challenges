//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"

//MARK: - Fake notification center tests
class FakeNotification {
    typealias Block = (()->Void)
    var dic = [String: [Block]]()

    ///Better queue for this case to handle at the same time with other things
    let concurrentQueue = DispatchQueue(label: "concurrent", attributes: [.concurrent])

    func add(_ name: String, block: @escaping Block) {
        //Other options outside of concurrent queue to ensure we're adding correctly is NSMapTable and ObjectIdentifier
        concurrentQueue.async {
            if self.dic[name] != nil {
                self.dic[name]?.append(block)
            } else {
                self.dic[name] = [block]
            }
        }
    }

    func post(_ name: String) {
        if let blocks = dic[name] {
            blocks.forEach { $0() }
        }
    }
}

let notificationCenter = FakeNotification()
notificationCenter.add("sam", block: {
    for i in 1...5 {
        print(i)
    }
})

notificationCenter.add("sam", block: {
    for i in 1...5 {
        print(i + 10)
    }
})

notificationCenter.add("sam2", block: {
    for i in 1...5 {
        print(i + 1000)
    }
})

notificationCenter.post("sam")


//MARK: - Concurrent Queue vs Serial Queue tests
///One after another type of a queue
let serialQueue = DispatchQueue(label: "serialQueue")

///Better queue for this case to handle at the same time with other things
///- Ensures only one thing is writing or reading
///- Guarantees it finishes the execution
let concurrentQueue = DispatchQueue(label: "concurrent", attributes: [.concurrent])
//serialQueue.async {
//    for i in 1...5 {
//        print(i)
//    }
//}
//serialQueue.async {
//    for i in 1...5 {
//        print(i + 10)
//    }
//}
//concurrentQueue.async {
//    for i in 1...5 {
//        print(i + 1000)
//    }
//}

//MARK: -  Interview 2

//Questions
//1. What is the output on current count and new count
//2. How can we change it to output what we expect, which is 6
class CountTracker {
    var count: Int = 0

    lazy var increaseValue: Void = {
        print("UPDATE: Current count: \(count)")
        increment()
        print("UPDATE: New count: \(count)")
    }()

    func increment() {
        count += 1
        count += 1
    }
}

let tracker = CountTracker()
print("Current count: \(tracker.count)")
var increaseValue: Void = tracker.increaseValue
increaseValue = tracker.increment()
increaseValue = tracker.increment()
print("New count: \(tracker.count)")

print("")
//MARK: Part 2:
//Questions
//Update the track method code to print a log message where it prints the method and File name of file and function from where it is being used/called.
protocol LoggingHelper {
    func track(functionName: String, fileName: String)
}

extension LoggingHelper {
    func track(functionName: String = #function, fileName: String = #file) {
        print("Function name \(functionName) is in \(fileName)")
    }
}

class MyClassA : LoggingHelper {
    func function_X() {
        track()
        // Some other Biz logic
    }

    func function_Y() {
        track()
        // Some other Biz logic
    }
}

class MyClassB : LoggingHelper {
    func function_P() {
        track()
        // Some other Biz logic
    }

    func function_Q() {
        track()
        // Some other Biz logic
    }
}

let objectA = MyClassA()
let objectB = MyClassB()

objectA.function_X()
objectB.function_P()
objectA.function_Y()
objectB.function_Q()

//: [Next](@next)
