import React from 'react';
import _ from 'lodash';

import RepoPulseServices from 'services/chart/RepoPulseServices';
import RepoCell from 'components/Dashboard/RepoCell';

class Dashboard extends React.Component {
  componentWillMount() {
    let visibleRepos = this._getVisibleRepos().map((repo) => {
      return repo.id;
    });
    let reposWithPulses = this.props.repoPulses.map((pulse) => {
      return pulse.repoId;
    });
    let reposWithoutPulse = _.difference(visibleRepos, reposWithPulses);
    if (reposWithoutPulse.length > 0) {
      RepoPulseServices.requestRepoPulses(reposWithoutPulse);
    }
  }

  _getVisibleRepos() {
    return _.select(this.props.repos, (repo) => {
      return repo.visible === true;
    });
  }

  repoPulses() {
    let repos = this._getVisibleRepos();
    let content = repos.map((repo) => {
      return <RepoCell commitsOverviews={ this.props.commitsOverviews } repoPulses={ this.props.repoPulses } repo={ repo } key={ 'repo-cell-' + repo.id }/>;
    });
    return content;
  }

  render() {
    return (
      <div>
        <h1>Dashboard</h1>
        <section>
          { this.repoPulses() }
        </section>
      </div>
    );
  }
}

export default Dashboard;
