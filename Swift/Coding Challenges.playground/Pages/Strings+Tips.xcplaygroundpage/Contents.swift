//: [Previous](@previous)

import Foundation

//--------------------------------------------------------------------------------------------------
print("String indexes!")
var greeting = "Hello, playground!"
print(greeting[greeting.startIndex])// H
print(greeting[greeting.index(before: greeting.endIndex)])// !
print(greeting[greeting.index(after: greeting.startIndex)]) // e
let index = greeting.index(greeting.startIndex, offsetBy: 7)
print(greeting[index]) // p

//--------------------------------------------------------------------------------------------------
print("\nInserting and Removing")
var welcome = "hello"
welcome.insert("!", at: welcome.endIndex) // "hello!"
print(welcome)
welcome.insert(contentsOf: " there", at: welcome.index(before: welcome.endIndex)) // "hello there!"
print(welcome)
welcome.remove(at: welcome.index(before: welcome.endIndex)) // "hello there"
print(welcome)

//remove given a range
let range = welcome.index(welcome.endIndex, offsetBy: -6)..<welcome.endIndex
welcome.removeSubrange(range) // "hello"
print(welcome)

//--------------------------------------------------------------------------------------------------
print("\nSubstrings")
let greeting2 = "Hello, world!"
let index2 = greeting2.firstIndex(of: ",") ?? greeting2.endIndex
//remove given a range
let beginning = String(greeting2[..<index2]) // beginning is "Hello"
print(beginning)

print("\(41 % 2)")
//: [Next](@next)
