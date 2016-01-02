import React from 'react';
import connectToStores from 'alt/utils/connectToStores';

import RepoStore from 'stores/RepoStore';
import ChartStore from 'stores/ChartStore';
import Dashboard from 'components/Dashboard';

class Home extends React.Component {
  static getStores() {
    return [RepoStore, ChartStore];
  }

  static getPropsFromStores() {
    let initState = RepoStore.getState();
    initState.repoPulses = ChartStore.getState().pulses;
    return initState;
  }

  render() {
    return <Dashboard repos={ this.props.repos } repoPulses={ this.props.repoPulses }/>;
  }
}

export default connectToStores(Home);
