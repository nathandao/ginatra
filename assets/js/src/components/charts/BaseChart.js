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
      animationSteps: 60,
      responsive: true,
      scaleGridLineColor: 'rgba(255,255,255,0.5)',
      scaleLineColor: 'rgba(255,255,255,0.5)',
      scaleBackdropColor: 'rgba(255,255,255,0.75)',
      segmentStrokeColor: '#000',
    },
    chartData: {},
  }

  constructor(props) {
    super(props);
    this.state = {
      redraw: false,
    };
  }

  componentWillReceiveProps(nextProps) {
    let types = ['Bar', 'Pie', 'PolarArea'];
    let redraw = false;

    if (types.indexOf(this.props.type) >= 0) {
      let datasets = this.props.chartData;
      let nextDatasets = nextProps.chartData;
      if (this.props.type === 'Bar') {
        datasets = this.props.chartData.datasets;
        nextDatasets = nextProps.chartData.datasets;
      }
      if (datasets.length !== nextDatasets.length) {
        redraw = true;
      }
      this.setState({ redraw });
    }
  }

  render() {
    let chart = { Bar, Doughnut, Line, Pie, PolarArea, Radar };
    return (
      React.createElement(chart[this.props.type], {
        data: this.props.chartData,
        height: this.props.height,
        width: this.props.width,
        options: this.props.options,
        redraw: this.state.redraw,
      })
    );
  }
}

export default BaseChart;
