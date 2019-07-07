import PackageDescription

let package = Package(
    name: "SpearSwiftLib",
    products: [
        .library(name: "SpearSwiftLib", targets: ["SwiftyBeaver"]),
    ],
    targets: [
        .target(name: "SwiftyBeaver", dependencies: [], path: "Sources"),
        .testTarget(name: "SwiftyBeaverTests", dependencies: ["SwiftyBeaver"]),
    ]
)
