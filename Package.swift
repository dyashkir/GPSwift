import PackageDescription

let package = Package(
    name: "GPSwift",
    dependencies: [
        .Package(url: "https://github.com/dyashkir/Surge.git",
                 majorVersion: 0)
    ]
)
