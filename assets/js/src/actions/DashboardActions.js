import control from "control";

class DashboardActions {

  updateVisibleRepos(visibleRepos) {
    return visibleRepos;
  }

  retrieveRepos(repos) {
    return repos;
  }
}

export default control.createActions(DashboardActions);
