import React from 'react';
import connectToStores from 'alt/utils/connectToStores';

import RepoStore from 'stores/RepoStore';
import Dashboard from 'components/Dashboard';

class App extends React.Component {
  static getStores() {
    return [RepoStore];
  }

  static getPropsFromStores() {
    return RepoStore.getState();
  }

  render() {
    return (
      <div>
        <h1>Ginatra</h1>
        <Dashboard repos={ this.props.repos } />
      </div>
    );
  }
}

export default connectToStores(App);
