var React = require("react");
var GinatraChart = require("./GinatraChart.jsx");

var SprintOverview = React.createClass({
  render: function() {
    var width = this.props.width || "500";
    var height = this.props.height || "500";
    var socket = this.props.socket;

    return(
      <GinatraChart url="/stat/chart/line/sprint_commits" width={width} height={height} socket={socket} type="Bar" />
    );
  }
});

module.exports = SprintOverview;
