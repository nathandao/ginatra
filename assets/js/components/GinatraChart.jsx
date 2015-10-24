var React = require("react");
var PolarAreaChart = require("react-chartjs").PolarArea;
var BarChart = require("react-chartjs").Bar;
var LineChart = require("react-chartjs").Line;
var RadarChart = require("react-chartjs").Radar;
var PieChart = require("react-chartjs").Pie;
var DoughnutChart = require("react-chartjs").Doughnut;

var $ = require("jquery");

var GinatraChart = React.createClass({
  loadChartData: function() {
    $.ajax({
      url: this.props.url,
      dataType: "json",
      cache: false,
      success: function(data) {
        this.setState({chartData: data});
      }.bind(this),
      error: function(xhr, status, err) {
        console.error(this.props.url, status, err.toString());
      }.bind(this)
    });
  },
  getInitialState: function() {
    var initData = null;
    var type = this.props.type || "PolarArea";
    if (type === "PolarArea" || type === "Pie" || type === "Doughnut") {
      initData = { chartData: []};
    } else {
      initData = { chartData: { labels:["loading..."], datasets:[{ label: "loading...", data: [0] }] } };
    }

    return initData;
  },
  componentDidMount: function() {
    var socket = new WebSocket("ws://" + window.location.hostname + ":9290");
    socket.onmessage = function(event) {
      var updatedRepos = event.data.split(",");
      if (this.props.repoId == undefined || updatedRepos.indexOf(this.props.repoId) > -1) {
        this.loadChartData();
      }
    }.bind(this);
    this.loadChartData();
  },
  render: function() {
    var width = this.props.width || 1000;
    var height = this.props.height || 500;
    var type = this.props.type || "PolarArea";
    var chart = [];

    chart["PolarArea"] = PolarAreaChart;
    chart["Bar"] = BarChart;
    chart["Line"] = LineChart;
    chart["Radar"] = RadarChart;
    chart["Pie"] = PieChart;
    chart["Doughnut"] = DoughnutChart;

    return (
      React.createElement(chart[type], {data: this.state.chartData, width: width, height: height, options: { responsive: true, scaleGridLineColor: "rgba(255,255,255,0.5)" } })
    );
  }
});


module.exports = GinatraChart;
