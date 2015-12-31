import React from 'react';
import connectToStores from 'alt/utils/connectToStores';

import RepoStore from 'stores/RepoStore';
import Dashboard from 'components/Dashboard';

class Home extends React.Component {
  static getStores() {
    return [RepoStore];
  }

  static getPropsFromStores() {
    return RepoStore.getState();
  }

  render() {
    return <Dashboard repos={ this.props.repos }/>;
  }
}

export default connectToStores(Home);
