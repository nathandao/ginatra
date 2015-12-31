import React from 'react';
import connectToStores from 'alt/utils/connectToStores';

import BaseChart from 'components/charts/BaseChart';
import RepoStore from 'stores/RepoStore';

@connectToStores
class RepoPulse extends React.Component {

  static getStores() {
    return [RepoStore];
  }

  static getPropsFromStores() {
    return RepoStore.getState();
  }

  constructor(props) {
    super(props);
  }

  render() {
    let repoIds = Object.keys(this.props.repoPulses);
    if (repoIds.length > 0 && repoIds.indexOf(this.props.repoId >= 0)) {
      console.log(this.props.repoPulses);
      let chartData = this.props.repoPulses[this.props.repoId];
      return (
        <BaseChart type={ this.props.type } chartData={ chartData } />
      );
    }
    else {
      return <div></div>
    }
  }
}

export default RepoPulse;
