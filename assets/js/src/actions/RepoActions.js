import control from "control";

import {
  API_CHART_REPO_PULSE
} from "constants";

class RepoActions {

  getPulseData(repoId) {
    return repoId;
  }

  switchVisibility(repoId, isVisible = true) {
    return { repoId, isVisible };
  }
}

export default control.createActions(RepoActions);
