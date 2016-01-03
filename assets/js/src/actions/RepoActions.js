import control from 'control';

class RepoActions {
  constructor() {
    this.generateActions(
      'loadRepoList',
      'requestRepoListError',
      'reorderRepos',
      'switchRepoVisibility',
      'loadCommitsOverview',
      'requestCommitsOverviewError',
      'requestTodayOverview',
      'loadTodayOverview'
    );
  }
}

export default control.createActions(RepoActions);
