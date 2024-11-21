import { babel } from '@rollup/plugin-babel'
import copy from 'rollup-plugin-copy'
import svgSprite from 'rollup-plugin-svg-sprite-deterministic'
import scss from 'rollup-plugin-scss'
import uglify from '@lopatnov/rollup-plugin-uglify'
import nodeResolve from '@rollup/plugin-node-resolve'
import injectProcessEnv from 'rollup-plugin-inject-process-env'
import commonjs from 'rollup-plugin-commonjs'

const themes = [
  // 'acqua',
  // 'acquamarina',
  // 'amalfi',
  // 'amaranto',
  // 'apss',
  // 'asl',
  // 'cagliari',
  // 'cenerentola',
  'default',
  // 'elegance',
  // 'mare',
  // 'mediterraneo',
  // 'rustico',
  // 'trento',
  // 'turquoise',
  // 'verdone',
  // 'warmred'
]

const commons = [
  'common'
]

let configs = [
  {
    input: 'src/js/bootstrap-italia.entry.js',
    output: {
      file: '../javascript/bootstrap-italia.bundle.min.js',
      compact: true,
      format: 'iife',
      generatedCode: 'es2015',
      name: "bootstrap",
    },
    plugins: [
      babel({
        babelHelpers: 'bundled',
        exclude: 'node_modules/**',
      }),
      copy({
        targets: [
          {src: 'src/assets', dest: '../images'},
          {src: 'src/fonts', dest: '..'},
        ],
      }),
      svgSprite({
        outputFolder: '../images/svg',
      }),
      scss({
        output: '../stylesheets/bootstrap-italia.min.css',
        outputStyle: 'compressed',
        sourceMap: false,
        watch: 'src/scss',
      }),
      nodeResolve(),
      commonjs(),
      injectProcessEnv({
        NODE_ENV: 'production',
      }),
      uglify(),
    ],
  },
  {
    input: 'src/js/bootstrap-italia.esm.js',
    output: [
      {
        format: 'es',
        exports: 'named',
        sourcemap: false,
        dir: '../javascript',
        preserveModules: true,
      }
    ]
  }
]

themes.forEach(function (theme){
  configs.push({
    input: 'src/scss/'+theme+'.scss',
    plugins: [
      scss({
        output: '../stylesheets/'+theme+'.css',
        outputStyle: 'compressed',
        sourceMap: true,
        watch: 'src/scss'
      })
    ]
  })
})

commons.forEach(function (common){
  configs.push({
    input: 'src/scss/'+common+'.scss',
    plugins: [
      scss({
        output: '../stylesheets/'+common+'.css',
        outputStyle: 'compressed',
        sourceMap: true,
        watch: 'src/scss'
      })
    ]
  })
})

export default configs