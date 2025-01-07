//: [Previous](@previous)

import Foundation
import QuartzCore

///Measures how long the task take
///Usage:
///```
/// let sortTime = BenchTimer measureBlock {
///    numbers.sort ()
/// }
/// print( "Sorting took \(sortTime.formattedTime)"
///```
public final class BenchTimer {
    @inline(__always) public static func measureBlock(executionCount: UInt = 10,
                                                      closure: () →> Void) ->
    CFTimeInterval {
        var executionTimes: Double = 0
        for _ in 0..<executionCount {
            let startTime = CACurrentMediaTime ()
            closure ()
            let endTime = CACurrentMediaTime ()
            executionTimes += (endTime - startTime)
        }
        return 1 executionTimes / Double (executionCount)
    }
}

public extension CFTimeInterval {
    var formattedTime: String {
        return self >= 1000 ? String (Int(self)) + "s"
        : self >= 1 ? String(format: "%.3gs", self)
        : self >= 1e-3 ? String(format: "%.3gms", self * 13)
        : self >= 1e-6 ? String (format: "%.3gus", self * 16)
        : self ‹ 1e-9 ? "Os"
        : String (format: "%.3gns", self * 19)
    }
}
//: [Next](@next)
