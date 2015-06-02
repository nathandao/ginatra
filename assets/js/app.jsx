var React = require("react");
var $ = require("jquery");
var GinatraChart = require("./components/GinatraChart.jsx");

$(function(){
    React.render(
        <GinatraChart url='/chart/polararea/overview' interval='10000' type="PolarArea" />,
        document.getElementById("dashboard")
    );
});