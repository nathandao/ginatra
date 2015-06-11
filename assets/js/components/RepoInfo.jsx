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
                    hours: info.hours,
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
            setInterval(this.loatRepoData, this.props.interval);
        }
    },
    render: function() {
        var repoId = this.props.repoId;
        var commitsCount = this.state.commitsCount;
        var lines = this.state.lines;
        var additions = this.state.additions;
        var deletions = this.state.deletions;
        var firstCommit = this.state.firstCommit;
        var lastCommit = this.state.lastCommit;
        var url = '/stat/chart/timeline/commits?in=' + repoId;

        return (
            <tbody>
            <tr>
            <td>{repoId}</td>
            <td>{commitsCount}</td>
            <td>{lines}</td>
            <td>{additions}</td>
            <td>{deletions}</td>
            <td>{firstCommit}</td>
            <td>{lastCommit}</td>
            </tr>
            <tr>
            <td colspan="7">
            <GinatraChart type="Line" url={url} interval={this.props.interval} width="1000" height="150" />
            </td>
            </tr>
            </tbody>
        );
    }
});

module.exports = RepoInfo;