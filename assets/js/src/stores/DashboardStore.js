import control from 'control';
import _ from 'lodash';

import DashboardActions from 'actions/DashboardActions';

class DashboardStore {
  constructor() {
    this.bindListeners({
      onGetRepoList: DashboardActions.getRepoListSuccess,
      // onReorderRepos: DashboardActions.reorderRepos,
      // onFlushCaches: DashboardActions.flushCaches,
    });

    this.state = {
      repos: [],
    };
  }

  onGetRepoList(repos) {
    _.forEach(repos, (repo, index) => {
      repos[index].visible = true;
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
}

export default control.createStore(DashboardStore, 'DashboardStore');
