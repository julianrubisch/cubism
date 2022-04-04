module Cubism
  class Engine < ::Rails::Engine
    initializer "cubism.stores" do
      Cubism.block_store = Cubism::CubicleStore.new("cubism-blocks")
      Cubism.source_store = Cubism::CubicleStore.new("cubism-source")
    end

    initializer "cubism.assets" do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w[
          cubism.js
          cubism.min.js
          cubism.min.js.map
          cubism.umd.js
          cubism.umd.min.js
          cubism.umd.min.js.map
        ]
      end
    end

    initializer "cubism.importmap", before: "importmap" do |app|
      if app.config.respond_to?(:importmap)
        app.config.importmap.paths << Engine.root.join("lib/cubism/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/assets/javascripts")
      end
    end
  end
end
