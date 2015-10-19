var React = require("react");
var $ = require("jquery");

var CommitsOverview = React.createClass({
  loadOverviewData: function() {
    $.ajax({
      url: this.props.url,
      dataType: 'json',
      cache: false,
      success: function(data) {
        var commits_string = 'commits';
        if(data.commits_count == 1) {
          commits_string = 'commit';
        }
        this.setState({
          commits_count: data.commits_count,
          commits_string: commits_string,
          additions: data.additions,
          deletions: data.deletions
        });
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {
      commits_count: 0,
      commits_string: 'commits',
      additions: 0,
      deletions: 0
    }
  },
  componentDidMount: function() {
    this.loadOverviewData();
    if (this.props.socket != undefined) {
      this.props.socket.onmessage = function(event) {
        this.loadOverviewData();
      }.bind(this);
    }
  },
  render: function() {
    return(
      <div className="commits-overview">
        <div classnName="half">
          <p><span className="big">{this.state.commits_count}</span> {this.state.commits_string}</p>
        </div>
        <div className="half">
          <p>{this.state.additions} additions</p>
          <p>{this.state.deletions} deletions</p>
        </div>
      </div>
    );
  }
});

module.exports = CommitsOverview;
