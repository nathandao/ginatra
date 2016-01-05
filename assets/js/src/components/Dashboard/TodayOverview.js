import React from 'react';
import moment from 'moment';
import _ from 'lodash';

class TodayOverview extends React.Component {
  getTodayData() {
    let todayStart = moment(new Date()).hour(0).minute(0).second(0).unix();
    let todayEnd = moment(new Date()).hour(23).minute(59).second(59).unix();
    let todayData = {
      commitsCount: 0,
      additions: 0,
      deletions: 0,
    };
    let visibleReposData = _.filter(this.props.commitsData, (repoData) => {
      let index = _.findIndex(this.props.visibleRepos, (repo) => {
        return repo.id === repoData.repoId;
      });
      return index >= 0;
    });

    _.forEach(visibleReposData, (repoData) => {
      let todayCommits = _.filter(repoData.commits, (commit) => {
        let commitDate = moment(new Date(commit.date)).unix();
        return commitDate >= todayStart && commitDate <= todayEnd;
      });

      todayData.commitsCount = todayData.commitsCount + todayCommits.length;

      _.forEach(todayCommits, (commit) => {
        _.forEach(commit.changes, (change) => {
          if (change.additions) {
            todayData.additions = todayData.additions + Number(change.additions);
          }
          if (change.deletions) {
            todayData.deletions = todayData.deletions + Number(change.deletions);
          }
        });
      });
    });

    return todayData;
  }

  render() {
    let todayData = this.getTodayData();
    return (
      <section>
        <div className="col-half">
          <h1>{ todayData.commitsCount }</h1>
          <h2>Commits</h2>
        </div>
        <div className="col-half">
          <h3>{ todayData.additions } +</h3>
          <h3>{ todayData.deletions} -</h3>
        </div>
      </section>
    );
  }
}

export default TodayOverview;
