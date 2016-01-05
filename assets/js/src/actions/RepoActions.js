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
      'requestCommits',
      'loadCommits'
    );
  }
}

export default control.createActions(RepoActions);
