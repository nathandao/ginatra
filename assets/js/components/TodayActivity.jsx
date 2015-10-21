var React = require('react');
var BarChart = require("react-chartjs").Bar;
var $ = require('jquery');

var TodayActivity = React.createClass({
  loadData: function() {
    var hours = [
      'today at 00:00',
      'today at 01:00',
      'today at 02:00',
      'today at 03:00',
      'today at 04:00',
      'today at 05:00',
      'today at 06:00',
      'today at 07:00',
      'today at 08:00',
      'today at 09:00',
      'today at 10:00',
      'today at 11:00',
      'today at 12:00',
      'today at 13:00',
      'today at 14:00',
      'today at 15:00',
      'today at 16:00',
      'today at 17:00',
      'today at 18:00',
      'today at 19:00',
      'today at 20:00',
      'today at 21:00',
      'today at 22:00',
      'today at 23:00',
      'today at 23:59'
    ];
    var labels = [
      '00:00',
      '01:00',
      '02:00',
      '03:00',
      '04:00',
      '05:00',
      '06:00',
      '07:00',
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
      '21:00',
      '22:00',
      '23:00',
      '23:59'
    ];
    $.ajax({
      url: '/stat/chart/timeline/commits',
      type: "GET",
      contentType: 'json',
      data: { time_stamps: hours, labels: labels },
      cache: false,
      success: function(data) {
        this.setState( { chartData: data } );
      }.bind(this)
    });
  },
  getInitialState: function() {
    return { chartData: { labels:['loading...'], datasets:[{ label: 'loading...', data: [0] }] } };
  },
  componentDidMount: function() {
    this.loadData();
    socket = new WebSocket("ws://" + window.location.hostname + ":9290");
    socket.onmessage = function(event) {
      var updatedRepos = event.data.split(",");
      if (updatedRepos.indexOf(this.props.repoId) > -1 || this.props.repoId == undefined) {
        this.loadData();
      }
    }.bind(this);
  },
  render: function() {
    var width = this.props.width || 1000;
    var height = this.props.height || 500;
    var chartOptions = { responsive: true, scaleGridLineColor: "rgba(255,255,255,0.5)" };

    return(
      <BarChart data={this.state.chartData} options={chartOptions} width={width} height={height} />
    );
  }
});

module.exports = TodayActivity;

