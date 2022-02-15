module Cubism
  class Engine < ::Rails::Engine
    initializer "cubism.stores" do
      Cubism.block_store = Cubism::CubicleStore.new("cubism-blocks")
      Cubism.source_store = Cubism::CubicleStore.new("cubism-source")
    end
  end
end
