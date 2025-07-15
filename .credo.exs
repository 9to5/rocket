%{
  configs: [
    %{
      name: "default",
      strict: true,
      color: true,
      files: %{
        included: ["lib/", "test/"],
        excluded: ["_build/", "deps/"]
      }
    }
  ]
}
