//
//  main.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation

//data

func readFile(path: String) -> String {
    
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
func division(a:Double, b:Double) ->Double {
    if b != 0.0 {
        return a/b
    }else{
        return a
    }
}
functionArray.append((division, "/"))
//functionArray.append((min, "min"))
//functionArray.append((max, "max"))

var leafs = [Leaf]()


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

let trainingCSV = readFile(path: "/Users/dyashkir/ios/GPSwift/mnist_train_100.csv")

var lines = trainingCSV.components(separatedBy: "\n").map( { a in
    return a.components(separatedBy: ",")
})

lines = Array(lines[0..<(lines.count-1)])

for i in 0..<lines[0].count-1 {
    leafs.append(Leaf())
}

struct NumbersTrainer : GPTrainer {
   
    var train = [(Int, [Double])]()
    
    func fitness(forProgram: ProgramTreeNode, eval: (ProgramTreeNode) -> Double, leafs: [Leaf]) -> Double {
       var score = 0.0
        train.forEach({ t in
            let target = t.0
            for i in 0..<t.1.count {
                leafs[i].value = t.1[i]
            }
            
            let result = eval(forProgram)
            let error = (Double(target)-result)
            score += pow(error, 2.0)
        })
        return score
    }
}

var nt = NumbersTrainer()

func CSVNumbersDataParseLine(line: [String]) -> (Int, [Double]) {
    let dd = line[1..<line.count].map { b in
        return Double(b)!/255.0
    }
    let r = (Int(line[0])!, dd)
    return r
}
nt.train = lines.map(CSVNumbersDataParseLine)



var run = GPRun(functions: functionArray, leafs: leafs, trainer: nt, initialDepth: 8, numberOfGenerations: 100)
run.start()

let best = run.currentGeneration?[0]

//test
let testingCSV = readFile(path: "/Users/dyashkir/ios/GPSwift/mnist_test_10.csv")

var linesT = trainingCSV.components(separatedBy: "\n").map( { a in
    return a.components(separatedBy: ",")
})

linesT = Array(lines[0..<(lines.count-1)])
let test = linesT.map(CSVNumbersDataParseLine)

var testScore = 0.0
for t in test {
    let target = t.0
    for i in 0..<t.1.count {
        leafs[i].value = t.1[i]
    }
    
    let res = run.evalProgram(root: (best?.prg)!)
   
    if(abs(Double(t.0) - res) < 0.5){
        testScore += 1.0
    }
    NSLog("Expected: \(t.0) result: \(res)")
}

NSLog("Test Score: \(testScore)")

//NSLog("\(nt.train)")
/*
let sq = SquareTrainer()
let ct = CubeTrainer()

var run = GPRun(functions: functionArray, leafs: leafs, trainer: sq, initialDepth: 4, numberOfGenerations: 10)
run.start()

let maxPrg = run.currentGeneration?[0]

NSLog("Best for square is:")

NSLog(String(describing: maxPrg))
sq.train.forEach {a in
    leafs[0].value = a.0
    let res = run.evalProgram(root: (maxPrg?.prg)!)
    NSLog("x: \(a.0) result: \(res)")
}

var runCube = GPRun(functions: functionArray, leafs: leafs, trainer: ct, initialDepth: 4, numberOfGenerations: 10)
runCube.start()

let maxPrgCt = runCube.currentGeneration?[0]

NSLog("Best for Cube is:")

NSLog(String(describing: maxPrgCt))
ct.train.forEach {a in
    leafs[0].value = a.0
    let res = runCube.evalProgram(root: (maxPrgCt?.prg)!)
    NSLog("x: \(a.0) result: \(res) expected: \(a.1)")
}
*/
