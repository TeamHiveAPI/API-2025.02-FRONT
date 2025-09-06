export default {
    extends: ["@commitlint/config-conventional"],
    rules: {
        "type-enum": [
            2,
            "always",
            [
                "fix",
                "feature",
                "refactor",
                "docs",
                "ci",
                "test",
                "security",
                "deprecated",
                "remove",
            ],
        ],
        "subject-case": [0, "always"],
        "references-empty": [1, "never"],
        "header-max-length": [2, "always", Infinity],
        "body-max-length": [2, "always", 0],
        "footer-max-length": [2, "always", 0],
    },
    parserPreset: {
        parserOpts: {
            headerPattern: /(\w+):\s#[a-zA-Z0-9]+\s([a-zA-Z0-9]+)/,
            headerCorrespondence: ["type", "subject"],
        },
    },
}
