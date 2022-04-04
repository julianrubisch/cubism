import resolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import json from '@rollup/plugin-json'
import { terser } from 'rollup-plugin-terser'

const pretty = () => {
  return terser({
    mangle: false,
    compress: false,
    format: {
      beautify: true,
      indent_level: 2
    }
  })
}

const minify = () => {
  return terser({
    mangle: true,
    compress: true
  })
}

const esConfig = {
  format: 'es',
  inlineDynamicImports: true
}

const umdConfig = {
  name: 'Cubism',
  format: 'umd',
  exports: 'named',
  globals: {
    cable_ready: 'CableReady'
  }
}

const distFolders = ['dist/', 'app/assets/javascripts/']

const output = distFolders
  .map(distFolder => [
    {
      ...esConfig,
      file: `${distFolder}/cubism.js`,
      plugins: [pretty()]
    },
    {
      ...esConfig,
      file: `${distFolder}/cubism.min.js`,
      sourcemap: true,
      plugins: [minify()]
    },
    {
      ...umdConfig,
      file: `${distFolder}/cubism.umd.js`,
      plugins: [pretty()]
    },
    {
      ...umdConfig,
      file: `${distFolder}/cubism.umd.min.js`,
      sourcemap: true,
      plugins: [minify()]
    }
  ])
  .flat()

export default [
  {
    external: ['cable_ready'],
    input: 'javascript/index.js',
    output,
    plugins: [commonjs(), resolve(), json()],
    watch: {
      include: 'javascript/**'
    }
  }
]
