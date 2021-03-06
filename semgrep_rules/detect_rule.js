{
  rules: [
    {
      id: "insecure-eval-use",
      patterns: [
        {
          pattern: "eval(...)"
        },
        {
          pattern-not: "eval(\"...\")
        }
      ],
      message: "Calling 'eval' with user input",
      languages: [
        "java"
      ],
      severity: "WARNING"
    }
  ]
}
