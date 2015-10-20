var React = require('react');
var $ = require('jquery');
var GinatraChart = require("./GinatraChart.jsx");


var RepoInfo = React.createClass({
  doubleDigit: function(digit) {
    if (digit < 10) {
      digit = "0" + digit;
    }
    return digit;
  },
  goodDay: function(dateStr) {
    var d = new Date(dateStr),
        date = this.doubleDigit(d.getDate()),
        month = this.doubleDigit(d.getMonth() + 1),
        year = d.getFullYear(),
        hours = this.doubleDigit(d.getHours()),
        minutes = this.doubleDigit(d.getMinutes());
    return date + "." + month + "." + year + " " + hours + ":" + minutes;
  },
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
          firstCommit: this.goodDay(info.first_commit),
          lastCommit: this.goodDay(info.last_commit)
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
    if (this.props.socket != undefined) {
      this.props.socket.onmessage = function(event) {
        var updatedRepos = event.data.split(",");
        if (updatedRepos.indexOf(this.props.repoId) > -1 || this.props.repoId == undefined) {
          this.loadRepoData();
        }
      }.bind(this);
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
      <div className="repo-cell third">
        <div className="full">
          <h3 className="half">{repoName} <small>({repoId})</small></h3>
        </div>
        <div className="full">
          <table>
            <tr>
              <td><span className="label">Commits</span></td>
              <td><span className="label">Lines</span></td>
              <td><span className="label">Additions</span></td>
              <td><span className="label">Deletions</span></td>
              <td><span className="label">First commit</span></td>
              <td><span className="label">Last commit</span></td>
              <td><span className="label">Est hours</span></td>
            </tr>
            <tr>
              <td>{commitsCount}</td>
              <td>{lines}</td>
              <td>{additions}</td>
              <td>{deletions}</td>
              <td>{firstCommit}</td>
              <td>{lastCommit}</td>
              <td>{hours}</td>
            </tr>
          </table>
        </div>
        <div className="full">
          <GinatraChart type="Line" url={url} socket={this.props.socket} width="300" height="100" />
        </div>
      </div>
    );
  }
});

module.exports = RepoInfo;
