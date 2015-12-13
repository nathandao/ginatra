import request from "reqwest";

import DashboardActions from "actions/DashboardActions";
import { API_REPO_LIST } from "constants";

class DashboardService {
  getRepos() {
    request({
      url: API_REPO_LIST,
      method: "get",
      dataType: "application/json",
      success: function(resp) {
        DashboardActions.retrieveRepos(resp);
        var visibleRepos = Object.keys(resp);
        DashboardActions.updateVisibleRepos(visibleRepos);
      }
    });
  }
}

export default new DashboardService();
