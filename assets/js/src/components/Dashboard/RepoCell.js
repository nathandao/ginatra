import React from 'react';
import _ from 'lodash';

import BaseChart from 'components/Charts/BaseChart';
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
    let repoContent = <div>Loading...</div>;
    let pulseData = _.find(this.props.repoPulses, (repoPulse) => {
      return repoPulse.repoId === repo.id;
    });

    if (pulseData) {
      repoContent = <BaseChart type="Line" chartData={ pulseData.chartData } width="1000" height="400"/>;
    }

    return repoContent;
  }

  render() {
    let repo = this.props.repo;

    return (
      <div className="col-third" key={ repo.id }>
        <div className="col-full">
          <h3>{ repo.name } [ { repo.id } ]</h3>
        </div>
        { this.repoPulse() }
        { this.repoOverview() }
      </div>
    );
  }
}

export default RepoCell;
