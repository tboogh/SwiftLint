import PackagePlugin
import Foundation

@main
struct SwiftLintPlugin: BuildToolPlugin {
    func createBuildCommands(context: PackagePlugin.PluginContext, target: PackagePlugin.Target) async throws -> [PackagePlugin.Command] {
        let fileManager = FileManager.default
        // Possible paths where there may be a config file (root of package, target dir.)
        let configurations: [Path] = [context.package.directory, target.directory]
            .map { $0.appending("swiftlint.yml") }
            .filter { fileManager.fileExists(atPath: $0.string) }

        return try configurations.map {
            .buildCommand(
                displayName: "SwiftLint",
                executable: try context.tool(named: "swiftlint").path,
                arguments: [
                    "--config", $0
                ])
        }
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftLintPlugin: XcodeBuildToolPlugin {

    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let fileManager = FileManager.default
        // Possible paths where there may be a config file
        let configurations: [Path] = [context.xcodeProject.directory]
            .map { $0.appending("swiftlint.yml") }
            .filter { fileManager.fileExists(atPath: $0.string) }
        let configs: [Path]
        = context.xcodeProject.filePaths.filter { $0.string.contains("swiftlint.yml")}
        return try [configurations, configs].map {
            .buildCommand(
                displayName: "SwiftLint",
                executable: try context.tool(named: "swiftlint").path,
                arguments: [
                    "--config", $0
                ])
        }
    }
}
#endif
