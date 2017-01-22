//
//  main.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation



var functionArray1 = [(Double)->Double]()
var functionArray2 = [(Double, Double)->Double]()
var leafs = [()->Double]()

functionArray2.append(+)
functionArray2.append(-)
functionArray2.append(*)

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

enum NodeType{
    case twoVal
    case oneVal
    case leaf
}

struct NodeFunction{
    var type : NodeType
    var f1 : ((Double)->Double)?
    var f2 : ((Double, Double)->Double)?
    var leaf :(()->Double)?
    init(type : NodeType) {
        self.type = type
    }
}

typealias ProgramTreeNode = TreeNode<NodeFunction>

func makeProgram(depth: Int)-> TreeNode<NodeFunction>{
    if(depth == 1){
        var body = NodeFunction(type: .leaf)
        let i = Int( (arc4random_uniform(UInt32(leafs.count))))
        body.leaf = leafs[i]
        let t = TreeNode<NodeFunction>(value: body)
        return t
    }

    var rootFunc = NodeFunction(type: .twoVal)
    
    let f1 = makeProgram(depth: depth-1)
    let f2 = makeProgram(depth: depth-1)
    
    let i = Int( (arc4random_uniform(UInt32(functionArray2.count))))
    rootFunc.f2 = functionArray2[i]
    
    let root = TreeNode<NodeFunction>(value: rootFunc)
    root.add(f1)
    root.add(f2)
    return root
}

func evalProgram(root : ProgramTreeNode)->Double{
    if root.value.type == .leaf {
        return root.value.leaf!()
    }else if root.value.type == .oneVal{
        let v1 = evalProgram(root: root.children[0])
        
        return root.value.f1!(v1)
    }else{
        let v1 = evalProgram(root: root.children[0])
        let v2 = evalProgram(root: root.children[1])
        
        return root.value.f2!(v1, v2)
    }
}

struct IndividualProgram {
    let prg : ProgramTreeNode
    var score : Double = 0.0
}
var programs = [IndividualProgram]()
for i in 0..<10000 {
    let p = IndividualProgram(prg: makeProgram(depth: 4), score: 1000.0)
    programs.append(p)
}
func fitness(program: ProgramTreeNode)-> Double{
    let result = evalProgram(root: program)
    return abs(2.0-result)
}

for i in 0..<programs.count {
    programs[i].score = fitness(program: programs[i].prg)
}

programs.sort(by: {a,b in
    return a.score<b.score
})

let maxPrg = programs[0]
print(" \(programs[0])")

print("Target is 2.0")
print("Best is \(evalProgram(root: maxPrg.prg))")





