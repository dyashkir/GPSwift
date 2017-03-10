//
//  Tree.swift
//  GPSwift
//
//  Created by Dmytro Yashkir on 2017-01-22.
//  Copyright © 2017 Dmytro Yashkir. All rights reserved.
//

import Foundation
class TreeNode<T> {
    public var value: T
    
    public weak var parent: TreeNode?
    public var children = [TreeNode<T>]()
    
    public init(value: T) {
        self.value = value
    }
    
    public func add(_ node: TreeNode<T>) {
        children.append(node)
        node.parent = self
    }
    
    public func replica() ->TreeNode<T> {
        let n = TreeNode<T>(value: self.value)
        let newChildren = self.children.map( { a in
            return a.replica()
            })
        n.children = newChildren
        return n
    }
}

extension TreeNode: CustomStringConvertible {
    public var description: String {
        var s = "\(value) "
        if !children.isEmpty {
            s += " {" + children.map { $0.description }.joined(separator: ", ") + "}"
        }
        return s
    }
}
