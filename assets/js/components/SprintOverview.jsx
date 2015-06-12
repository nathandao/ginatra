var React = require("react");
var GinatraChart = require("./GinatraChart.jsx");

var SprintOverview = React.createClass({
  render: function() {
    var width = this.props.width || '500';
    var height = this.props.height || '500';
    var interval = this.props.interval || false
    return(
      <GinatraChart url='/stat/chart/line/sprint_hours_commits' width={width} height={height} interval={interval} type="Bar" />
    );
  }
});

module.exports = SprintOverview;