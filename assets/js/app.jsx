var $ = require("jquery");
var React = require("react");
var Chart = require("react-chartjs");
var TimelineCommits = require("./components/TimelineCommits.jsx");
var PolarAreaLines = require("./components/PolarAreaLines.jsx");
var CommitsOverview = require("./components/CommitsOverview.jsx");
var SprintOverview = require("./components/SprintOverview.jsx");
var RepoTable = require("./components/RepoTable.jsx");
var GinatraChart = require("./components/GinatraChart.jsx");
var TodayActivity = require("./components/TodayActivity.jsx");

$(function(){
    React.render(
        <CommitsOverview url='/stat/commits_overview?from=today%20at%200:00&til=now' interval='10000' width='500' height='500' />,
        document.getElementById("today-overview")
    );

    React.render(
        <SprintOverview interval='120000' width='500' height='180' />,
        document.getElementById("sprint-overview")
    );

    React.render(
        <RepoTable interval='30000' url='/stat/repo_list' />,
        document.getElementById("repo-info")
    );

    React.render(
        <GinatraChart type="Doughnut" url="/stat/chart/round/lines" interval="300000" options='{ scaleBackdropColor : "rgba(255,255,255,1)" }' />,
        document.getElementById("project-size-comparison")
    );

    React.render(
        <TodayActivity interval="20000" width="500" height="300" />,
        document.getElementById("today-activity")
    );
});