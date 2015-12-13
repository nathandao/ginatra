import React from "react";

import {
  BarChart,
  DoughnutChart,
  LineChart,
  PieChart,
  PolarAreaChart,
  RadarChart,
} from "react-chartjs";

const chart = [
  "Bar": BarChart,
  "Doughnut": DoughnutChart,
  "Line": LineChart,
  "Pie": PieChart,
  "PolarArea": PolarAreaChart,
  "Radar": RadarChart
];

class BaseChart exdends React.Component {

  constructor() {
    this.state = this._getState();
  }

  getDefaultProps() {
    return {
      width: 1000,
      height: 500,
      type: "PolarArea"
    }
  }

  render() {
    return (
      React.createElement(chart[type], {
        data: this.state.chartData,
        height: height,
        width: width,
        options: {
          responsive: true,
          scaleGridLineColor: "rgba(255,255,255,0.5)"
        }
      })
    );
  }
}

export default BaseChart;
