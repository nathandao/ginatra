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
        var repos = this.state.repos
        for (var i = 0; i < repos.length; i++) {
            rows.push(<RepoInfo interval={this.props.interval} repoId={repos[i]} />);
        }
        return (
            <table>
            <thead>
            <th>Project</th>
            <th>Commits</th>
            <th>Lines</th>
            <th>Add</th>
            <th>Del</th>
            <th>First Commit</th>
            <th>Last Commit</th>
            </thead>
            {rows}
            </table>
        );
    }
});

module.exports = RepoTable;