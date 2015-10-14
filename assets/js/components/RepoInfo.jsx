var React = require('react');
var $ = require('jquery');
var GinatraChart = require("./GinatraChart.jsx");

var RepoInfo = React.createClass({
  loadRepoData: function() {
    var repoId = this.props.repoId;
    $.ajax({
      url: '/stat/repo_overview',
      data: { 'in': repoId },
      cache: false,
      success: function(data) {
        var info = data[repoId];
        this.setState({
          lines: info.lines,
          commitsCount: info.commits_count,
          additions: info.additions,
          deletions: info.deletions,
          hours: info.hours.toFixed(2),
          firstCommit: info.first_commit,
          lastCommit: info.last_commit
        });
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {
      lines: 0,
      commitsCount: 0,
      additions: 0,
      deletions: 0,
      hours: 0,
      firstCommit: 0,
      lastCommit: 0
    };
  },
  componentDidMount: function() {
    this.loadRepoData();
    if (this.props.interval != false) {
      setInterval(this.loadRepoData, this.props.interval);
    }
  },
  render: function() {
    var repoId = this.props.repoId;
    var repoName = this.props.repoName;
    var commitsCount = this.state.commitsCount;
    var lines = this.state.lines;
    var additions = this.state.additions;
    var deletions = this.state.deletions;
    var firstCommit = this.state.firstCommit;
    var lastCommit = this.state.lastCommit;
    var hours = this.state.hours;

    var url = '/stat/chart/timeline/commits?in=' + repoId;

    return (
      <div className="repo-cell full">
        <div className="full">
          <h3 className="half">{repoName}<br/>
          <small>({repoId})</small></h3>
        </div>
        <div className="third">
          <ul>
            <li><span className="label">Commits:</span> {commitsCount}</li>
            <li><span className="label">Lines:</span> {lines}</li>
            <li><span className="label">Additions:</span> {additions}</li>
            <li><span className="label">Deletions:</span> {deletions}</li>
            <li><span className="label">First commit:</span> {firstCommit}</li>
            <li><span className="label">Last commit:</span> {lastCommit}</li>
            <li><span className="label">Estimated hours:</span> {hours}</li>
          </ul>
        </div>
        <div className="half">
          <GinatraChart type="Line" url={url} interval={this.props.interval} width="300" height="100" />
        </div>
      </div>
   );
  }
});

module.exports = RepoInfo;
