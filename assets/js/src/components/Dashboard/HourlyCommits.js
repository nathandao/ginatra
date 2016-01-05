import React from 'react';
import moment from 'moment';
import _ from 'lodash';

import BarChart from 'components/Charts/BarChart';
import {
  HOURLY_TIME_STAMPS,
  HOURLY_TIME_LABELS,
} from 'constants/dashboard';

class HourlyCommits extends React.Component {
  getCommitsCountInHour(repoCommitData, index) {
    let commitsCount = _.countBy(repoCommitData.commits, (commit) => {
      let startTime = moment(new Date(HOURLY_TIME_STAMPS[index])).unix();
      let endTime = moment(new Date(HOURLY_TIME_STAMPS[index + 1])).unix();
      let commitDate = moment(new Date(commit.date)).unix();
      return startTime <= commitDate && commitDate <= endTime;
    });

    return commitsCount.true ? commitsCount.true : 0;
  }

  getRepoDataset(repo) {
    let repoCommitData = _.find(this.props.commitsData, (data) => {
      return data.repoId === repo.id;
    });
    let rgb = [repo.rgb.r, repo.rgb.g, repo.rgb.b].join(', ');
    let dataset = {
      label: repo.name,
      fillColor: `rgba(${ rgb }, 0.5)`,
      strokeColor: `rgba(${ rgb }, 0.8)`,
      highlightFill: `rgba(${ rgb }, 0.75)`,
      highlightStroke: `rgba(${ rgb }, 1)`,
      data: [],
    };

    for (let i = 0; i < HOURLY_TIME_STAMPS.length; i++) {
      let commitsCountInHour = this.getCommitsCountInHour(repoCommitData, i);
      dataset.data.push(commitsCountInHour);
    }

    return dataset;
  }

  getChartData() {
    let labels = HOURLY_TIME_LABELS;
    let chartData = {
      labels,
      datasets: [],
    };

    _.forEach(this.props.commitsData, (data) => {
      let repo = _.find(this.props.repos, (repoData) => {
        return repoData.id === data.repoId;
      });
      if (repo) {
        chartData.datasets.push(this.getRepoDataset(repo));
      }
    });

    return chartData;
  }

  render() {
    let chartData = this.getChartData();
    let content = <div></div>;
    if (chartData.datasets.length > 0) {
      content = <BarChart chartData={ this.getChartData() } width="1000" height="80"/>;
    }
    return content;
  }
}

export default HourlyCommits;
