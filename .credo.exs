%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: ["_build/", "deps/"]
      }
    }
  ]
}
