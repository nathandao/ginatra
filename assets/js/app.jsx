var React = require("react");
var $ = require("jquery");
var TimelineCommits = require("./components/TimelineCommits.jsx");
var PolarAreaLines = require("./components/PolarAreaLines.jsx");

$(function(){
    React.render(
        <TimelineCommits url='/stat/timeline/commits' interval='120000' width='1000' height='500' />,
        document.getElementById("dashboard")
    );

    React.render(
        <PolarAreaLines url='/stat/chart/lines?type=polararea' interval='3600000' width='500' height='500' />,
        document.getElementById("round")
    );
});