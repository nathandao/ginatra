import React from 'react';
import _ from 'lodash';

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
    return repos.map((repo) => {
      let pulseData = _.find(this.props.repoPulses, (repoPulse) => {
        return repoPulse.repoId === repo.id;
      });
      if (!pulseData) {
        RepoPulseServices.requestRepoPulse(repo.id);
      } else {
        return (
          <div className="col-third" key={ repo.id }>
            <div className="col-full"><h5>{ repo.name } [ { repo.id } ]</h5></div>
            <RepoPulse chartData={ pulseData.chartData }/>
          </div>
        );
      }
    });
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
