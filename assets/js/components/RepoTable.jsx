var $ = require("jquery");
var React = require("react");
var RepoInfo = require("./RepoInfo.jsx");

var RepoTable = React.createClass({
  loadRepoList: function() {
    $.ajax({
      url: this.props.url,
      cache: false,
      success: function(data) {
        this.setState({ repos: data });
      }.bind(this)
    });
  },
  getInitialState: function() {
    return { repos: [] };
  },
  componentDidMount: function() {
    this.loadRepoList();
  },
  render: function() {
    var rows = [];
    var repos = this.state.repos;
    var repoKeys = Object.keys(repos);
    for (var i = 0; i < repoKeys.length; i++) {
      rows.push(<RepoInfo interval="10000" repoId={repoKeys[i]} repoName={repos[repoKeys[i]].name} />);
    }
    return ( <div className="repo-list row full">{rows}</div> );
  }
});

module.exports = RepoTable;
