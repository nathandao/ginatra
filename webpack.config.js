'use strict';

var webpack = require('webpack'),
    HtmlWebpackPlugin = require('html-webpack-plugin'),
    path = require('path'),
    srcPath = path.join(__dirname, 'assets/js/src'),
    env = process.env.NODE_ENV || 'development';

var app = {
  target: 'web',
  cache: true,

  entry: {
    main: path.join(srcPath, 'app.js'),
    common: ['react', 'events']
  },

  resolve: {
    root: srcPath,
    extensions: ['', '.js'],
    modulesDirectories: ['node_modules', srcPath]
  },

  output: {
    path: path.join(__dirname, 'assets/js/dist'),
    publicPath: '',
    filename: '[name].js',
    library: ['Ginatra', 'name'],
    pathInfo: true
  },

  module: {
    loaders: [
      { test: /\.js$/, exclude: /node_modules/, loaders: ['babel'] },
      { test: /\.css$/, exclude: /node_modules/, loader: 'style!css?sourceMap!postcss' }
    ],
    preLoaders: [
      { test: /\.js$/, loaders: ['eslint-loader'], include: [path.resolve('assets/js/src')] }
    ]
  },

  postcss: [
    require('lost'),
    require('autoprefixer'),
    require('precss')
  ],

  plugins: (function() {

    var plugins = [
      new webpack.optimize.CommonsChunkPlugin('common', 'common.js'),
      new webpack.NoErrorsPlugin(),
      new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/)
    ];

    if (process.env.NODE_ENV == 'production') {
      plugins.push(
        new webpack.DefinePlugin({
          "process.env": {
            // This has effect on the react lib size
            "NODE_ENV": JSON.stringify("production")
          }
        }),
        new webpack.optimize.UglifyJsPlugin(),
        new webpack.optimize.OccurenceOrderPlugin()
      );
    }
    else {
      plugins.push(
        new webpack.HotModuleReplacementPlugin(),
        new HtmlWebpackPlugin()
      );
    }

    return plugins;
  }()),

  stats: { colors: true },
  eslint: { configFile: './.eslintrc' },
  debug: true,
  devtool: 'eval-cheap-module-source-map',
  devServer: {
    hot: true,
    historyApiFallback: true,
    stats: {
      chunkModules: false,
      colors: true
    }
  }
}

if (process.env.NODE_ENV === 'production') {
  app.devtool = 'source-map';
}

module.exports = [
  app
];
