//
//  main.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation

typealias TrainTuple = (x:Double, y:Double)

let train : [TrainTuple] = [(1.0, 1.0), (2.0, 2.0), (3.0, 9.0), (10.0, 100.0)]

var functionArray = [GPFunction]()

functionArray.append((+, "+"))
functionArray.append((-, "-"))
functionArray.append((*,"*"))
functionArray.append((min, "min"))
functionArray.append((max, "max"))

var leafs = [Leaf]()
leafs.append(Leaf())

func fitness(program: ProgramTreeNode)-> Double{
    let result = run.evalProgram(root: program)
    return abs(2.0-result)
}

func fitnessX2(train:TrainTuple, program: ProgramTreeNode) ->Double{
    leafs[0].value = train.x
    let result = run.evalProgram(root: program)
    return abs(train.y-result)
}
let run = GPRun(functionArray: functionArray, leafs: leafs, fitness: fitness)

var generation = run.buildGeneration(size: 1000)

for i in 0..<generation.count {
    var score = 0.0
    for j in 0..<train.count{
         score += fitnessX2(train: train[j], program: generation[i].prg)
    }
    generation[i].score = score
}

generation.sort(by: {a,b in
    return a.score<b.score
})

let maxPrg = generation[0]
print(" \(generation[0])")

print("Target is 4.0")
print("Best is:")
train.forEach {a in
    leafs[0].value = a.x
    let res = run.evalProgram(root: maxPrg.prg)
    print("x: \(a.x) result: \(res)")
}





