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

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.0"
  spec.add_dependency "kredis", ">= 0.4"
  spec.add_dependency "cable_ready", "= 5.0.0.pre6"

  spec.add_development_dependency "standard"
end
