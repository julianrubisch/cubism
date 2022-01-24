module Cubism
  class Engine < ::Rails::Engine
    initializer "cubism.store" do
      Cubism.store = Cubism::CubicleBlockStore.new
    end
  end
end
