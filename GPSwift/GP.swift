//
//  GP.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-23.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation


typealias ProgramTreeNode = TreeNode<NodeFunction>
enum GPFunction {
    case twoArg(f : (Double, Double)->Double, name: String)
    case threeArg(f : (Double, Double, Double)->Double, name: String)
}
//typealias GPFunction = (function : (Double, Double)->Double, name: String)

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

enum NodeFunction {
    case leaf(Leaf)
    case f(GPFunction)
    case constant(Double)
}

extension NodeFunction: CustomStringConvertible {
    
    var description : String {
        switch self {
        case .leaf(_):
            return "leaf"
        case .constant(let constant):
            return "\(constant)"
        case .f(let gpFunction):
            switch gpFunction {
            case .twoArg(_, let name):
                return name
            case .threeArg(_, let name):
                return name
            }
            
        }
    }
}

protocol GPTrainer{
    func fitness(forProgram: ProgramTreeNode, eval: (ProgramTreeNode)->Double, leafs: [Leaf]) ->Double
    func description() -> String
}

struct RunConfiguration {
    let initialTreeDepth : Int
    let numberOfGenerations : Int
    let generationSize : Int
    let mutationRate : Double
    let crossoverRate : Double
    let tournamentSize : Int
}

struct GPRun {
    
    let functionArray : [GPFunction]
    let leafs: [Leaf]
    let trainer : GPTrainer
    
    let config : RunConfiguration
    
    var currentGeneration : ([IndividualProgram])?


    init(functions: [GPFunction],
         leafs: [Leaf],
         trainer: GPTrainer,
         config: RunConfiguration
         ) {
        
        self.functionArray = functions
        self.leafs = leafs
        self.trainer = trainer
        
        self.config = config
    }
   
    private func makeConstant()->Double {
        return Double((arc4random_uniform(UInt32(100))))/100.0
    }
    private func getRandomLeaf()-> Leaf {
        let i = Int( (arc4random_uniform(UInt32(leafs.count))))
        return leafs[i]
    }
    private func getRandomTwoArgFunc() -> GPFunction {
        let funcs = self.functionArray.filter { f in
            switch f{
            case .threeArg:
                return false
            case .twoArg:
                return true
            }
        }
        
        let i = Int( (arc4random_uniform(UInt32(funcs.count))))
        return funcs[i]
    }
    private func getRandomThreeArgFunc() -> GPFunction {
        let funcs = self.functionArray.filter { f in
            switch f{
            case .threeArg:
                return true
            case .twoArg:
                return false
            }
        }
        
        let i = Int( (arc4random_uniform(UInt32(funcs.count))))
        return funcs[i]
    }
    
    func makeProgram(depth: Int)-> TreeNode<NodeFunction>{
        if(depth == 1){
            if (Int(arc4random_uniform(UInt32(2))) == 0){
                let body = NodeFunction.constant(self.makeConstant())
                let t = TreeNode<NodeFunction>(value: body)
                return t
            }else{
                let t = TreeNode<NodeFunction>(value: NodeFunction.leaf(self.getRandomLeaf()))
                return t
            }
            
        }
        
        
        let f1 = makeProgram(depth: depth-1)
        let f2 = makeProgram(depth: depth-1)
        
        let i = Int( (arc4random_uniform(UInt32(functionArray.count))))
        let selectedFunction = self.functionArray[i]
        
        let rootFunc = NodeFunction.f(selectedFunction)
        
        
        let root = TreeNode<NodeFunction>(value: rootFunc)
        root.add(f1)
        root.add(f2)
        
        switch selectedFunction {
        case .twoArg: break
        case .threeArg:
            let f3 = makeProgram(depth: depth-1)
            root.add(f3)
        }
        
        
        return root
    }
    
    func evalProgram(root : ProgramTreeNode)->Double{
        switch root.value {
        case .leaf(let leaf):
            return leaf.value
        case .constant(let constant):
            return constant
        case .f(let function):
            let v1 = evalProgram(root: root.children[0])
            let v2 = evalProgram(root: root.children[1])
            switch function {
            case .twoArg(let f,_):
                return f(v1, v2)
            case .threeArg(let f, _):
                let v3 = evalProgram(root: root.children[2])
                return f(v1, v2, v3)
            }
        }
    }
    
