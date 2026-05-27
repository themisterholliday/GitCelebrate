import Testing
@testable import GitCelebrate

struct GitCommitMetadataReaderTests {
    @Test
    func parsesGitShowNumstatOutput() {
        let output = """
        Add jump physics
        42\t7\tSources/Player.swift
        3\t0\tREADME.md
        -\t-\tAssets/image.png
        """

        let metadata = GitCommitMetadataReader().parse(output)

        #expect(metadata.subject == "Add jump physics")
        #expect(metadata.filesChanged == 3)
        #expect(metadata.insertions == 45)
        #expect(metadata.deletions == 7)
        #expect(metadata.netLines == 38)
        #expect(metadata.churn == 52)
    }
}
