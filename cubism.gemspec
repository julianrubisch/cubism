require_relative "lib/cubism/version"

Gem::Specification.new do |spec|
  spec.name = "cubism"
  spec.version = Cubism::VERSION
  spec.authors = ["Julian Rubisch"]
  spec.email = ["julian@julianrubisch.at"]
  spec.homepage = "https://github.com/julianrubisch/cubism"
  spec.summary = "Lightweight Resource-Based Presence Solution with CableReady"
  spec.description = "Lightweight Resource-Based Presence Solution with CableReady"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/julianrubisch/cubism.git"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir[
    "lib/**/*.rb",
    "app/**/*.rb",
    "app/assets/javascripts/*",
    "bin/*",
    "[A-Z]*"
  ]

  spec.test_files = Dir["test/**/*.rb"]

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "kredis", ">= 0.4"
  spec.add_dependency "cable_ready", "= 5.0.0.pre9"

  spec.add_development_dependency "standard"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "sqlite3"
end
