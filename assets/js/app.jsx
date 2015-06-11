var React = require("react");
var $ = require("jquery");
var TimelineCommits = require("./components/TimelineCommits.jsx");
var PolarAreaLines = require("./components/PolarAreaLines.jsx");
var CommitsOverview = require("./components/CommitsOverview.jsx");
var SprintOverview = require("./components/SprintOverview.jsx");
var RepoTable = require("./components/RepoTable.jsx");

$(function(){
    React.render(
        <CommitsOverview url='/stat/commits_overview?from=today%20at%200:00&til=now' interval='10000' width='500' height='500' />,
        document.getElementById("today-overview")
    );

    React.render(
        <SprintOverview interval='10000' />,
        document.getElementById("sprint-overview")
    );

    React.render(
        <RepoTable interval='10000' url='/stat/repo_list' />,
        document.getElementById("repo-info")
    );
});