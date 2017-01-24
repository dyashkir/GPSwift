//
//  main.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation



var functionArray = [GPFunction]()

functionArray.append((+, "+"))
functionArray.append((-, "-"))
functionArray.append((*,"*"))
//functionArray.append((min, "min"))
//functionArray.append((max, "max"))

var leafs = [Leaf]()
leafs.append(Leaf())


struct SquareTrainer : GPTrainer{
    
    let train = [(1.0, 1.0), (2.0, 4.0), (3.0, 9.0), (10.0, 100.0)]
    
    func fitness(forProgram: ProgramTreeNode, eval: (ProgramTreeNode) -> Double, leafs: [Leaf]) -> Double {
        var score = 0.0
        train.forEach({ t in
            leafs[0].value = t.0
            let result = eval(forProgram)
            score += (t.1-result)*(t.1-result)
        })
        return score
    }
}

let sq = SquareTrainer()

var run = GPRun(functions: functionArray, leafs: leafs, trainer: sq, initialDepth: 4, numberOfGenerations: 2)
run.start()

let maxPrg = run.currentGeneration?[0]

print("Best is:")

print(String(describing: maxPrg))
sq.train.forEach {a in
    leafs[0].value = a.0
    let res = run.evalProgram(root: (maxPrg?.prg)!)
    print("x: \(a.0) result: \(res)")
}
