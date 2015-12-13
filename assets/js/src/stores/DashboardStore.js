import control from "control";
import DashboardActions from "actions/DashboardActions";
import RepoActions from "actions/RepoActions";

class DashboardStore {
  constructor() {
    this.bindListeners({
      updateVisibleRepos: DashboardActions.updateVisibleRepos,
      retrieveRepos: DashboardActions.retrieveRepos,
      switchRepoVisibility: RepoActions.switchVisibility
    });

    this.state = {
      visibleRepos: [],
      repos: {}
    };
  }

  updateVisibleRepos(visibleRepos) {
    this.setState({ visibleRepos });
  }

  retrieveRepos(repos) {
    this.setState({ repos });
  }

  switchRepoVisibility(repo) {
    var visibleRepos = this.state.visibleRepos,
        repoIndex = visibleRepos.indexOf(repo.repoId);

    if (repoIndex > -1 && !repo.isValid) {
      visibleRepos.splice(repoIndex, repoIndex + 1);
    }
    else if (repoIndex < 0) {
      visibleRepos = visibleRepos.concat(repo["repoId"]);
    }
    this.setState({ visibleRepos })
  }
}

export default control.createStore(DashboardStore, "DashboardStore");
