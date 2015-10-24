var GinatraChart = require("./GinatraChart.jsx");
var React = require("react");

var PolarAreaLines = React.createClass({
  render: function() {
    var type = "PolarArea";
    var height = this.props.height;
    var width = this.props.width;
    var url = this.props.url;

    return (
      <GinatraChart url={url} type={type} width={width} height={height} />
    );
  }
});

module.exports = PolarAreaLines;
