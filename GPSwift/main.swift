//
//  main.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation

//data

func readFile() -> String {
    
    let path = "/Users/dyashkir/ios/GPSwift/mnist_train_100.csv"
    do {
        
        let text = try String(contentsOfFile: path)
        return text
    }catch{
        fatalError()
    }
}

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
            let error = (t.1-result)
            score += pow(error/t.1, 2.0)
            
        })
        
        return score
    }
}
struct CubeTrainer : GPTrainer{
    
    let train = [(1.0, 1.0), (2.0, 8.0), (3.0, 27.0), (10.0, 1000.0)]
    
    func fitness(forProgram: ProgramTreeNode, eval: (ProgramTreeNode) -> Double, leafs: [Leaf]) -> Double {
        var score = 0.0
        train.forEach({ t in
            leafs[0].value = t.0
            let result = eval(forProgram)
            let error = (t.1-result)
            score += pow(error/t.1, 2.0)
        })
        return score
    }
}

NSLog(readFile())

let sq = SquareTrainer()
let ct = CubeTrainer()

var run = GPRun(functions: functionArray, leafs: leafs, trainer: sq, initialDepth: 4, numberOfGenerations: 10)
run.start()

let maxPrg = run.currentGeneration?[0]

print("Best for square is:")

print(String(describing: maxPrg))
sq.train.forEach {a in
    leafs[0].value = a.0
    let res = run.evalProgram(root: (maxPrg?.prg)!)
    print("x: \(a.0) result: \(res)")
}

var runCube = GPRun(functions: functionArray, leafs: leafs, trainer: ct, initialDepth: 4, numberOfGenerations: 10)
runCube.start()

let maxPrgCt = runCube.currentGeneration?[0]

print("Best for Cube is:")

print(String(describing: maxPrgCt))
ct.train.forEach {a in
    leafs[0].value = a.0
    let res = runCube.evalProgram(root: (maxPrgCt?.prg)!)
    print("x: \(a.0) result: \(res) expected: \(a.1)")
}
