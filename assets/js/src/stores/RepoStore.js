import requset from "reqwest";
import when from "when";

import control from "control";
import RepoActions from "actions/RepoActions";

class RepoStore {

  construct() {
    this.bindListener({
      updatePulseData: RepoActions.getPulseData
    });
  }

  updatePulseData(repoId) {
    request({
      url: API_CHART_REPO_PULSE,
      method: "get",
      type: "application/json",
      success: resp => {
        console.log(resp);
      }
    });
  }
}
