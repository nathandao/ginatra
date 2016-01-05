import React from 'react';
import _ from 'lodash';

import LineChart from 'components/Charts/LineChart';
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
        <LineChart chartData={ pulseData.chartData } key={ 'pulse-data-' + repo.id }/>
      );
    }

    return repoContent;
  }

  render() {
    let repo = this.props.repo;

    return (
      <div className="col-third" key={ repo.id }>
        <div className="col-full">
          <h2>{ repo.name } [ { repo.id } ]</h2>
        </div>
        { this.repoOverview() }
        { this.repoPulse() }
      </div>
    );
  }
}

export default RepoCell;
