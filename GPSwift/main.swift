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
    var body = NodeFunction(type: .leaf)
    body.leaf = leafs[0]
    var t = TreeNode<NodeFunction>(value: body)
    return t
}

func evalProgram(root : ProgramTreeNode)->Double{
   return root.value.leaf!()
}


let firstProgram = makeProgram(depth: 5)

let result = evalProgram(root: firstProgram)

print("Result! : \(result)")



