import React from 'react';
import _ from 'lodash';

import BaseChart from 'components/Charts/BaseChart';

class ContributorsComparison extends React.Component {
  getChartData() {
    let chartData = [];
    let contributorsData = _.filter(this.props.contributorsData, (data) => {
      let repoIndex = _.findIndex(this.props.repos, (repo) => {
        return repo.id === data.repoId;
      });
      return repoIndex >= 0;
    });

    if (contributorsData.length > 0) {
      chartData = contributorsData.map((data) => {
        let repoData = _.find(this.props.repos, (repo) => {
          return repo.id === data.repoId;
        });
        return {
          value: data.authors.length,
          color: repoData.color,
          highlight: repoData.color,
          label: repoData.name,
        };
      });
    }
    return chartData;
  }

  render() {
    let content = <div>Loading...</div>;
    let chartData = this.getChartData();
    if (chartData.length > 0) {
      content = <BaseChart type="PolarArea" chartData={ chartData } width="500" height="500"/>;
    }
    return (
      <div className="col-full">
        { content }
      </div>
    );
  }
}

export default ContributorsComparison;
