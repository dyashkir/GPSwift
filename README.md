# GPSwift
*genetic programming in Swift*

Basic Genetic Programming using Swift programming language, work in progress. Suggestions, ideas, PRs are welcome

##Install

Clone the repo ;)

## Sample

### Fit the `X^2`

```swift
var functionArray = [GPFunction]()

functionArray.append((+, "+"))
functionArray.append((-, "-"))
functionArray.append((*,"*"))

var leafs = [Leaf]()
leafs.append(Leaf())

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

let sq = SquareTrainer()

var run = GPRun(functions: functionArray, leafs: leafs, trainer: sq, initialDepth: 4, numberOfGenerations: 30)
run.start()

let maxPrg = run.currentGeneration?[0]

print("Best is:")

print(String(describing: maxPrg))

```

### Handwriting number recognition
