import React from 'react';
import _ from 'lodash';

class Dashboard extends React.Component {
  _getVisibleRepos() {
    return _.select(this.props.repos, (repo) => {
      return repo.visible === true;
    });
  }

  render() {
    return (
      <div>
        <h1>Dashboard</h1>
        <div>{ JSON.stringify(this._getVisibleRepos()) }</div>
      </div>
    );
  }
}

export default Dashboard;
