var React = require("react");
var $ = require("jquery");
var TimelineCommits = require("./components/TimelineCommits.jsx");
var PolarAreaLines = require("./components/PolarAreaLines.jsx");
var CommitsOverview = require("./components/CommitsOverview.jsx");

$(function(){
    React.render(
        <CommitsOverview url='/stat/commits_overview?from=today%20at%200:00&til=now' interval='120000' width='500' height='500' />,
        document.getElementById("today-overview")
    );
});