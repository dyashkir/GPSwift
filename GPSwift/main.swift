//
//  main.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation



var functionArray = [(Double, Double)->Double]()
var leafs = [()->Double]()

functionArray.append(+)
functionArray.append(-)
functionArray.append(*)
functionArray.append(min)
functionArray.append(max)

func constF(c:Double) -> ()->Double{
    func f()->Double{
        return c
    }
    return f
}
leafs.append(constF(c: 0.1))
leafs.append(constF(c: 0.2))
leafs.append(constF(c: 0.3))
leafs.append(constF(c: 0.4))

func fitness(program: ProgramTreeNode)-> Double{
    let result = run.evalProgram(root: program)
    return abs(2.0-result)
}

let run = GPRun(functionArray: functionArray, leafs: leafs, fitness: fitness)

var generation = run.buildGeneration(size: 1000)

for i in 0..<generation.count {
    generation[i].score = fitness(program: generation[i].prg)
}

generation.sort(by: {a,b in
    return a.score<b.score
})

let maxPrg = generation[0]
print(" \(generation[0])")

print("Target is 2.0")
print("Best is \(run.evalProgram(root: maxPrg.prg))")





