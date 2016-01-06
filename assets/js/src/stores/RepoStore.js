import _ from 'lodash';

import control from 'control';
import RepoActions from 'actions/RepoActions';

class RepoStore {
  constructor() {
    this.bindActions(RepoActions);
    this.state = {
      repos: [],
      commitsOverviews: [],
      commitsData: [],
      contributorsData: [],
      hoursData: [],
    };
  }

  onLoadRepoList(repos) {
    _.forEach(repos, (repo, index) => {
      repos[index].visible = true;
      repos[index].rgb = this._hexToRgb(repos[index].color);
    });
    this.setState({
      repos,
    });
  }

  onSwitchRepoVisibility(repoId) {
    let repos = this.state.repos;
    let repoIndex = _.findIndex(repos, (repo) => {
      return repo.id === repoId;
    });

    if (repoIndex >= 0) {
      repos[repoIndex].visible = !repos[repoIndex].visible;
      this.setState({
        repos,
      });
    }
  }

  onLoadCommitsOverview(data) {
    let overviews = this.state.commitsOverviews;
    let repoIndex = _.findIndex(overviews, (overview) => {
      return overview.repoId === data.repoId;
    });

    if (repoIndex >= 0) {
      overviews[repoIndex] = data;
    } else {
      overviews.push(data);
    }
    this.setState({
      commitsOverviews: overviews,
    });
  }

  onLoadCommits(allCommitsData) {
    let commitsData = this.state.commitsData;
    _.forEach(allCommitsData, (data) => {
      let repoIndex = _.findIndex(commitsData, (commitData) => {
        return commitData.repoId === data.repoId;
      });

      if (repoIndex >= 0) {
        commitsData[repoIndex].commits = _.uniq(_.merge(
          commitsData[repoIndex].commits,
          data.commits
        ));
      } else {
        commitsData.push(data);
      }
    });
    this.setState({ commitsData });
  }

  onLoadContributors(newContributorsData) {
    let contributorsData = this.state.contributorsData;
    _.forEach(newContributorsData, (data) => {
      let repoIndex = _.findIndex(contributorsData, (repoContributorsData) => {
        return repoContributorsData.repoId === data.repoId;
      });

      if (repoIndex >= 0) {
        contributorsData[repoIndex] = data.authors;
      } else {
        contributorsData.push(data);
      }
    });
    this.setState({ contributorsData });
  }

  onLoadHours(newHoursData) {
    let hoursData = this.state.hoursData;
    _.forEach(newHoursData, (data) => {
      let repoIndex = _.findIndex(hoursData, (repoHoursData) => {
        return repoHoursData.repoId === data.repoId;
      });

      if (repoIndex > 0) {
        hoursData[repoIndex] = data.hours;
      } else {
        hoursData.push(data);
      }
    });
    this.setState({ hoursData });
  }

  _hexToRgb(hex) {
    let result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16),
    } : null;
  }
}

export default control.createStore(RepoStore, 'RepoStore');
