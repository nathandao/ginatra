import React from 'react';
import _ from 'lodash';

import BaseChart from 'components/Charts/BaseChart';

class EstHoursComparison extends React.Component {
  getChartData() {
    let chartData = [];
    let hoursData = _.filter(this.props.hoursData, (data) => {
      let repoIndex = _.findIndex(this.props.repos, (repo) => {
        return repo.id === data.repoId;
      });
      return repoIndex >= 0;
    });

    if (hoursData.length > 0) {
      chartData = hoursData.map((data) => {
        let repoData = _.find(this.props.repos, (repo) => {
          return repo.id === data.repoId;
        });
        let totalHours = 0;
        data.hours.map((authorsHours) => {
          totalHours = totalHours + authorsHours.hours;
        });
        return {
          value: Math.ceil(totalHours),
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
      content = <BaseChart type="Pie" chartData={ this.getChartData() } width="500" height="500" redraw/>;
    }
    return (
      <div className="col-full">
        { content }
      </div>
    );
  }
}

export default EstHoursComparison;
