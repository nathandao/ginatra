import control from 'control';

class DashboardActions {
  constructor() {
    this.generateActions(
      'getRepoListSuccess',
      'getRepoListError',
      'switchRepoVisibility',
      'reorderRepos',
      'flushCaches'
    );
  }
}

export default control.createActions(DashboardActions);
