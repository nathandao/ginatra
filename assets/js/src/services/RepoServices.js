import request from 'reqwest';

import ChartServices from 'services/ChartServices';
import RepoActions from 'actions/RepoActions';
import {
  API_REPO_LIST,
  API_COMMITS_OVERVIEW,
  API_COMMITS,
} from 'constants/api';
import { PULSE_TIME_STAMPS } from 'constants/dashboard';

class RepoServices {
  initData() {
    request({
      url: API_REPO_LIST,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      success: (resp) => {
        let startTime = PULSE_TIME_STAMPS[0];
        let endTime = PULSE_TIME_STAMPS[PULSE_TIME_STAMPS.length - 1];
        RepoActions.loadRepoList(resp);
        this.requestCommits(startTime, endTime);
        resp.map((repo) => {
          ChartServices.requestRepoPulse(repo.id);
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

  requestCommits(from, til) {
    request({
      url: API_COMMITS,
      method: 'get',
      type: 'json',
      dataType: 'application/json',
      data: { from, til },
      success: (resp) => {
        RepoActions.loadCommits(resp);
      },
      error: (err) => {
        RepoActions.requestTodayOverviewError(err);
      },
    });
  }
}

export default new RepoServices();
