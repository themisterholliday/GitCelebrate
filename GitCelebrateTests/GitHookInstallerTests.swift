import Testing
@testable import GitCelebrate

struct GitHookInstallerTests {
    @Test
    func generatedHookUsesJsonEncoderInsteadOfRawPrintfPayload() {
        let script = GitHookInstaller().hookScript(type: .commit)

        #expect(script.localizedStandardContains("osascript -l JavaScript"))
        #expect(script.localizedStandardContains("JSON.stringify"))
        #expect(!script.localizedStandardContains("printf '{\"type\""))
    }
}
