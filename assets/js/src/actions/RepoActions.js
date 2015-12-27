import control from 'control';

class RepoActions {
  constructor() {
    this.generateActions(
      'getRepoPulse',
      'switchRepoVisibility'
    );
  }
}

export default control.createActions(RepoActions);
