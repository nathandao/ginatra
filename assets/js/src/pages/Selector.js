import React from 'react';
import connectToStores from 'alt/utils/connectToStores';

import RepoSelector from 'components/RepoSelector/RepoSelector';
import RepoStore from 'stores/RepoStore';

class Selector extends React.Component {
  static getStores() {
    return [RepoStore];
  }

  static getPropsFromStores() {
    return RepoStore.getState();
  }

  render() {
    return (
      <div>
        <h1>Repo Selector</h1>
        <RepoSelector { ...this.props } />
      </div>
    );
  }
}

export default connectToStores(Selector);
