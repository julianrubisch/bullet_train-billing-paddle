require_relative "lib/bullet_train/billing/paddle/version"

Gem::Specification.new do |spec|
  spec.name = "bullet_train-billing-paddle"
  spec.version = BulletTrain::Billing::Paddle::VERSION
  spec.authors = ["Julian Rubisch"]
  spec.email = ["julian@julianrubisch.at"]
  spec.homepage = "https://github.com/julianrubisch/bullet_train-billing-paddle"
  spec.summary = "Bullet Train Billing for Paddle"
  spec.description = spec.summary
  spec.license = "Nonstandard"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "bullet_train-billing"
  spec.add_dependency "paddle_pay"

  spec.add_development_dependency "standard"
end
