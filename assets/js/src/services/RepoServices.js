import request from 'reqwest';

import RepoActions from 'actions/RepoActions';
import { API_REPO_LIST } from 'constants/api';

class RepoServices {
  requestRepoList() {
    request({
      url: API_REPO_LIST,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      success: (resp) => {
        RepoActions.loadRepoList(resp);
      },
      error: (err) => {
        RepoActions.requestRepoListError(err);
      },
    });
  }
}

export default new RepoServices();
