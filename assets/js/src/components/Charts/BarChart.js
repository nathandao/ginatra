import React from 'react';

import BaseChart from 'components/charts/BaseChart';

class BarChart extends React.Component {
  static defaultProps = {
    height: 350,
    width: 1000,
    type: 'Bar',
    chartData: {
      labels: [
        'loading...',
      ],
      datasets: [],
    },
  }

  constructor(props) {
    super(props);
  }

  render() {
    let content = '';
    if (this.props.chartData !== null) {
      content = <BaseChart { ...this.props }/>;
    } else {
      content = <div>Loading...</div>;
    }
    return content;
  }
}

export default BarChart;
