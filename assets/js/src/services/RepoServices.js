import request from 'reqwest';

import ChartServices from 'services/ChartServices';
import RepoActions from 'actions/RepoActions';
import {
  API_REPO_LIST,
  API_COMMITS_OVERVIEW,
  API_REPO_OVERVIEW,
  API_COMMITS,
  API_AUTHORS,
  API_HOURS,
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
        this.requestRepoOverviews();
        resp.map((repo) => {
          ChartServices.requestRepoPulse(repo.id);
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

  requestCommitsOverview(repoId = null) {
    let data = {};
    if (repoId !== null) {
      data.in = repoId;
    }
    request({
      url: API_COMMITS_OVERVIEW,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      data,
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

  requestRepoOverviews(repoId = null) {
    let data = {};
    if (repoId !== null) {
      data.in = repoId;
    }
    request({
      url: API_REPO_OVERVIEW,
      method: 'get',
      type: 'json',
      contentType: 'application/json',
      data,
      success: (resp) => {
        resp.map((repoOverview) => {
          RepoActions.loadCommitsOverview(repoOverview);
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

  requestContributors(repoId = null) {
    let data = {};
    if (repoId) {
      data.in = repoId;
    }
    request({
      url: API_AUTHORS,
      method: 'get',
      type: 'json',
      dataType: 'application/json',
      data,
      success: (resp) => {
        RepoActions.loadContributors(resp);
      },
      error: (err) => {
        RepoActions.requestContributorsError(err);
      },
    });
  }

  requestHours(repoId = null) {
    let data = {};
    if (repoId) {
      data.in = repoId;
    }
    request({
      url: API_HOURS,
      method: 'get',
      type: 'json',
      dataType: 'application/json',
      data,
      success: (resp) => {
        RepoActions.loadHours(resp);
      },
      error: (err) => {
        RepoActions.requestHoursError(err);
      },
    });
  }
}

export default new RepoServices();
