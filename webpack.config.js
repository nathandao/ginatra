"use strict";

var webpack = require("webpack"),
    HtmlWebpackPlugin = require("html-webpack-plugin"),
    path = require("path"),
    srcPath = path.join(__dirname, "assets/js/src"),
    env = process.env.NODE_ENV || "development";

var app = {
  target: "web",
  cache: true,

  entry: {
    main: path.join(srcPath, "app.js"),
    common: ["react", "react-dom", "events", "react-router"]
  },

  resolve: {
    root: srcPath,
    extensions: ["", ".js"],
    modulesDirectories: ["node_modules", srcPath]
  },

  output: {
    path: path.join(__dirname, "assets/js/dist"),
    publicPath: "",
    filename: "[name].js",
    library: ["Ginatra", "name"],
    pathInfo: true
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        loaders: ["react-hot", "babel"],
        exclude: /node_modules/
      },
      {
        test: /\.css$/,
        loader: "style-loader!css-loader?sourceMap!postcss"
      }
    ],
    preLoaders: [
      {
        test: /\.js$/,
        loaders: ["eslint"],
        include: [path.resolve("./assets/js/src")] }
    ]
  },

  postcss: function() {
    return [
      require("postcss-cssnext"),
      require("postcss-import-url"),
      require("lost"),
      require("autoprefixer"),
      require("postcss-normalize"),
    ];
  },

  plugins: (function() {

    var plugins = [
      new webpack.optimize.CommonsChunkPlugin("common", "common.js"),
      new webpack.NoErrorsPlugin(),
      new webpack.IgnorePlugin(/^\.\/locale$/, /moment$/)
    ];

    if (process.env.NODE_ENV == "production") {
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
        new HtmlWebpackPlugin({
          inject: true,
          template: "assets/js/src/index.html"
        })
      );
    }

    return plugins;
  }()),

  stats: { colors: true },
  eslint: { configFile: ".eslintrc" },
  debug: true,
  devtool: "eval-cheap-module-source-map",
  devServer: {
    hot: true,
    port: 9292,
    historyApiFallback: true,
    stats: {
      chunkModules: false,
      colors: true
    }
  }
};

if (process.env.NODE_ENV === "production") {
  app.devtool = "source-map";
}

module.exports = [
  app
];
