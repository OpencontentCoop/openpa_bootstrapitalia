// rollup.config.js

import { babel } from '@rollup/plugin-babel'
import copy from 'rollup-plugin-copy'
import svgSprite from 'rollup-plugin-svg-sprite-deterministic'
import scss from 'rollup-plugin-scss'
import uglify from '@lopatnov/rollup-plugin-uglify'
import legacy from '@rollup/plugin-legacy'
import nodeResolve from '@rollup/plugin-node-resolve'
import injectProcessEnv from 'rollup-plugin-inject-process-env'
import commonjs from 'rollup-plugin-commonjs'

export default [
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
          { src: 'src/assets', dest: '../images' },
          { src: 'src/fonts', dest: '..' },
        ],
      }),
      svgSprite({
        outputFolder: '../images/svg',
      }),
      scss({
        output: '../stylesheets/bootstrap-italia.min.css',
        outputStyle: 'compressed',
        sourceMap: true,
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
        sourcemap: true,
        dir: '../javascript',
        // chunkFileNames: '[name].js'
        preserveModules: true,
        // // Optionally strip useless path from source
        // preserveModulesRoot: 'lib',
      },
    ],
    // plugins: [
    //   injectProcessEnv({
    //     NODE_ENV: 'production',
    //   }),
    // ],
    // manualChunks: id => path.parse(id).name
  },
  // {
  //   input: 'docs/assets/src/js/docs-entry.js',
  //   output: {
  //     file: 'docs/assets/../javascript/docs.min.js',
  //     compact: true,
  //     format: 'iife',
  //   },
  //   plugins: [
  //     legacy({
  //       './cover-animation.js': {
  //         initCoverAnimation: 'animation.initCoverAnimation',
  //       },
  //     }),
  //     babel({ babelHelpers: 'bundled' }),
  //     scss({
  //       output: 'docs/assets/dist/css/docs.min.css',
  //       outputStyle: 'compressed',
  //       watch: 'docs/assets/src/scss',
  //     }),
  //   ],
  // },
  // Entry comuni
  // {
  //   input: 'src/scss/bootstrap-italia-comuni.scss',
  //   output: {
  //     dir: '../stylesheets',
  //   },
  //   plugins: [
  //     scss({
  //       output: '../stylesheets/bootstrap-italia-comuni.min.css',
  //       outputStyle: 'compressed',
  //       watch: 'src/scss',
  //     }),
  //   ],
  // },
  {
    input: 'src/scss/default.scss',
    output: {
      dir: '../stylesheets',
    },
    plugins: [
      scss({
        output: '../stylesheets/default.css',
        outputStyle: 'compressed',
        sourceMap: false,
        watch: 'src/scss',
      }),
    ],
  },
  {input: 'src/scss/acqua.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/acqua.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/acquamarina.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/acquamarina.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/amaranto.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/amaranto.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/apss.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/apss.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/cagliari.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/cagliari.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/cenerentola.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/cenerentola.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/elegance.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/elegance.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/mare.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/mare.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/mediterraneo.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/mediterraneo.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/rustico.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/rustico.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/trento.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/trento.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {
    input: 'src/scss/turquoise.scss',
    output: {dir: '../stylesheets'},
    plugins: [
      scss({
        output: '../stylesheets/turquoise.css',
        outputStyle: 'compressed',
        sourceMap: false,
        watch: 'src/scss'
      })]
  },
  {input: 'src/scss/verdone.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/verdone.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {input: 'src/scss/warmred.scss', output: {dir: '../stylesheets'},plugins: [scss({output: '../stylesheets/warmred.css',outputStyle: 'compressed',watch: 'src/scss'})]},
  {
    input: 'src/scss/common.scss',
    output: {
      dir: '../stylesheets',
    },
    plugins: [
      scss({
        output: '../stylesheets/common.css',
        outputStyle: 'compressed',
        sourceMap: false,
        watch: 'src/scss',
      }),
    ],
  },
]
