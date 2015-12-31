import React from 'react';
import _ from 'lodash';

import RepoPulse from 'components/Charts/RepoPulse';

class Dashboard extends React.Component {
  _getVisibleRepos() {
    return _.select(this.props.repos, (repo) => {
      return repo.visible === true;
    });
  }

  repoPulses() {
    let repos = this._getVisibleRepos();

    return repos.map((repo) => {
      let pulseData = _.find(this.props.repoPulses, (repoPulse) {
        return repoPulse.repoId === repo.id;
      });

      if (pulseData) {
        return <RepoPulse chartData={ pulseData }/>;
      }
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
