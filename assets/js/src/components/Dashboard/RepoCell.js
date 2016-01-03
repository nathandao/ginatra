import React from 'react';
import _ from 'lodash';

import RepoPulse from 'components/charts/RepoPulse';
import RepoCellHeader from 'components/Dashboard/RepoCellHeader';

class RepoCell extends React.Component {
  repoOverview() {
    let repo = this.props.repo;
    let repoContent = [];
    let overviewData = _.find(this.props.commitsOverviews, (overview) => {
      return overview.repoId === repo.id;
    });

    if (overviewData) {
      repoContent.push(
        <RepoCellHeader overview={ overviewData } key={ 'cell-header-' + repo.id }/>
      );
    }

    return repoContent;
  }

  repoPulse() {
    let repo = this.props.repo;
    let repoContent = [];
    let pulseData = _.find(this.props.repoPulses, (repoPulse) => {
      return repoPulse.repoId === repo.id;
    });

    if (pulseData) {
      repoContent.push(
        <RepoPulse chartData={ pulseData.chartData } key={ 'pulse-data-' + repo.id }/>
      );
    }

    return repoContent;
  }

  render() {
    let repo = this.props.repo;
    let repoContent = [];

    repoContent.push(
      <div className="col-full" key={ 'repo-head-' + repo.id }>
        <h2>{ repo.name } [ { repo.id } ]</h2>
      </div>
    );
    repoContent = repoContent.concat(
      this.repoOverview(),
      this.repoPulse()
    );

    return <div className="col-third" key={ repo.id }>{ repoContent }</div>;
  }
}

export default RepoCell;
