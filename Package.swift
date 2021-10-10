// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "KeychainExport",
    products: [
        .library(
            name: "KeychainExport",
            targets: ["KeychainExport"])
    ],
    dependencies: [
        .package(url: "https://github.com/eonist/With.git", .branch("master")),
        .package(url: "https://github.com/sentryco/WizardHelper.git", .branch("master")),
        .package(url: "https://github.com/eonist/JSONSugar.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "KeychainExport",
            dependencies: ["With", "WizardHelper", "JSONSugar"])
    ]
)
