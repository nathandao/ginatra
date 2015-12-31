import React from 'react';

import BaseChart from 'components/Charts/BaseChart';

class RepoPulse extends React.Component {
  static propTypes() {
    return {
      repoId: React.PropTypes.string.isRequired,
      type: React.PropTypes.oneOf(['Line', 'PolarArea', 'Radar']),
    };
  }

  static defaultProps() {
    return {
      height: 400,
      width: 1000,
      options: {},
      type: 'Line',
    };
  }

  render() {
    return <BaseChart chartData={ this.props.chartData }/>;
  }
}

export default RepoPulse;
