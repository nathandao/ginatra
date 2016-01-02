import React from 'react';
import _ from 'lodash';

import RepoServices from 'services/RepoServices';
import RepoPulseServices from 'services/chart/RepoPulseServices';
import RepoPulse from 'components/Charts/RepoPulse';

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
      let repoContent = [];
      let pulseData = _.find(this.props.repoPulses, (repoPulse) => {
        return repoPulse.repoId === repo.id;
      });
      let overviewData = _.find(this.props.commitsOverviews, (overview) => {
        return overview.repoId === repo.id;
      });

      repoContent.push(
        <div className="col-full" key={ 'repo-head-' + repo.id }>
          <h5>{ repo.name } [ { repo.id } ]</h5>
        </div>
      );

      if (overviewData) {
        repoContent.push(
          <div className="col-full" key={ 'repo-overview-' + repo.id }>{ JSON.stringify(overviewData) }</div>
        );
      } else {
        RepoServices.requestCommitsOverview(repo.id);
      }

      if (pulseData) {
        repoContent.push(<RepoPulse chartData={ pulseData.chartData } key={ 'pulse-data-' + repo.id }/>);
      } else {
        RepoPulseServices.requestRepoPulse(repo.id);
      }

      return <div className="col-third" key={ repo.id }>{ repoContent }</div>;
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
