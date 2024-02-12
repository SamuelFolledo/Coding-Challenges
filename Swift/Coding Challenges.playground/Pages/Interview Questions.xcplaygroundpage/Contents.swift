//: [Previous](@previous)

import Foundation

/*
 Interview Question with James Fong from Apple's Health team on 2/12/2024
 
 Given an m x n 2D binary grid which represents a map of '1's (land) and '0's (water), return the number of islands.
 An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. You may assume all four edges of the grid are all surrounded by water.
 //
 Example 1:
 Input: grid = [
 [1,1,1,1,0],
 [1,1,0,1,0],
 [1,1,0,0,0],
 [0,0,0,0,0]
 ]
 Output: 1
 Example 2:
 Input: grid = [
 [1,1,0,0,0],
 [1,1,0,0,0],
 [0,0,1,0,0],
 [0,0,0,1,1]
 ]
 Output: 3
 */
func getNumberOfIslands(_ grid: [[Int]]) -> Int {
    var islandCounter = 0
    var grid2 = grid
    for x in 0..<grid.count {
        for y in 0..<grid2[x].count {
            let item = grid2[x][y]
            let isLand = item == 1
            if isLand {
                islandCounter += 1
                updateNeighbors(&grid2, x, y)
            }
        }
    }
    return islandCounter
}

func updateNeighbors(_ grid: inout [[Int]] , _ x: Int, _ y: Int) {
    //return if x or y is out of range OR item is water
    if x < 0 || x > grid.count - 1 || y < 0 || y > grid[x].count - 1 ||
        grid[x][y] == 0 {
        return
    }
    grid[x][y] = 0
    updateNeighbors(&grid, x-1, y)
    updateNeighbors(&grid, x+1, y)
    updateNeighbors(&grid, x, y-1)
    updateNeighbors(&grid, x, y+1)
}

let grid = [
    [1,1,1,1,0],
    [1,1,0,1,0],
    [1,1,0,0,0],
    [0,0,0,0,0]
] //Output: 1

let grid2 = [
    [1,1,0,0,0],
    [1,1,0,0,0],
    [0,0,1,0,0],
    [0,0,0,1,1]
] //Output: 3

print("Number of island for grid1 = \(getNumberOfIslands(grid))")
print("Number of island for grid2 = \(getNumberOfIslands(grid2))")

//: [Next](@next)
