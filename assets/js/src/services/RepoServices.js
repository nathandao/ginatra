import request from 'reqwest';
import moment from 'moment';

import RepoPulseServices from 'services/chart/RepoPulseServices';
import RepoActions from 'actions/RepoActions';
import {
  API_REPO_LIST,
  API_COMMITS_OVERVIEW,
} from 'constants/api';

class RepoServices {
  initData() {
    request({
      url: API_REPO_LIST,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      success: (resp) => {
        RepoActions.loadRepoList(resp);
        resp.map((repo) => {
          RepoPulseServices.requestRepoPulse(repo.id);
          this.requestCommitsOverview(repo.id);
        });
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

  requestTodayOverview() {
    let todayEnd = moment().hour(23).minute(59).second(59).format('MM-DD-YYYY HH:mm');
    let todayStart = moment().hour(0).minute(0).second(0).format('MM-DD-YYYY HH:mm');
    request({
      url: API_COMMITS_OVERVIEW,
      method: 'get',
      type: 'json',
      dataType: 'application/json',
      data: { from: todayStart, til: todayEnd },
      success: (resp) => {
        RepoActions.loadTodayOverview(resp);
      },
      error: (err) => {
        RepoActions.requestTodayOverviewError(err);
      },
    });
  }
}

export default new RepoServices();
