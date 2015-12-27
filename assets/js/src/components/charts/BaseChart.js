import React from 'react';

import {
  Bar,
  Doughnut,
  Line,
  Pie,
  PolarArea,
  Radar
} from 'react-chartjs';

class BaseChart extends React.Component {

  constructor() {
    super();
  }

  static defaultProps() {
    return {
      width: 1000,
      height: 500,
      type: 'Line'
    };
  }

  render() {

    var chart = [];
    chart['Bar'] = Bar;
    chart['Doughnut'] = Doughnut;
    chart['Line'] = Line;
    chart['Pie'] = Pie;
    chart['PolarArea'] = PolarArea;
    chart['Radar'] = Radar;
    console.log(this.props.chartData);

    return (
      React.createElement(chart[this.props.type], {
        data: this.props.chartData,
        height: this.props.height,
        width: this.props.width,
        options: {
          responsive: true,
          scaleGridLineColor: 'rgba(255,255,255,0.5)'
        }
      })
    );
  }
}

export default BaseChart;
