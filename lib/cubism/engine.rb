module Cubism
  class Engine < ::Rails::Engine
    initializer "cubism.block_store" do
      Cubism.block_store = Cubism::CubicleBlockStore.new
    end
  end
end
