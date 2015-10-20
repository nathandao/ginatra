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
          <div><span className="big">{this.state.commits_count}</span></div>
          <div className="commits-string">{this.state.commits_string}</div>
        </div>
        <div className="half">
          <p>{this.state.additions} add</p>
          <p>{this.state.deletions} del</p>
        </div>
      </div>
    );
  }
});

module.exports = CommitsOverview;
