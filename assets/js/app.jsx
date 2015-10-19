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
  var Socket = window.MozWebSocket || window.WebSocket,
      socket = new Socket('ws://localhost:9290');

  React.render(
    <CommitsOverview url='/stat/commits_overview?from=today%20at%200:00&til=now' socket={socket} width='500' height='500' />,
    document.getElementById("today-overview")
  );

  React.render(
    <SprintOverview socket={socket} width='500' height='180' />,
    document.getElementById("sprint-overview")
  );

  React.render(
    <RepoTable url='/stat/repo_list' socket={socket} />,
    document.getElementById("repo-info")
  );

  React.render(
    <GinatraChart type="Doughnut" url="/stat/chart/round/lines" socket={socket} options='{ scaleBackdropColor : "rgba(255,255,255,1)" }' />,
    document.getElementById("project-size-comparison")
  );

  React.render(
    <TodayActivity socket={socket} width="500" height="300" />,
    document.getElementById("today-activity")
  );
});
