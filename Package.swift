import PackageDescription

let package = Package(
    name: "GPSwift",
    dependencies: [
        .Package(url: "https://github.com/dyashkir/Surge.git",
                 majorVersion: 0),
        .Package(url: "https://github.com/yaslab/CSV.swift.git", majorVersion: 1, minor: 1)
    ]
)
