import React from 'react';
import _ from 'lodash';

import RepoCell from 'components/Dashboard/RepoCell';
import TodayOverview from 'components/Dashboard/TodayOverview';
import HourlyCommits from 'components/Dashboard/HourlyCommits';

class Dashboard extends React.Component {
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
          <div className="col-half">
            <TodayOverview commitsData={ this.props.commitsData } visibleRepos={ this._getVisibleRepos() } />
          </div>
          <div className="col-full">
            <HourlyCommits repos={ this._getVisibleRepos() } commitsData={ this.props.commitsData }/>
          </div>
        </section>
        <section>
          { this.repoPulses() }
        </section>
      </div>
    );
  }
}

export default Dashboard;