    func buildGeneration(size: Int)->[IndividualProgram]{
        var gen = [IndividualProgram]()
        for _ in 0..<size{
            let p = IndividualProgram(prg: makeProgram(depth: self.config.initialTreeDepth), score: 1000.0)
            gen.append(p)
        }
        return gen
    }
    
    mutating func start(){
        
        self.currentGeneration = self.buildGeneration(size: self.config.generationSize)
        
        guard var currentGeneration = self.currentGeneration else{
            fatalError()
        }
        
        let mutatedNumber = Int(Double(self.config.generationSize)*self.config.mutationRate)
        let crossoverNumber = Int(Double(self.config.generationSize)*self.config.crossoverRate)
        
        for _ in 0..<self.config.numberOfGenerations {
            for i in 0..<currentGeneration.count {
                currentGeneration[i].score = trainer.fitness(forProgram: currentGeneration[i].prg, eval: self.evalProgram, leafs: leafs)
            }
            
            currentGeneration.sort(by: {a,b in
                return a.score<b.score
            })
            NSLog("Run \(trainer.description()) Current gen best score: \(currentGeneration[0].score) worst: \(currentGeneration[currentGeneration.count-1].score)")
            
            var newGeneration = ([IndividualProgram])()
            let filler = currentGeneration.prefix(upTo: currentGeneration.count-mutatedNumber-crossoverNumber)
            newGeneration.append(contentsOf: filler)
            for _ in 0..<mutatedNumber{
                let prgToMutate = Int((arc4random_uniform(UInt32(self.config.generationSize/2))))
                newGeneration.append(self.mutate(prg: currentGeneration[prgToMutate]))
            }
            
            for i in 0..<crossoverNumber{
                let parent1 = currentGeneration[self.tournamentSelection()]
                var p2 = Int((arc4random_uniform(UInt32(self.config.generationSize/2))))
                while p2 == i{
                    p2 = tournamentSelection()
                }
                let parent2 = currentGeneration[p2]
                var new = self.crossover(parents: (parent1, parent2))
                while new == nil {
                    new = self.crossover(parents: (parent1, parent2))
                }
                newGeneration.append(new!)
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
    
    func tournamentSelection()->Int{
        var winner : Int?
        for _ in 0..<self.config.tournamentSize {
            let cur = Int((arc4random_uniform(UInt32(self.config.generationSize-1))))
            if let w = winner {
                if currentGeneration![cur].score < currentGeneration![w].score {
                    winner = cur
                }
            }else{
                winner = cur
            }
        }
        return winner!
    }
    
    func mutate(prg: IndividualProgram) -> IndividualProgram{
        let level = Int( (arc4random_uniform(UInt32(self.config.initialTreeDepth-2))))
        var next = prg.prg.replica()
        let top = next
        for _ in 0..<level{
            let decision = Int( (arc4random_uniform(UInt32(2))))
            next = next.children[decision]
        }
       
        
        switch next.value {
        case .constant(_):
            next.value = NodeFunction.constant(self.makeConstant())
        case .leaf(_):
            next.value = NodeFunction.leaf(self.getRandomLeaf())
        case .f(let f):
            switch f {
            case .twoArg:
                next.value = NodeFunction.f(self.getRandomTwoArgFunc())
            case .threeArg:
                next.value = NodeFunction.f(self.getRandomThreeArgFunc())
            }
        }
        
        let newProgram = IndividualProgram(prg: top, score:0.0)
        return newProgram
    }
    
    func crossover(parents: (IndividualProgram, IndividualProgram)) -> IndividualProgram?{
        let level = Int( (arc4random_uniform(UInt32(self.config.initialTreeDepth-2))))
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
        
        var newProgram : IndividualProgram?
        if next1.children.count == next2.children.count {
            next1.children = next2.children
            newProgram = IndividualProgram(prg: top, score:0.0)
        }
        return newProgram
        
    }
}
