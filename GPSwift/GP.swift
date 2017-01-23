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

struct IndividualProgram {
    let prg : ProgramTreeNode
    var score : Double = 0.0
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


struct GPRun {
    let functionArray: [(Double, Double)->Double]
    let leafs: [()->Double]
    
    let fitness : (ProgramTreeNode)->Double


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
        rootFunc.f2 = functionArray[i]
        
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
    
    func buildGeneration(size: Int)->[IndividualProgram]{
        var gen = [IndividualProgram]()
        for _ in 0..<size{
            let p = IndividualProgram(prg: makeProgram(depth: 4), score: 1000.0)
            gen.append(p)
        }
        return gen
    }
    
}
