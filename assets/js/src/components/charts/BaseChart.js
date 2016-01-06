import React from 'react';

import {
  Bar,
  Doughnut,
  Line,
  Pie,
  PolarArea,
  Radar,
} from 'react-chartjs';

class BaseChart extends React.Component {
  static defaultProps = {
    width: 1000,
    height: 400,
    type: 'Line',
    options: {
      responsive: true,
      scaleGridLineColor: 'rgba(255,255,255,0.5)',
      scaleLineColor: 'rgba(255,255,255,0.5)',
      scaleBackdropColor: 'rgba(255,255,255,0.75)',
      segmentStrokeColor: '#bada55',
    },
    chartData: {},
  }

  render() {
    let chart = { Bar, Doughnut, Line, Pie, PolarArea, Radar };
    return (
      React.createElement(chart[this.props.type], {
        data: this.props.chartData,
        height: this.props.height,
        width: this.props.width,
        options: this.props.options,
      })
    );
  }
}

export default BaseChart;
