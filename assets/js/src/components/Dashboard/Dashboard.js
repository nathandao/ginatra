import React from 'react';
import _ from 'lodash';

import RepoCell from 'components/Charts/RepoCell';
import HourlyCommits from 'components/Charts/HourlyCommits';
import TodayOverview from 'components/Dashboard/TodayOverview';
import ReposOverview from 'components/Dashboard/ReposOverview';
import RepoSelector from 'components/RepoSelector/RepoSelector';

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
        <section>
          <div className="col-half">
            <section>
              <div className="col-third">
                <h3>Commits today</h3>
                <TodayOverview commitsData={ this.props.commitsData } visibleRepos={ this._getVisibleRepos() } />
              </div>
              <div className="col-two-third">
                <h3>Switch visibility</h3>
                <RepoSelector repos={ this.props.repos }/>
              </div>
            </section>

            <div className="col-full">
              <h3>Hourly commits</h3>
              <HourlyCommits repos={ this._getVisibleRepos() } commitsData={ this.props.commitsData }/>
            </div>
          </div>
          <div className="col-half">
            <h3>Overviews</h3>
            <ReposOverview repos={ this._getVisibleRepos() } commitsOverviews={ this.props.commitsOverviews }/>
          </div>
        </section>
        <h1>Commit counts in the past 7 days</h1>
        <section>
          { this.repoPulses() }
        </section>
      </div>
    );
  }
}

export default Dashboard;
