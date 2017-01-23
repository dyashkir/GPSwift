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
}

typealias ProgramTreeNode = TreeNode<NodeFunction>
typealias GPFunction = (function : (Double, Double)->Double, name: String)
class Leaf {
    var value : Double = 0.0
}
struct IndividualProgram {
    let prg : ProgramTreeNode
    var score : Double = 0.0
}
struct NodeFunction{
    var type : NodeType
    var f : GPFunction?
    var leaf : Leaf?
    var name : String?
    init(type : NodeType) {
        self.type = type
    }
    
}
extension NodeFunction: CustomStringConvertible {
     
    var description: String {
        if(type == .leaf){
           return "leaf"
        }else{
            return (self.f!.name)
        }
    }
}

struct GPRun {
    let functionArray: [(function: (Double, Double)->Double, name: String)]
    let leafs: [Leaf]
    
    let fitness : (ProgramTreeNode)->Double
    let initialTreeDepth : Int


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
    
    func mutate(prg: IndividualProgram) -> IndividualProgram{
        let decision = Int( (arc4random_uniform(UInt32(2))))
        let i = Int( (arc4random_uniform(UInt32(functionArray.count))))
        prg.prg.children[decision].value.f = functionArray[i]
        return prg
    }
}
