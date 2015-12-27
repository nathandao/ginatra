import request from 'reqwest';

import DashboardActions from 'actions/DashboardActions';
import { API_REPO_LIST } from 'constants/api';

class DashboardServices {
  getRepoList() {
    request({
      url: API_REPO_LIST,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      success: (resp) => {
        DashboardActions.getRepoListSuccess(resp);
      },
      error: (err) => {
        DashboardActions.getRepoListError(err);
      },
    });
  }
}

export default new DashboardServices();
