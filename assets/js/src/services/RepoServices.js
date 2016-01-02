import request from 'reqwest';

import RepoActions from 'actions/RepoActions';
import {
  API_REPO_LIST,
  API_COMMITS_OVERVIEW,
} from 'constants/api';

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

  requestCommitsOverviews(repoIds) {
    repoIds.map((repoId) => {
      this.requestCommitsOverview(repoId);
    });
  }

  requestCommitsOverview(repoId) {
    request({
      url: API_COMMITS_OVERVIEW,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      data: { in: repoId },
      success: (resp) => {
        RepoActions.loadCommitsOverview({
          repoId,
          overviewData: resp,
        });
      },
      error: (err) => {
        RepoActions.requestCommitsOverviewError(err);
      },
    });
  }
}

export default new RepoServices();
