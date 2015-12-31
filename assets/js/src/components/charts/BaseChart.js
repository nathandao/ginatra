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
  static propTypes() {
    return {
      type: React.PropTypes.oneOf(['Bar', 'Doughnut', 'Line', 'Pie', 'PolarArea', 'Radar']),
      width: React.PropTypes.number,
      height: React.PropTypes.number,
    };
  }
  static defaultProps() {
    return {
      width: 1000,
      height: 500,
      type: 'Line',
      options: {
        repsponsive: true,
        scaleGridLineColor: 'rgba(255,255,255,0.5)',
      },
      chartData: {},
    };
  }

  render() {
    let chart = { Bar, Doughnut, Line, Pie, PolarArea, Radar };

    return React.createElement(chart[this.props.type], {
      data: this.props.chartData,
      height: this.props.height,
      width: this.props.width,
      options: this.props.options,
    });
  }
}

export default BaseChart;
