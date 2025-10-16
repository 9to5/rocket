%{
  configs: [
    %{
      name: "default",
      strict: true,
      color: true,
      files: %{
        included: ["lib/", "test/"],
        excluded: ["_build/", "deps/"]
      },
      checks: [
        {Credo.Check.Readability.ModuleDoc, []},
        {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
        {Credo.Check.Refactor.CyclomaticComplexity, [max_complexity: 10]},
        {Credo.Check.Design.TagTODO, [exit_status: 0]},
        {Credo.Check.Design.TagFIXME, [exit_status: 0]}
      ]
    }
  ]
}
