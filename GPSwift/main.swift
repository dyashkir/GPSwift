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

let trainingCSV = readFile(path: "/Users/dyashkir/ios/GPSwift/mnist_train_100.csv")

var lines = trainingCSV.components(separatedBy: "\n").map( { a in
    return a.components(separatedBy: ",")
})

lines = Array(lines[0..<(lines.count-1)])

for i in 0..<lines[0].count-1 {
    leafs.append(Leaf())
}

struct NumbersTrainer : GPTrainer {
   
    var train : [(Int, [Double])]
    
    let targetNumber : Int
    
    func fitness(forProgram: ProgramTreeNode, eval: (ProgramTreeNode) -> Double, leafs: [Leaf]) -> Double {
       var score = 0.0
        train.forEach({ t in
            let target = t.0
            for i in 0..<t.1.count {
                leafs[i].value = t.1[i]
            }
            
            let result = eval(forProgram)
            var error = 1.0
            if target == targetNumber {
                if (result > 0){
                    error = 0.0
                }
            }else{
                if (result < 0){
                    error = 0.0
                }
            }
            score += error
        })
        return score
    }
}



func CSVNumbersDataParseLine(line: [String]) -> (Int, [Double]) {
    let dd = line[1..<line.count].map { b in
        return Double(b)!/255.0
    }
    let r = (Int(line[0])!, dd)
    return r
}

let trainSet = lines.map(CSVNumbersDataParseLine)
var trainers = [NumbersTrainer]()

for i in 0..<10{
    let trainer = NumbersTrainer(train: trainSet, targetNumber: i)
    trainers.append(trainer)
}

var runs = trainers.map { trainer in
    
    return GPRun(functions: functionArray, leafs: leafs, trainer: trainer, initialDepth: 5, numberOfGenerations: 5, tournamentSize : 9)
}
let best = runs.map { run -> IndividualProgram in
    
    var run = run
    run.start()
    let best = run.currentGeneration?[0]
    return best!
}


//test
let testingCSV = readFile(path: "/Users/dyashkir/ios/GPSwift/mnist_test_10.csv")

var linesT = testingCSV.components(separatedBy: "\n").map( { a in
    return a.components(separatedBy: ",")
})

linesT = Array(linesT[0..<(linesT.count-1)])
let test = linesT.map(CSVNumbersDataParseLine)

var testScore = 0.0
for t in test {
    let target = t.0
    for i in 0..<t.1.count {
        leafs[i].value = t.1[i]
    }
    
    let results = best.map { prg -> Double in
        let res = runs[0].evalProgram(root: (prg.prg))
        return res
    }
  
    var maxVal = 0.0
    var index = -1
    NSLog("Number is: \(t.0)")
    for i in 0..<results.count{
        if results[i] > maxVal {
            NSLog("\(results[i]) \(i)")
            maxVal = results[i]
            index = i
        }
    }
    
    NSLog("Expected: \(t.0) selected: \(index)")
    let res = index
    if t.0 == index {
        testScore += 1.0
    }
}
NSLog("Test ran: \(test.count)")
testScore = testScore/Double(test.count)
NSLog("Test Score: \(testScore)")
