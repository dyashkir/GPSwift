//
//  GP.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-23.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation

enum NodeType{
    case twoVal
    case oneVal
    case leaf
    case constant
}

typealias ProgramTreeNode = TreeNode<NodeFunction>
typealias GPFunction = (function : (Double, Double)->Double, name: String)
class Leaf {
    var value : Double = 0.0
}
struct IndividualProgram {
    let prg : ProgramTreeNode
    var score : Double = 0.0
    
    func replicate() -> IndividualProgram{
        return self
    }
}
struct NodeFunction{
    var type : NodeType
    var f : GPFunction?
    var leaf : Leaf?
    var constant : Double?
    var name : String?
    init(type : NodeType) {
        self.type = type
    }
    
}
extension NodeFunction: CustomStringConvertible {
     
    var description: String {
        if(type == .leaf){
           return "leaf"
        }else if (type == .constant){
            return "\(self.constant!)"
        }else{
            return (self.f!.name)
        }
    }
}

protocol GPTrainer{
    func fitness(forProgram: ProgramTreeNode, eval: (ProgramTreeNode)->Double, leafs: [Leaf]) ->Double
}

struct GPRun {
    
    let functionArray : [(function: (Double, Double)->Double, name: String)]
    let leafs: [Leaf]
    let trainer : GPTrainer
    
    let initialTreeDepth : Int
    let numberOfGenerations : Int
    let generationSize : Int = 500
    let mutationRate = 0.05
    let crossoverRate = 0.9
    
    var currentGeneration : ([IndividualProgram])?


    init(functions: [(function: (Double, Double)->Double, name: String)],
         leafs: [Leaf],
         trainer: GPTrainer,
         initialDepth : Int,
         numberOfGenerations : Int) {
        
        self.functionArray = functions
        self.leafs = leafs
        self.trainer = trainer
        self.initialTreeDepth = initialDepth
        self.numberOfGenerations = numberOfGenerations
    }
    
    func makeProgram(depth: Int)-> TreeNode<NodeFunction>{
        if(depth == 1){
            if (Int(arc4random_uniform(UInt32(2))) == 0){
                var body = NodeFunction(type: .constant)
                body.constant = Double((arc4random_uniform(UInt32(100))))/100.0
                let t = TreeNode<NodeFunction>(value: body)
                return t
            }else{
                var body = NodeFunction(type: .leaf)
                let i = Int( (arc4random_uniform(UInt32(leafs.count))))
                body.leaf = leafs[i]
                let t = TreeNode<NodeFunction>(value: body)
                return t    
            }
            
        }
        
        var rootFunc = NodeFunction(type: .twoVal)
        
        let f1 = makeProgram(depth: depth-1)
        let f2 = makeProgram(depth: depth-1)
        
        let i = Int( (arc4random_uniform(UInt32(functionArray.count))))
        rootFunc.f = functionArray[i]
        
        let root = TreeNode<NodeFunction>(value: rootFunc)
        root.add(f1)
        root.add(f2)
        return root
    }
    
    func evalProgram(root : ProgramTreeNode)->Double{
        if root.value.type == .leaf {
            return root.value.leaf!.value
        }else if root.value.type == .oneVal{
            let v1 = evalProgram(root: root.children[0])
            
            return root.value.f!.function(v1, v1)
        }else if root.value.type == .constant {
            return root.value.constant!
        }else{
            let v1 = evalProgram(root: root.children[0])
            let v2 = evalProgram(root: root.children[1])
            
            return root.value.f!.function(v1, v2)
        }
    }
    
    func buildGeneration(size: Int)->[IndividualProgram]{
        var gen = [IndividualProgram]()
        for _ in 0..<size{
            let p = IndividualProgram(prg: makeProgram(depth: self.initialTreeDepth), score: 1000.0)
            gen.append(p)
        }
        return gen
    }
    
    mutating func start(){
        
        self.currentGeneration = self.buildGeneration(size: self.generationSize)
        
        guard var currentGeneration = self.currentGeneration else{
            fatalError()
        }
        
        let mutatedNumber = Int(Double(generationSize)*mutationRate)
        let crossoverNumber = Int(Double(generationSize)*crossoverRate)
        
        for _ in 0..<self.numberOfGenerations {
            for i in 0..<currentGeneration.count {
                currentGeneration[i].score = trainer.fitness(forProgram: currentGeneration[i].prg, eval: self.evalProgram, leafs: leafs)
            }
            
            currentGeneration.sort(by: {a,b in
                return a.score<b.score
            })
            NSLog("Current gen best score: \(currentGeneration[0].score) worst: \(currentGeneration[currentGeneration.count-1].score)")
            
            var newGeneration = ([IndividualProgram])()
            let filler = currentGeneration.prefix(upTo: currentGeneration.count-mutatedNumber-crossoverNumber)
            newGeneration.append(contentsOf: filler)
            for _ in 0..<mutatedNumber{
                let prgToMutate = Int((arc4random_uniform(UInt32(generationSize/2))))
                newGeneration.append(self.mutate(prg: currentGeneration[prgToMutate]))
            }
            
            for i in 0..<crossoverNumber{
                let parent1 = currentGeneration[i]
                var p2 = Int((arc4random_uniform(UInt32(generationSize/2))))
                while p2 == i{
                    p2 = Int((arc4random_uniform(UInt32(generationSize/2))))
                }
                let parent2 = currentGeneration[p2]
                newGeneration.append(self.crossover(parents: (parent1, parent2)))
            }
            
            currentGeneration = newGeneration
            
        }
        
        for i in 0..<currentGeneration.count {
            currentGeneration[i].score = trainer.fitness(forProgram: currentGeneration[i].prg, eval: self.evalProgram, leafs: leafs)
        }
        currentGeneration.sort(by: {a,b in
                return a.score<b.score
        })
        self.currentGeneration = currentGeneration
        
    }
    
    func mutate(prg: IndividualProgram) -> IndividualProgram{
        let level = Int( (arc4random_uniform(UInt32(self.initialTreeDepth-2))))
        var next = prg.prg.replica()
        let top = next
        for _ in 0..<level{
            let decision = Int( (arc4random_uniform(UInt32(2))))
            next = next.children[decision]
        }
        let i = Int( (arc4random_uniform(UInt32(functionArray.count))))
        next.value.f = functionArray[i]
        
        let newProgram = IndividualProgram(prg: top, score:0.0)
        return newProgram
    }
    
    func crossover(parents: (IndividualProgram, IndividualProgram)) -> IndividualProgram{
        let level = Int( (arc4random_uniform(UInt32(self.initialTreeDepth-2))))
        var next1 = parents.0.prg.replica()
        var next2 = parents.1.prg.replica()
        let top = next1
        
        for _ in 0..<level{
            let decision = Int( (arc4random_uniform(UInt32(2))))
            next1 = next1.children[decision]
        }
        
        for _ in 0..<level{
            let decision = Int( (arc4random_uniform(UInt32(2))))
            next2 = next2.children[decision]
        }
        
        next1.children = next2.children
        
        let newProgram = IndividualProgram(prg: top, score:0.0)
        return newProgram
    }
}
