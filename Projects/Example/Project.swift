import ProjectDescription

var ExampleTarget: Target {
  return .target(
    name: "Example",
    destinations: .iOS,
    product: .app,
    bundleId: "com.GiumaSoft.TinyRest.Example",
    infoPlist: .extendingDefault(
      with: [
        "UILaunchStoryboardName": "LaunchScreen.storyboard",
      ]
    ),
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    dependencies: [
      .package(product: "TinyRest")
    ]
  )
}

var ExampleTestsTarget: Target {
  .target(
      name: "ExampleTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "com.GiumaSoft.TinyRest.ExampleTests",
      infoPlist: .default,
      sources: ["Tests/**"],
      resources: [],
      dependencies: [.target(name: "Example")]
  )
}

let project = Project(
    name: "Example",
    packages: [
      .package(path: "../../")
    ],
    settings: Settings.settings(
      base: [
        "ENABLE_USER_SCRIPT_SANDBOXING": false
      ]
    ),
    targets: [
      ExampleTarget,
      ExampleTestsTarget
    ]
)
