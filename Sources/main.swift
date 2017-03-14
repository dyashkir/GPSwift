//
//  main.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation
import Surge

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

functionArray.append( .twoArg(f : +, name : "+"))


functionArray.append(.twoArg(f : *, name : "*"))
functionArray.append(.twoArg(f : -, name : "-"))


/*func division(a:Double, b:Double) ->Double {
    if b != 0.0 {
        return a/b
    }else{
        return a
    }
}
functionArray.append(.twoArg(f : division, name : "/"))

func if_func(condition : Double, negative : Double, positive: Double) -> Double{
    if (condition < 0.0){
        return negative
    }else{
        return positive
    }
}

functionArray.append(.threeArg(f : if_func, name : "if"))
*/
var leafs = [Leaf]()

let trainingCSV = readFile(path: "/Users/dyashkir/ios/GPSwift/train_test_data/mnist_train_100.csv")

var lines = trainingCSV.components(separatedBy: "\n").map( { a in
    return a.components(separatedBy: ",")
})

lines = Array(lines[0..<(lines.count-1)])

for i in 0..<lines[0].count-1 {
    leafs.append(Leaf(value: Array<Double>()))
}

struct NumbersTrainer : GPTrainer {
   
    var target : [Double]
    var inputs : [[Double]]
    
    let targetNumber : Int
    
    func description() -> String {
        return "\(targetNumber)"
    }
    
    init(_ inputSet : [(Int, [Double])], targetNumber : Int) {
        
        self.targetNumber = targetNumber
        
        self.target = inputSet.map { i in
            return Double(i.0)
        }
        
        let trainingSetSize = inputSet.count
        let dataSize = inputSet[0].1.count
        
        var data = [[Double]]()
        for i in 0..<dataSize {
            var inp = [Double](repeating: 0.0, count: trainingSetSize)
            for j in 0..<trainingSetSize{
               inp[j] = inputSet[j].1[i]
            }
            data.append(inp)
        }
        self.inputs = data
    }
    
    func dataCount() -> Int {
        return target.count
    }
    
    func fitness(forProgram: ProgramTreeNode, eval: (ProgramTreeNode) -> [Double], leafs: [Leaf]) -> Double {
       
        for i in 0..<leafs.count{
            leafs[i].value = inputs[i]
        }
        
        let result = eval(forProgram)
        
        var error = 0.0
        for i in 0..<result.count{
            
            if target[i] == Double(targetNumber){
                if (result[i] <= 0){
                    error += 5.0
                }
            }else{
                if (result[i] >= 0){
                    error += 1.0
                }
            }
        }
        
        return error
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
    let trainer = NumbersTrainer(trainSet, targetNumber: i)
    trainers.append(trainer)
}

var runs = trainers.map { trainer -> GPRun in
    
    let runConfig = RunConfiguration( initialTreeDepth: 6,
                                      numberOfGenerations: 20,
                                      generationSize: 1000,
                                      mutationRate: 0.01,
                                      crossoverRate: 0.98,
                                      tournamentSize : 2)
    
    return GPRun(functions: functionArray, leafs: leafs, trainer: trainer, config: runConfig)
}
NSLog("Starting runs")
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
        leafs[i].value = [t.1[i]]
    }
    
    let results = best.map { prg -> [Double] in
        let res = runs[0].evalProgram(root: (prg.prg))
        return res
    }
  
    var maxVal = 0.0
    var index = -1
    NSLog("Number is: \(t.0)")
    /*for i in 0..<results.count{
        if results[i] > maxVal {
            NSLog("\(results[i]) \(i)")
            maxVal = results[i]
            index = i
        }
    }*/
    
    NSLog("Expected: \(t.0) selected: \(index)")
    let res = index
    if t.0 == index {
        testScore += 1.0
    }
}
NSLog("Test ran: \(test.count)")
testScore = testScore/Double(test.count)
NSLog("Test Score: \(testScore)")
